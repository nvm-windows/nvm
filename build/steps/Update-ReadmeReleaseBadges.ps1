# Refresh README download badges from GitHub Releases.
# - Prerelease badge -> newest published pre-release (tag link); HTML-commented when
#   it is not newer than the latest stable release
# - Stable badge     -> newest published non-prerelease (tag link)
#
# Requires: gh CLI, GH_TOKEN with contents:read (list releases).

param(
	[string]$Repository = $env:GITHUB_REPOSITORY,
	[string]$ReadmePath = "",
	[switch]$WhatIf
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if ([string]::IsNullOrWhiteSpace($Repository)) {
	throw "Repository is required (GITHUB_REPOSITORY or -Repository)."
}

if ([string]::IsNullOrWhiteSpace($ReadmePath)) {
	$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
	$ReadmePath = Join-Path $repoRoot "README.md"
}

if (-not (Test-Path -LiteralPath $ReadmePath -PathType Leaf)) {
	throw "README not found: $ReadmePath"
}

$markerStart = "<!-- nvm-readme-release-badges:start -->"
$markerEnd = "<!-- nvm-readme-release-badges:end -->"

function Invoke-GhJson {
	param(
		[Parameter(Mandatory = $true)]
		[string[]]$GhArgs
	)
	$prevEap = $ErrorActionPreference
	$ErrorActionPreference = "Continue"
	try {
		$text = (& gh @GhArgs --repo $Repository 2>&1 | Out-String).Trim()
		$code = $LASTEXITCODE
	}
	finally {
		$ErrorActionPreference = $prevEap
	}
	if ($code -ne 0) {
		throw "gh $($GhArgs -join ' ') failed ($code): $text"
	}
	if ([string]::IsNullOrWhiteSpace($text)) {
		return $null
	}
	return $text | ConvertFrom-Json
}

function Encode-ShieldsLabel {
	param([string]$Label)
	$encoded = [uri]::EscapeDataString($Label)
	return $encoded.Replace("+", "%20")
}

function Format-PrereleaseBadgeLabel {
	param([string]$Tag)
	$version = $Tag.Trim()
	if ($version.StartsWith("v", [System.StringComparison]::OrdinalIgnoreCase)) {
		$version = $version.Substring(1)
	}
	if ($version -match '^(\d+)\.(\d+)\.(\d+)-rc\.(\d+)$') {
		return "Try v$($matches[1]) RC $($matches[4])"
	}
	return "Try v$version"
}

function Format-StableBadgeLabel {
	param([string]$Tag)
	$version = $Tag.Trim()
	if ($version.StartsWith("v", [System.StringComparison]::OrdinalIgnoreCase)) {
		$version = $version.Substring(1)
	}
	return "Latest Stable-v$version"
}

function Get-ReleasePageUrl {
	param([string]$Tag)
	return "https://github.com/$Repository/releases/tag/$Tag"
}

function Build-PrereleaseBadgeMarkdown {
	param(
		[string]$Tag,
		[string]$Label
	)
	$shields = "https://img.shields.io/badge/-$(Encode-ShieldsLabel $Label)-%2322A6F2"
	$url = Get-ReleasePageUrl -Tag $Tag
	return "[![$Label]($shields)]($url)"
}

function Build-StableBadgeMarkdown {
	param(
		[string]$Tag,
		[string]$Label
	)
	$shields = "https://img.shields.io/badge/$(Encode-ShieldsLabel $Label)-1?style=social"
	$url = Get-ReleasePageUrl -Tag $Tag
	return "[![$Label]($shields)]($url)"
}

function Get-SemVerParts {
	param([string]$Tag)
	$version = $Tag.Trim()
	if ($version.StartsWith("v", [System.StringComparison]::OrdinalIgnoreCase)) {
		$version = $version.Substring(1)
	}
	if ($version -notmatch '^(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z.-]+))?(?:\+([0-9A-Za-z.-]+))?$') {
		throw "Unsupported release tag for version compare: $Tag"
	}
	$prerelease = $null
	if ($matches.Count -ge 5 -and -not [string]::IsNullOrWhiteSpace($matches[4])) {
		$prerelease = $matches[4]
	}
	return [pscustomobject]@{
		Major      = [int]$matches[1]
		Minor      = [int]$matches[2]
		Patch      = [int]$matches[3]
		Prerelease = $prerelease
	}
}

function Compare-PrereleaseIdentifiers {
	param(
		[string]$Left,
		[string]$Right
	)
	$leftParts = if ([string]::IsNullOrWhiteSpace($Left)) { @() } else { $Left.Split('.') }
	$rightParts = if ([string]::IsNullOrWhiteSpace($Right)) { @() } else { $Right.Split('.') }
	$max = [Math]::Max($leftParts.Count, $rightParts.Count)
	for ($i = 0; $i -lt $max; $i++) {
		$leftPart = if ($i -lt $leftParts.Count) { $leftParts[$i] } else { $null }
		$rightPart = if ($i -lt $rightParts.Count) { $rightParts[$i] } else { $null }
		if ($null -eq $leftPart) { return -1 }
		if ($null -eq $rightPart) { return 1 }

		$leftNumeric = 0
		$rightNumeric = 0
		$leftIsNumeric = [int]::TryParse($leftPart, [ref]$leftNumeric)
		$rightIsNumeric = [int]::TryParse($rightPart, [ref]$rightNumeric)
		if ($leftIsNumeric -and $rightIsNumeric) {
			if ($leftNumeric -lt $rightNumeric) { return -1 }
			if ($leftNumeric -gt $rightNumeric) { return 1 }
			continue
		}
		if ($leftIsNumeric -and -not $rightIsNumeric) { return -1 }
		if (-not $leftIsNumeric -and $rightIsNumeric) { return 1 }
		$cmp = [string]::Compare($leftPart, $rightPart, [System.StringComparison]::OrdinalIgnoreCase)
		if ($cmp -ne 0) { return $cmp }
	}
	return 0
}

function Compare-ReleaseTags {
	param(
		[string]$LeftTag,
		[string]$RightTag
	)
	$leftVersion = Get-SemVerParts -Tag $LeftTag
	$rightVersion = Get-SemVerParts -Tag $RightTag
	if ($leftVersion.Major -ne $rightVersion.Major) { return [Math]::Sign($leftVersion.Major - $rightVersion.Major) }
	if ($leftVersion.Minor -ne $rightVersion.Minor) { return [Math]::Sign($leftVersion.Minor - $rightVersion.Minor) }
	if ($leftVersion.Patch -ne $rightVersion.Patch) { return [Math]::Sign($leftVersion.Patch - $rightVersion.Patch) }
	$leftPre = [string]$leftVersion.Prerelease
	$rightPre = [string]$rightVersion.Prerelease
	if ([string]::IsNullOrWhiteSpace($leftPre) -and [string]::IsNullOrWhiteSpace($rightPre)) { return 0 }
	if ([string]::IsNullOrWhiteSpace($leftPre)) { return 1 }
	if ([string]::IsNullOrWhiteSpace($rightPre)) { return -1 }
	return Compare-PrereleaseIdentifiers -Left $leftPre -Right $rightPre
}

function Test-PrereleaseIsNewerThanStable {
	param(
		[string]$PrereleaseTag,
		[string]$StableTag
	)
	return (Compare-ReleaseTags -LeftTag $PrereleaseTag -RightTag $StableTag) -gt 0
}

function Get-LatestPublishedPrerelease {
	$releases = Invoke-GhJson -GhArgs @(
		"release", "list",
		"--limit", "100",
		"--json", "tagName,isPrerelease,isDraft,publishedAt"
	)
	if ($null -eq $releases) {
		return $null
	}
	$list = @($releases) | Where-Object {
		-not $_.isDraft -and $_.isPrerelease -and -not [string]::IsNullOrWhiteSpace([string]$_.tagName)
	}
	if ($list.Count -eq 0) {
		return $null
	}
	return $list[0]
}

function Get-LatestPublishedStableRelease {
	$releases = Invoke-GhJson -GhArgs @(
		"release", "list",
		"--limit", "100",
		"--exclude-pre-releases",
		"--json", "tagName,isDraft,publishedAt"
	)
	if ($null -eq $releases) {
		return $null
	}
	$list = @($releases) | Where-Object {
		-not $_.isDraft -and -not [string]::IsNullOrWhiteSpace([string]$_.tagName)
	}
	if ($list.Count -eq 0) {
		return $null
	}
	return $list[0]
}

$prerelease = Get-LatestPublishedPrerelease
$stable = Get-LatestPublishedStableRelease

if ($null -eq $prerelease -and $null -eq $stable) {
	Write-Host "No published releases found; README unchanged."
	exit 0
}

$badgeParts = @()
if ($null -ne $prerelease) {
	$preTag = [string]$prerelease.tagName
	$preLabel = Format-PrereleaseBadgeLabel -Tag $preTag
	$tryBadge = Build-PrereleaseBadgeMarkdown -Tag $preTag -Label $preLabel
	$showTry = $true
	if ($null -ne $stable) {
		$stableTag = [string]$stable.tagName
		$showTry = Test-PrereleaseIsNewerThanStable -PrereleaseTag $preTag -StableTag $stableTag
	}
	if ($showTry) {
		$badgeParts += $tryBadge
		Write-Host "Prerelease badge -> $preLabel ($preTag) [visible]"
	}
	else {
		$badgeParts += "<!-- $tryBadge -->"
		Write-Host "Prerelease badge -> $preLabel ($preTag) [commented: not newer than stable]"
	}
}
else {
	Write-Warning "No published prerelease found; prerelease badge will be omitted."
}

if ($null -ne $stable) {
	$stableTag = [string]$stable.tagName
	$stableLabel = Format-StableBadgeLabel -Tag $stableTag
	$badgeParts += (Build-StableBadgeMarkdown -Tag $stableTag -Label $stableLabel)
	Write-Host "Stable badge -> $stableLabel ($stableTag)"
}
else {
	Write-Warning "No published stable release found; stable badge will be omitted."
}

if ($badgeParts.Count -eq 0) {
	Write-Host "Nothing to update."
	exit 0
}

$newInner = ($badgeParts -join " ")
# Newlines required: HTML comments glued to badge markdown break GitHub rendering
# (raw link text instead of images).
$newBlock = "$markerStart`n$newInner`n$markerEnd"

$readme = [System.IO.File]::ReadAllText($ReadmePath)
if ($readme -notmatch [regex]::Escape($markerStart) -or $readme -notmatch [regex]::Escape($markerEnd)) {
	throw "README is missing release badge markers ($markerStart ... $markerEnd)."
}

$pattern = "(?s)$([regex]::Escape($markerStart)).*?$([regex]::Escape($markerEnd))"
$updated = [regex]::Replace($readme, $pattern, $newBlock, 1)

if ($updated -eq $readme) {
	Write-Host "README badges already up to date."
	exit 0
}

if ($WhatIf) {
	Write-Host "WhatIf: would update README badges:"
	Write-Host $newInner
	exit 0
}

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($ReadmePath, $updated, $utf8NoBom)
Write-Host "Updated $ReadmePath"
