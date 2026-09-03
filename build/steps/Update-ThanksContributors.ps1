# Refresh THANKS.md contributor grid from git history on selected refs.
# GitHub's /contributors + contrib.rocks only see the default branch (v2 rewrite),
# so this walks commit authors on historical refs too (v1 master + current main).
#
# Requires: gh CLI, GH_TOKEN with contents:read.

param(
	[string]$Repository = $env:GITHUB_REPOSITORY,
	[string]$ThanksPath = "",
	[string[]]$Refs = @("master", "main"),
	[int]$AvatarSize = 64,
	[int]$Columns = 8,
	[switch]$WhatIf
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if ([string]::IsNullOrWhiteSpace($Repository)) {
	throw "Repository is required (GITHUB_REPOSITORY or -Repository)."
}

if ([string]::IsNullOrWhiteSpace($ThanksPath)) {
	$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
	$ThanksPath = Join-Path $repoRoot "THANKS.md"
}

if (-not (Test-Path -LiteralPath $ThanksPath -PathType Leaf)) {
	throw "THANKS.md not found: $ThanksPath"
}

$markerStart = "<!-- nvm-thanks-contributors:start -->"
$markerEnd = "<!-- nvm-thanks-contributors:end -->"

$excludedLogins = @(
	"github-actions[bot]",
	"dependabot[bot]",
	"dependabot-preview[bot]",
	"renovate[bot]",
	"imgbot[bot]",
	"weblate",
	"gitter-badger",
	"codetriage-readme-bot"
)

function Test-ExcludedLogin {
	param([string]$Login)
	if ([string]::IsNullOrWhiteSpace($Login)) {
		return $true
	}
	if ($Login -match '\[bot\]$') {
		return $true
	}
	foreach ($name in $excludedLogins) {
		if ([string]::Equals($Login, $name, [System.StringComparison]::OrdinalIgnoreCase)) {
			return $true
		}
	}
	return $false
}

function Invoke-GhApiJson {
	param(
		[Parameter(Mandatory = $true)]
		[string]$PathAndQuery
	)
	$prevEap = $ErrorActionPreference
	$ErrorActionPreference = "Continue"
	try {
		$text = (& gh api --paginate $PathAndQuery 2>&1 | Out-String).Trim()
		$code = $LASTEXITCODE
	}
	finally {
		$ErrorActionPreference = $prevEap
	}
	if ($code -ne 0) {
		throw "gh api $PathAndQuery failed ($code): $text"
	}
	if ([string]::IsNullOrWhiteSpace($text)) {
		return @()
	}
	$parsed = $text | ConvertFrom-Json
	return @($parsed)
}

function Get-LoginFromCommit {
	param($Commit)
	if ($null -ne $Commit.author -and -not [string]::IsNullOrWhiteSpace([string]$Commit.author.login)) {
		return [string]$Commit.author.login
	}
	$email = ""
	if ($null -ne $Commit.commit -and $null -ne $Commit.commit.author) {
		$email = [string]$Commit.commit.author.email
	}
	if ($email -match '^(?:\d+\+)?([^@]+)@users\.noreply\.github\.com$') {
		return $matches[1]
	}
	return ""
}

function Get-ContributorsFromRef {
	param([string]$RefName)
	$encodedRef = [uri]::EscapeDataString($RefName)
	$path = "repos/$Repository/commits?sha=$encodedRef&per_page=100"
	Write-Host "Fetching commits -> $RefName"
	return (Invoke-GhApiJson -PathAndQuery $path)
}

$seenShas = New-Object "System.Collections.Generic.HashSet[string]"
$counts = @{}
$htmlUrls = @{}
$avatarUrls = @{}

foreach ($refName in $Refs) {
	$commits = Get-ContributorsFromRef -RefName $refName
	Write-Host "  $($commits.Count) commit records"
	foreach ($commit in $commits) {
		$sha = [string]$commit.sha
		if ([string]::IsNullOrWhiteSpace($sha)) {
			continue
		}
		if (-not $seenShas.Add($sha)) {
			continue
		}
		$login = Get-LoginFromCommit -Commit $commit
		if (Test-ExcludedLogin -Login $login) {
			continue
		}
		if ($counts.ContainsKey($login)) {
			$counts[$login] = [int]$counts[$login] + 1
		}
		else {
			$counts[$login] = 1
		}
		if ($null -ne $commit.author) {
			if (-not [string]::IsNullOrWhiteSpace([string]$commit.author.html_url)) {
				$htmlUrls[$login] = [string]$commit.author.html_url
			}
			if (-not [string]::IsNullOrWhiteSpace([string]$commit.author.avatar_url)) {
				$avatarUrls[$login] = [string]$commit.author.avatar_url
			}
		}
	}
}

if ($counts.Count -eq 0) {
	throw "No contributors found for refs: $($Refs -join ', ')"
}

$ranked = $counts.Keys | Sort-Object {
	- [int]$counts[$_]
}, { $_.ToLowerInvariant() }

Write-Host "Contributors -> $($ranked.Count) (bots excluded)"

$cells = New-Object System.Collections.Generic.List[string]
foreach ($login in $ranked) {
	$url = if ($htmlUrls.ContainsKey($login)) { $htmlUrls[$login] } else { "https://github.com/$login" }
	$avatar = if ($avatarUrls.ContainsKey($login)) {
		$avatarUrls[$login]
	}
	else {
		"https://github.com/$login.png?size=$AvatarSize"
	}
	if ($avatar -notmatch '[\?&]s=') {
		$sep = if ($avatar.Contains("?")) { "&" } else { "?" }
		$avatar = "$avatar$sep" + "s=$AvatarSize"
	}
	$count = [int]$counts[$login]
	$escapedLogin = [System.Net.WebUtility]::HtmlEncode($login)
	$cells.Add(
		('<td align="center" valign="top" width="{0}%"><a href="{1}"><img src="{2}" width="{3}" height="{3}" alt="{4}" /><br /><sub><b>{4}</b></sub></a><br /><sub>{5}</sub></td>' -f `
			([int][Math]::Floor(100 / $Columns)), $url, $avatar, $AvatarSize, $escapedLogin, $count)
	)
}

$rowHtml = New-Object System.Collections.Generic.List[string]
$rowHtml.Add('<table>')
for ($i = 0; $i -lt $cells.Count; $i += $Columns) {
	$rowHtml.Add("<tr>")
	$end = [Math]::Min($i + $Columns, $cells.Count) - 1
	for ($j = $i; $j -le $end; $j++) {
		$rowHtml.Add($cells[$j])
	}
	$rowHtml.Add("</tr>")
}
$rowHtml.Add("</table>")

$listLines = New-Object System.Collections.Generic.List[string]
$rank = 1
foreach ($login in $ranked) {
	$url = if ($htmlUrls.ContainsKey($login)) { $htmlUrls[$login] } else { "https://github.com/$login" }
	$count = [int]$counts[$login]
	$listLines.Add("$rank. [@$login]($url) — $count")
	$rank += 1
}

$generated = @(
	"_Commit authors on ``master`` (v1) and ``main`` (v2), sorted by commit count. Bots omitted. Updated on each community release._"
	""
	($rowHtml -join "`n")
	""
	"<details>"
	"<summary>Ranked list</summary>"
	""
	($listLines -join "`n")
	""
	"</details>"
) -join "`n"

$newBlock = "$markerStart`n$generated`n$markerEnd"

$doc = [System.IO.File]::ReadAllText($ThanksPath)
if ($doc -notmatch [regex]::Escape($markerStart) -or $doc -notmatch [regex]::Escape($markerEnd)) {
	throw "THANKS.md is missing contributor markers ($markerStart ... $markerEnd)."
}

$pattern = "(?s)$([regex]::Escape($markerStart)).*?$([regex]::Escape($markerEnd))"
$rx = New-Object System.Text.RegularExpressions.Regex($pattern)
$safeBlock = $newBlock.Replace('$', '$$')
$updated = $rx.Replace($doc, $safeBlock, 1)

if ($updated -eq $doc) {
	Write-Host "THANKS.md contributors already up to date."
	exit 0
}

if ($WhatIf) {
	Write-Host "WhatIf: would write $($ranked.Count) contributors."
	Write-Host ($ranked | Select-Object -First 10 | ForEach-Object { "$_ $($counts[$_])" } | Out-String)
	exit 0
}

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($ThanksPath, $updated, $utf8NoBom)
Write-Host "Updated $ThanksPath"
