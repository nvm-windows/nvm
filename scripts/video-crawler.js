#!/usr/bin/env node
'use strict';

/**
 * Crawl authenticated listing/profile pages and collect the best available
 * MP4 variant from each discovered video page.
 *
 * This utility is intended for sites and media that the operator is
 * authorized to access. It does not bypass authentication or CAPTCHAs.
 *
 * Examples:
 *   node scripts/video-crawler.js --url https://example.test/profile/alice
 *   node scripts/video-crawler.js --url https://example.test/videos --concurrency 3
 *   node scripts/video-crawler.js --url https://example.test/videos --storage-state storageState.json
 */

const fs = require('node:fs');
const fsp = require('node:fs/promises');
const path = require('node:path');
const readline = require('node:readline/promises');
const process = require('node:process');
const { URL } = require('node:url');

function getChromium() {
  try {
    return require('playwright').chromium;
  } catch (loadError) {
    throw new Error(
      'Playwright is required. Run "npm install" in the scripts directory, '
      + 'then "npx playwright install chromium".',
      { cause: loadError },
    );
  }
}

const DEFAULT_CDP_ENDPOINT = 'http://localhost:9222';
const DEFAULT_OUTPUT_DIR = path.resolve(process.cwd(), 'video-crawler-output');
const DEFAULT_CONCURRENCY = 2;
const DEFAULT_RETRIES = 3;
const DEFAULT_JITTER_MIN = 600;
const DEFAULT_JITTER_MAX = 1500;
const RETRYABLE_STATUS_CODES = new Set([408, 425, 429, 500, 502, 503, 504]);
const INVALID_WINDOWS_FILENAME_CHARACTERS = /[<>:"/\\|?*]/g;
const VIDEO_PAGE_PATTERN = /\/(?:scenes|video|movies|watch)(?:\/|$)/i;
const MP4_PATTERN = /https?:\/\/[^\s"'<>\\]+?\.mp4(?:\?[^\s"'<>\\]*)?/gi;
const PAGE_QUERY_PATTERN = /(?:[?&])page=\d+/i;

function log(message, ...args) {
  console.log(`[video-crawler] ${message}`, ...args);
}

function warn(message, ...args) {
  console.warn(`[video-crawler] WARN: ${message}`, ...args);
}

function error(message, ...args) {
  console.error(`[video-crawler] ERROR: ${message}`, ...args);
}

function sleep(milliseconds) {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}

function randomBetween(minimum, maximum) {
  return Math.floor(Math.random() * (maximum - minimum + 1)) + minimum;
}

function sanitizeFolderName(value) {
  const sanitized = String(value || 'profile')
    .replace(INVALID_WINDOWS_FILENAME_CHARACTERS, '')
    .replace(/[.\s]+$/g, '')
    .replace(/\s+/g, ' ')
    .trim();
  return sanitized || 'profile';
}

function parseArguments(argv) {
  const options = {
    url: null,
    outputDir: DEFAULT_OUTPUT_DIR,
    cdpEndpoint: DEFAULT_CDP_ENDPOINT,
    storageState: null,
    cookiesFile: null,
    concurrency: DEFAULT_CONCURRENCY,
    retries: DEFAULT_RETRIES,
    jitterMin: DEFAULT_JITTER_MIN,
    jitterMax: DEFAULT_JITTER_MAX,
    timeout: 45_000,
    maxListingPages: 500,
    maxVideoPages: 10_000,
    headlessFallback: false,
  };

  const valueOptions = new Set([
    '--url',
    '--output-dir',
    '--cdp-endpoint',
    '--storage-state',
    '--cookies',
    '--concurrency',
    '--retries',
    '--jitter-min',
    '--jitter-max',
    '--timeout',
    '--max-listing-pages',
    '--max-video-pages',
  ]);

  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    if (argument === '--headless-fallback') {
      options.headlessFallback = true;
      continue;
    }
    if (argument === '--help' || argument === '-h') {
      printUsage();
      process.exit(0);
    }
    if (!valueOptions.has(argument)) {
      if (!options.url && !argument.startsWith('-')) {
        options.url = argument;
        continue;
      }
      throw new Error(`Unknown argument: ${argument}`);
    }
    const value = argv[index + 1];
    if (!value || value.startsWith('--')) {
      throw new Error(`Missing value for ${argument}`);
    }
    index += 1;
    switch (argument) {
      case '--url':
        options.url = value;
        break;
      case '--output-dir':
        options.outputDir = path.resolve(value);
        break;
      case '--cdp-endpoint':
        options.cdpEndpoint = value;
        break;
      case '--storage-state':
        options.storageState = path.resolve(value);
        break;
      case '--cookies':
        options.cookiesFile = path.resolve(value);
        break;
      case '--concurrency':
        options.concurrency = clampInteger(value, 1, 3, argument);
        break;
      case '--retries':
        options.retries = clampInteger(value, 0, 10, argument);
        break;
      case '--jitter-min':
        options.jitterMin = clampInteger(value, 0, 60_000, argument);
        break;
      case '--jitter-max':
        options.jitterMax = clampInteger(value, 0, 60_000, argument);
        break;
      case '--timeout':
        options.timeout = clampInteger(value, 1_000, 300_000, argument);
        break;
      case '--max-listing-pages':
        options.maxListingPages = clampInteger(value, 1, 100_000, argument);
        break;
      case '--max-video-pages':
        options.maxVideoPages = clampInteger(value, 1, 1_000_000, argument);
        break;
      default:
        throw new Error(`Unhandled argument: ${argument}`);
    }
  }

  if (!options.url) {
    throw new Error('A starting URL is required. Use --url <url>.');
  }
  options.url = new URL(options.url).toString();
  if (options.jitterMax < options.jitterMin) {
    [options.jitterMin, options.jitterMax] = [options.jitterMax, options.jitterMin];
  }
  return options;
}

function clampInteger(value, minimum, maximum, optionName) {
  const parsed = Number.parseInt(value, 10);
  if (!Number.isInteger(parsed) || parsed < minimum || parsed > maximum) {
    throw new Error(`${optionName} must be an integer from ${minimum} to ${maximum}`);
  }
  return parsed;
}

function printUsage() {
  console.log(`
Usage:
  node scripts/video-crawler.js --url <starting-url> [options]

Options:
  --output-dir <dir>          Output directory (default: ./video-crawler-output)
  --cdp-endpoint <url>        Existing Chrome CDP endpoint (default: http://localhost:9222)
  --storage-state <file>      Playwright storageState.json fallback
  --cookies <file>            Netscape cookies.txt fallback
  --concurrency <1-3>         Video page concurrency (default: 2)
  --retries <n>               Retries for navigation and redirect resolution (default: 3)
  --jitter-min <ms>           Minimum delay between video pages (default: 600)
  --jitter-max <ms>           Maximum delay between video pages (default: 1500)
  --timeout <ms>              Navigation/request timeout (default: 45000)
  --max-listing-pages <n>     Listing-page safety limit (default: 500)
  --max-video-pages <n>       Video-page safety limit (default: 10000)
  --headless-fallback         Launch fallback Chromium headless instead of headed
`);
}

function decodeEscapedText(value) {
  return String(value)
    .replace(/\\u002F/gi, '/')
    .replace(/\\u0026/gi, '&')
    .replace(/\\u003F/gi, '?')
    .replace(/\\u003D/gi, '=')
    .replace(/\\u0026/gi, '&')
    .replace(/\\x2f/gi, '/')
    .replace(/\\x26/gi, '&')
    .replace(/\\(["'])/g, '$1')
    .replace(/&amp;/gi, '&');
}

function normalizeUrl(candidate, baseUrl) {
  if (!candidate) {
    return null;
  }
  const decoded = decodeEscapedText(String(candidate).trim()).replace(/[),.;]+$/g, '');
  try {
    const resolved = new URL(decoded, baseUrl);
    if (!/^https?:$/i.test(resolved.protocol)) {
      return null;
    }
    return resolved.toString();
  } catch {
    return null;
  }
}

function isMp4Url(url) {
  return /\.mp4(?:$|[?#])/i.test(url);
}

function parseNetscapeCookies(contents, fallbackUrl) {
  const fallback = new URL(fallbackUrl);
  const cookies = [];
  for (const line of contents.split(/\r?\n/)) {
    if (!line || line.startsWith('#') || line.split('\t').length < 7) {
      continue;
    }
    const [domain, includeSubdomains, pathValue, secure, expires, name, ...valueParts] = line.split('\t');
    const cookiePath = pathValue || '/';
    const host = domain.replace(/^\./, '');
    cookies.push({
      name,
      value: valueParts.join('\t'),
      domain: domain || fallback.hostname,
      path: cookiePath,
      secure: secure.toUpperCase() === 'TRUE',
      expires: Number(expires) > 0 ? Number(expires) : undefined,
      url: domain ? undefined : fallback.origin,
      sameSite: includeSubdomains.toUpperCase() === 'TRUE' ? 'Lax' : undefined,
      // Playwright requires a URL when a cookie has no valid domain.
      ...(host ? {} : { url: fallback.origin }),
    });
  }
  return cookies;
}

async function connectToBrowser(options) {
  const chromium = getChromium();
  try {
    const browser = await chromium.connectOverCDP(options.cdpEndpoint, {
      timeout: 5_000,
    });
    const contexts = browser.contexts();
    if (!contexts.length) {
      throw new Error('Connected Chrome has no browser contexts');
    }
    log(`Attached to existing Chrome via ${options.cdpEndpoint}`);
    return { browser, context: contexts[0], connectedOverCdp: true };
  } catch (attachError) {
    warn(`Could not attach to Chrome CDP: ${attachError.message}`);
    const storageStatePath = options.storageState
      || (fs.existsSync(path.resolve(process.cwd(), 'storageState.json'))
        ? path.resolve(process.cwd(), 'storageState.json')
        : null);
    const cookiesPath = options.cookiesFile
      || (fs.existsSync(path.resolve(process.cwd(), 'cookies.txt'))
        ? path.resolve(process.cwd(), 'cookies.txt')
        : null);
    const storageState = storageStatePath && fs.existsSync(storageStatePath)
      ? JSON.parse(await fsp.readFile(storageStatePath, 'utf8'))
      : undefined;
    const browser = await chromium.launch({
      headless: options.headlessFallback,
    });
    const context = await browser.newContext(storageState);
    if (cookiesPath && fs.existsSync(cookiesPath)) {
      const contents = await fsp.readFile(cookiesPath, 'utf8');
      const cookies = parseNetscapeCookies(contents, options.url);
      if (cookies.length) {
        await context.addCookies(cookies);
        log(`Loaded ${cookies.length} cookies from ${cookiesPath}`);
      }
    }
    log('Started fallback Chromium context');
    return { browser, context, connectedOverCdp: false };
  }
}

async function pauseForManualAuthentication(page, reason) {
  warn(`${reason}. Complete authentication manually in the browser.`);
  const input = readline.createInterface({ input: process.stdin, output: process.stdout });
  await input.question('Press Enter after authentication is complete to resume crawling. ');
  input.close();
  await page.waitForLoadState('domcontentloaded', { timeout: 15_000 }).catch(() => {});
}

async function sessionLooksExpired(page) {
  const pathname = new URL(page.url()).pathname.toLowerCase();
  if (pathname === '/login' || pathname.startsWith('/login/')) {
    return true;
  }
  return page.locator('form[action*="login" i], input[type="password"]').first().isVisible()
    .catch(() => false);
}

async function navigateWithRetry(page, url, options, label) {
  let lastError;
  for (let attempt = 0; attempt <= options.retries; attempt += 1) {
    try {
      await page.goto(url, { waitUntil: 'domcontentloaded', timeout: options.timeout });
      if (await sessionLooksExpired(page)) {
        await pauseForManualAuthentication(page, `Session appears expired while opening ${label}`);
        if (await sessionLooksExpired(page)) {
          throw new Error('Session is still unauthenticated after manual re-authentication');
        }
      }
      return;
    } catch (navigationError) {
      lastError = navigationError;
      if (attempt === options.retries) {
        break;
      }
      const delay = 1_000 * (2 ** attempt) + randomBetween(0, 500);
      warn(`Retrying ${label} after ${navigationError.message} (${delay} ms)`);
      await sleep(delay);
    }
  }
  throw new Error(`Unable to open ${label}: ${lastError.message}`);
}

async function extractHeading(page) {
  const heading = await page.locator('h1, .model-name, title').first().textContent().catch(() => null);
  return sanitizeFolderName(heading || new URL(page.url()).hostname);
}

async function collectListingLinks(page) {
  return page.evaluate(() => {
    const absolute = (element) => {
      const href = element.getAttribute('href');
      try {
        return href ? new URL(href, location.href).toString() : null;
      } catch {
        return null;
      }
    };
    const values = [];
    for (const anchor of document.querySelectorAll('a[href]')) {
      const url = absolute(anchor);
      if (url) values.push({ url, text: (anchor.textContent || '').trim(), rel: anchor.rel || '' });
    }
    return values;
  });
}

async function scrollListingPage(page) {
  await page.evaluate(async () => {
    const maximumScrolls = 40;
    let unchanged = 0;
    let previousHeight = 0;
    for (let index = 0; index < maximumScrolls; index += 1) {
      window.scrollTo(0, document.body.scrollHeight);
      await new Promise((resolve) => setTimeout(resolve, 350));
      const height = document.body.scrollHeight;
      if (height === previousHeight) {
        unchanged += 1;
      } else {
        unchanged = 0;
        previousHeight = height;
      }
      if (unchanged >= 3) break;
    }
  }).catch(() => {});
}

function classifyListingLinks(links, currentUrl) {
  const pageLinks = [];
  const videoLinks = [];
  for (const item of links) {
    const normalized = normalizeUrl(item.url, currentUrl);
    if (!normalized) continue;
    const candidate = { ...item, url: normalized };
    if (VIDEO_PAGE_PATTERN.test(new URL(normalized).pathname)) {
      videoLinks.push(normalized);
    }
    const isNext = /\bnext\b/i.test(item.text) || /\bnext\b/i.test(item.rel)
      || /\bnext\b/i.test(item.url);
    const isNumberedPage = PAGE_QUERY_PATTERN.test(normalized);
    if (isNext || isNumberedPage) {
      pageLinks.push(normalized);
    }
  }
  return { pageLinks, videoLinks };
}

async function discoverVideoPages(page, startUrl, options) {
  const listingQueue = [startUrl];
  const visitedListings = new Set();
  const videoPages = new Set();
  while (listingQueue.length && visitedListings.size < options.maxListingPages) {
    const listingUrl = listingQueue.shift();
    if (visitedListings.has(listingUrl)) continue;
    visitedListings.add(listingUrl);
    log(`Mapping listing ${visitedListings.size}: ${listingUrl}`);
    await navigateWithRetry(page, listingUrl, options, 'listing page');
    await scrollListingPage(page);
    const links = await collectListingLinks(page);
    const { pageLinks, videoLinks } = classifyListingLinks(links, page.url());
    for (const videoUrl of videoLinks) {
      videoPages.add(videoUrl);
    }
    for (const pageUrl of pageLinks) {
      if (!visitedListings.has(pageUrl)) listingQueue.push(pageUrl);
    }
    log(`Listing yielded ${videoLinks.length} video links; ${listingQueue.length} listing pages queued`);
  }
  if (listingQueue.length) {
    warn(`Listing safety limit reached; ${listingQueue.length} pages remain queued`);
  }
  return [...videoPages].slice(0, options.maxVideoPages);
}

function candidateFromUrl(url, metadata = {}, requireMp4 = true) {
  const normalized = normalizeUrl(url, metadata.baseUrl || url);
  return normalized && (!requireMp4 || isMp4Url(normalized))
    ? { url: normalized, ...metadata }
    : null;
}

function extractMp4Strings(text, baseUrl, source) {
  const candidates = [];
  const decoded = decodeEscapedText(text);
  for (const match of decoded.matchAll(MP4_PATTERN)) {
    const candidate = candidateFromUrl(match[0], { baseUrl, source });
    if (candidate) candidates.push(candidate);
  }
  return candidates;
}

async function inspectInteractiveVideoControls(page) {
  const selectors = [
    'button',
    '[role="button"]',
    'summary',
    'select',
    '[aria-haspopup="menu"]',
    '[data-res]',
    '[data-resolution]',
  ];
  const controls = page.locator(selectors.join(','));
  const count = await controls.count();
  for (let index = 0; index < Math.min(count, 40); index += 1) {
    const control = controls.nth(index);
    const label = [
      await control.textContent().catch(() => ''),
      await control.getAttribute('aria-label').catch(() => ''),
      await control.getAttribute('title').catch(() => ''),
    ].join(' ');
    if (!/(download|resolution|quality|4k|2160|uhd|video)/i.test(label)) continue;
    await control.click({ timeout: 1_500, force: true }).catch(() => {});
    await page.waitForTimeout(300);
  }
}

async function extractDomCandidates(page) {
  await inspectInteractiveVideoControls(page);
  const records = await page.evaluate(() => {
    const output = [];
    const add = (element, rawUrl) => {
      if (!rawUrl) return;
      output.push({
        url: rawUrl,
        text: (element.textContent || '').trim(),
        title: element.getAttribute('title') || '',
        label: element.getAttribute('aria-label') || '',
        resolution: element.getAttribute('data-res') || element.getAttribute('data-resolution') || '',
      });
    };
    for (const element of document.querySelectorAll('a[href*=".mp4" i], a[href*="download" i], video[src], source[src], [data-src*=".mp4" i], [data-url*=".mp4" i]')) {
      add(element, element.getAttribute('href') || element.getAttribute('src')
        || element.getAttribute('data-src') || element.getAttribute('data-url'));
    }
    return output;
  });
  return records.flatMap((record) => {
    const candidate = candidateFromUrl(record.url, {
      baseUrl: page.url(),
      source: 'dom',
      text: record.text,
      title: record.title,
      label: record.label,
      resolution: record.resolution,
    }, false);
    return candidate ? [candidate] : [];
  });
}

async function extractEmbeddedCandidates(page) {
  const scripts = await page.locator('script').allTextContents().catch(() => []);
  const candidates = [];
  for (const script of scripts) {
    candidates.push(...extractMp4Strings(script, page.url(), 'embedded-script'));
  }
  const jsonLd = await page.locator('script[type="application/ld+json"]').allTextContents().catch(() => []);
  for (const block of jsonLd) {
    candidates.push(...extractMp4Strings(block, page.url(), 'json-ld'));
  }
  const html = await page.content();
  candidates.push(...extractMp4Strings(html, page.url(), 'html-state'));
  return candidates;
}

async function resolveRedirectCandidate(request, candidate, options) {
  if (isMp4Url(candidate.url)) return candidate;
  let lastError;
  for (let attempt = 0; attempt <= options.retries; attempt += 1) {
    try {
      const response = await request.head(candidate.url, {
        maxRedirects: 8,
        timeout: options.timeout,
        failOnStatusCode: false,
      });
      const finalUrl = response.url();
      const contentType = response.headers()['content-type'] || '';
      if (isMp4Url(finalUrl) || /video\/mp4/i.test(contentType)) {
        return candidateFromUrl(finalUrl, {
          ...candidate,
          source: `${candidate.source || 'dom'}-redirect`,
          contentType,
        });
      }
      return null;
    } catch (requestError) {
      lastError = requestError;
      if (attempt < options.retries) {
        await sleep(500 * (2 ** attempt));
      }
    }
  }
  warn(`Could not resolve ${candidate.url}: ${lastError.message}`);
  return null;
}

function resolutionScore(candidate) {
  const haystack = [
    candidate.url,
    candidate.text,
    candidate.title,
    candidate.label,
    candidate.resolution,
  ].join(' ').toLowerCase();
  if (/(?:4k|2160p|uhd|ultra[\s-]*hd)/i.test(haystack)) return 400;
  if (/1440p/i.test(haystack)) return 300;
  if (/1080p|full[\s-]*hd/i.test(haystack)) return 200;
  if (/720p|hd/i.test(haystack)) return 100;
  return 50;
}

function deduplicateCandidates(candidates) {
  const byUrl = new Map();
  for (const candidate of candidates) {
    if (!candidate || !candidate.url) continue;
    const existing = byUrl.get(candidate.url);
    if (!existing || resolutionScore(candidate) > resolutionScore(existing)) {
      byUrl.set(candidate.url, candidate);
    }
  }
  return [...byUrl.values()];
}

function selectBestResolution(candidates) {
  const unique = deduplicateCandidates(candidates);
  if (!unique.length) return [];
  const highestScore = Math.max(...unique.map(resolutionScore));
  return unique.filter((candidate) => resolutionScore(candidate) === highestScore);
}

async function extractFromVideoPage(context, page, videoUrl, options) {
  const networkCandidates = [];
  const onRequest = (request) => {
    const requestUrl = request.url();
    if (isMp4Url(requestUrl)) {
      const candidate = candidateFromUrl(requestUrl, { source: 'cdp-request', baseUrl: videoUrl });
      if (candidate) networkCandidates.push(candidate);
    }
  };
  const onResponse = async (response) => {
    const responseUrl = response.url();
    const contentType = response.headers()['content-type'] || '';
    if (isMp4Url(responseUrl) || /video\/mp4/i.test(contentType)) {
      const candidate = candidateFromUrl(responseUrl, {
        source: 'cdp-response',
        baseUrl: videoUrl,
        contentType,
      });
      if (candidate) networkCandidates.push(candidate);
    }
  };
  page.on('request', onRequest);
  page.on('response', onResponse);
  try {
    await navigateWithRetry(page, videoUrl, options, 'video page');
    const [domCandidates, embeddedCandidates] = await Promise.all([
      extractDomCandidates(page),
      extractEmbeddedCandidates(page),
    ]);
    const redirectCandidates = domCandidates
      .filter((candidate) => !isMp4Url(candidate.url))
      .map((candidate) => resolveRedirectCandidate(context.request, candidate, options));
    const resolved = await Promise.all(redirectCandidates);
    const allCandidates = [
      ...domCandidates.filter((candidate) => isMp4Url(candidate.url)),
      ...embeddedCandidates,
      ...networkCandidates,
      ...resolved.filter(Boolean),
    ];
    const best = selectBestResolution(allCandidates);
    return {
      url: videoUrl,
      candidates: best,
      count: allCandidates.length,
    };
  } finally {
    page.off('request', onRequest);
    page.off('response', onResponse);
  }
}

async function mapWithConcurrency(items, concurrency, worker) {
  const results = [];
  let nextIndex = 0;
  async function runWorker() {
    while (true) {
      const index = nextIndex;
      nextIndex += 1;
      if (index >= items.length) return;
      results[index] = await worker(items[index], index);
    }
  }
  await Promise.all(Array.from({ length: Math.min(concurrency, items.length) }, runWorker));
  return results;
}

function toNetscapeCookieLine(cookie) {
  const domain = cookie.domain || new URL(cookie.url).hostname;
  const includeSubdomains = domain.startsWith('.') ? 'TRUE' : 'FALSE';
  return [
    domain,
    includeSubdomains,
    cookie.path || '/',
    cookie.secure ? 'TRUE' : 'FALSE',
    cookie.expires && cookie.expires > 0 ? Math.floor(cookie.expires) : '0',
    cookie.name,
    cookie.value,
  ].join('\t');
}

function powerShellQuote(value) {
  return `'${String(value).replace(/'/g, "''")}'`;
}

function generatePowerShellRunner(folderName, linksFileName, cookieFileName) {
  const destination = `D:\\Downloads\\${folderName}`;
  return `# Generated by scripts/video-crawler.js
$ErrorActionPreference = 'Stop'

$destination = ${powerShellQuote(destination)}
$linksFile = Join-Path $PSScriptRoot ${powerShellQuote(linksFileName)}
$cookieFile = Join-Path $PSScriptRoot ${powerShellQuote(cookieFileName)}

New-Item -ItemType Directory -Force -Path $destination | Out-Null
if (-not (Get-Command aria2c -ErrorAction SilentlyContinue)) {
    throw 'aria2c was not found on PATH. Install aria2c before running this script.'
}
if (-not (Test-Path -LiteralPath $linksFile)) {
    throw "Link file was not found: $linksFile"
}

$ariaArgs = @(
    '--input-file', $linksFile,
    '--dir', $destination,
    '--continue=true',
    '--allow-overwrite=false',
    '--auto-file-renaming=false',
    '--max-concurrent-downloads=3',
    '--max-connection-per-server=8',
    '--split=8',
    '--summary-interval=10',
    '--console-log-level=notice'
)
if (Test-Path -LiteralPath $cookieFile) {
    $ariaArgs += @('--load-cookies', $cookieFile)
}

& aria2c @ariaArgs
if ($LASTEXITCODE -ne 0) {
    throw "aria2c failed with exit code $LASTEXITCODE"
}
`;
}

async function writeArtifacts(context, folderName, results, outputDir) {
  const profileDir = path.join(outputDir, folderName);
  await fsp.mkdir(profileDir, { recursive: true });
  const links = [...new Set(results.flatMap((result) => result.candidates.map((candidate) => candidate.url)))];
  const linksFileName = `${folderName}_mp4_links.txt`;
  const linksPath = path.join(profileDir, linksFileName);
  await fsp.writeFile(linksPath, `${links.join('\r\n')}${links.length ? '\r\n' : ''}`, 'utf8');

  const cookies = await context.cookies();
  const cookieFileName = `${folderName}.cookies.txt`;
  const cookiePath = path.join(profileDir, cookieFileName);
  const cookieLines = [
    '# Netscape HTTP Cookie File',
    ...cookies.map(toNetscapeCookieLine),
  ];
  await fsp.writeFile(cookiePath, `${cookieLines.join('\r\n')}\r\n`, 'utf8');

  const runnerPath = path.join(profileDir, 'download_all.ps1');
  await fsp.writeFile(
    runnerPath,
    generatePowerShellRunner(folderName, linksFileName, cookieFileName),
    'utf8',
  );
  return { profileDir, linksPath, runnerPath, linkCount: links.length };
}

async function main() {
  const options = parseArguments(process.argv.slice(2));
  const { browser, context, connectedOverCdp } = await connectToBrowser(options);
  const listingPage = await context.newPage();
  listingPage.setDefaultTimeout(options.timeout);
  const videoPages = [];
  try {
    await navigateWithRetry(listingPage, options.url, options, 'starting URL');
    const folderName = await extractHeading(listingPage);
    log(`Using output folder name: ${folderName}`);
    const discoveredVideoPages = await discoverVideoPages(listingPage, options.url, options);
    log(`Discovered ${discoveredVideoPages.length} unique video pages`);

    const results = await mapWithConcurrency(
      discoveredVideoPages,
      options.concurrency,
      async (videoUrl, index) => {
        const page = await context.newPage();
        page.setDefaultTimeout(options.timeout);
        videoPages.push(page);
        await sleep(index === 0 ? 0 : randomBetween(options.jitterMin, options.jitterMax));
        try {
          const result = await extractFromVideoPage(context, page, videoUrl, options);
          log(`Video ${index + 1}/${discoveredVideoPages.length}: ${result.candidates.length} best link(s)`);
          return result;
        } catch (pageError) {
          error(`Failed video page ${videoUrl}: ${pageError.message}`);
          return { url: videoUrl, candidates: [], count: 0, error: pageError.message };
        } finally {
          await page.close().catch(() => {});
        }
      },
    );
    const artifacts = await writeArtifacts(context, folderName, results, options.outputDir);
    log(`Wrote ${artifacts.linkCount} links to ${artifacts.linksPath}`);
    log(`Wrote PowerShell runner to ${artifacts.runnerPath}`);
    if (connectedOverCdp) {
      log('Leaving the attached Chrome session open.');
    }
  } finally {
    await listingPage.close().catch(() => {});
    for (const page of videoPages) {
      await page.close().catch(() => {});
    }
    if (!connectedOverCdp) {
      await browser.close().catch(() => {});
    }
  }
}

main().catch((runError) => {
  error(runError.stack || runError.message);
  process.exitCode = 1;
});
