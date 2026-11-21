# Rebuild the ## VirusTotal section on a GitHub Release from current asset files.
# Call after VirusTotal upload so hashes are indexed. Safe for override_existing_release
# republishes - always replaces any prior VirusTotal block with links for the files on disk.
#
# Requires: gh CLI, GH_TOKEN with contents:write

param(
	[string]$Tag = "",

	[string]$AssetRoot = ""
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Get-NvmVirusTotalLinkLabel {
	param(
		[Parameter(Mandatory = $true)]
		[string]$FileName,

		[Parameter(Mandatory = $true)]
		[string]$VersionLabel
	)

	$name = [System.IO.Path]::GetFileName($FileName)
	$arch = "x64"
	if ($name -match '(?i)arm64') {
		$arch = "arm64"
	}
	elseif ($name -match '(?i)amd64') {
		$arch = "amd64"
	}
	elseif ($name -match '(?i)x86(?!_)') {
		$arch = "x86"
	}
	elseif ($name -match '(?i)x64') {
		$arch = "x64"
	}

	if ($name -match '(?i)-sync\.exe$') {
		return "NVM for Windows v$VersionLabel Sync Tool $arch Virus Report"
	}
	if ($name -match '(?i)-setup\.exe$') {
		return "NVM for Windows v$VersionLabel $arch Virus Report"
	}
	return "NVM for Windows v$VersionLabel $arch Virus Report ($name)"
}

# Dot-sourceable for unit tests (function above only).
if ($MyInvocation.InvocationName -eq '.') {
	return
}

if ([string]::IsNullOrWhiteSpace($Tag)) {
	throw "Tag is required"
}
if (-not (Test-Path -LiteralPath $AssetRoot -PathType Container)) {
	throw "AssetRoot not found: $AssetRoot"
}

$versionLabel = $Tag.Trim()
if ($versionLabel.StartsWith("v") -or $versionLabel.StartsWith("V")) {
	$versionLabel = $versionLabel.Substring(1)
}

$exes = @(
	Get-ChildItem -LiteralPath $AssetRoot -Recurse -File -Filter *.exe |
		Sort-Object Name, FullName
)
if ($exes.Count -eq 0) {
	throw "No .exe files under $AssetRoot"
}

$bullets = New-Object System.Collections.Generic.List[string]
foreach ($exe in $exes) {
	$hash = (Get-FileHash -LiteralPath $exe.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
	$url = "https://www.virustotal.com/gui/file/$hash"
	$label = Get-NvmVirusTotalLinkLabel -FileName $exe.Name -VersionLabel $versionLabel
	$bullets.Add("- [$label]($url)")
	Write-Host ("VirusTotal link -> {0} => {1}" -f $label, $url)
}

$section = @(
	"## VirusTotal",
	"",
	"These links open **antivirus scan reports** on VirusTotal. They are **not downloads** - use **Assets** below for installers and sync tools.",
	"",
	($bullets -join "`n")
) -join "`n"

$view = gh release view $Tag --json body | ConvertFrom-Json
if ($LASTEXITCODE -ne 0) {
	throw "gh release view $Tag failed"
}
$body = [string]$view.body
if ($null -eq $body) {
	$body = ""
}
# Normalize newlines so override/replace is deterministic on Windows runners.
$body = $body -replace "`r`n", "`n" -replace "`r", "`n"

# Drop any existing VirusTotal section (ours or crazy-max leftovers).
$body = [regex]::Replace(
	$body,
	'(?ms)^## VirusTotal\n(?:.*?)(?=^## |\n?> \[!IMPORTANT\]|\z)',
	"",
	1
)
$body = [regex]::Replace(
	$body,
	'(?m)\n*🛡 \[VirusTotal GitHub Action\][^\n]*(?:\n \* \[`[^\n]+)*',
	""
)
$body = [regex]::Replace(
	$body,
	'(?is)\n*<details>\n?\s*<summary>\s*🛡 VirusTotal analysis.*?</details>',
	""
)
$body = $body.TrimEnd() + "`n"

$importantMarker = "> [!IMPORTANT]"
$idx = $body.IndexOf($importantMarker)
if ($idx -ge 0) {
	$before = $body.Substring(0, $idx).TrimEnd()
	$after = $body.Substring($idx).TrimStart("`n")
	$body = $before + "`n`n" + $section + "`n`n" + $after
}
else {
	$body = $body.TrimEnd() + "`n`n" + $section + "`n"
}
if (-not $body.EndsWith("`n")) {
	$body += "`n"
}

$notesFile = Join-Path ([System.IO.Path]::GetTempPath()) ("nvm-vt-notes-{0}.md" -f [guid]::NewGuid().ToString("n"))
try {
	[System.IO.File]::WriteAllText($notesFile, $body, (New-Object System.Text.UTF8Encoding $false))
	gh release edit $Tag --notes-file $notesFile
	if ($LASTEXITCODE -ne 0) {
		throw "gh release edit $Tag failed"
	}
	Write-Host ("Updated release {0} VirusTotal section ({1} asset(s))." -f $Tag, $exes.Count)
}
finally {
	if (Test-Path -LiteralPath $notesFile) {
		Remove-Item -LiteralPath $notesFile -Force -ErrorAction SilentlyContinue
	}
}
