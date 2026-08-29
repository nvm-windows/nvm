param(
	[ValidateSet("amd64", "arm64")]
	[string]$Architecture = "amd64",
	[string]$BinRoot = "",
	[switch]$DownloadSync,
	[string]$SyncReleaseTag = "",
	[string]$SyncReleaseRepo = "nvm-windows/nvm"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot "..\common.ps1")
$ctx = Initialize-NvmBuildContext -BinRoot $BinRoot

$syncRoot = Join-Path $ctx.RepoRoot "sync"
$syncSrcRoot = Join-Path $syncRoot "src"
$goModPath = Join-Path $syncSrcRoot "go.mod"
$defaultSyncExe = Join-Path (Get-NvmDefaultBinRoot) "utils\sync.exe"
$syncExePath = Join-Path $ctx.BinRoot "utils\sync.exe"
$hasSyncSource = (Test-Path -LiteralPath $syncSrcRoot -PathType Container) -and (Test-Path -LiteralPath $goModPath -PathType Leaf)

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $defaultSyncExe) | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $syncExePath) | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ctx.BinRoot ".sync") | Out-Null

function Ensure-GoWinres {
	$cmd = Get-Command go-winres -ErrorAction SilentlyContinue
	if ($null -ne $cmd) {
		Write-Host "go-winres -> $($cmd.Source)"
		return
	}
	Write-Host "Installing go-winres..."
	& go install github.com/tc-hib/go-winres@latest
	if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
		throw "go install go-winres failed with exit code $LASTEXITCODE"
	}
	$cmd = Get-Command go-winres -ErrorAction SilentlyContinue
	if ($null -eq $cmd) {
		throw "go-winres not on PATH after install (ensure GOBIN/GOPATH/bin is on PATH)"
	}
	Write-Host "go-winres -> $($cmd.Source)"
}

# Shared sync go.mod points mirrorauth/idp at certified/enhanced. Community tree
# has stub mirrorauth only — rewrite for this build, restore after.
function Use-CommunitySyncGoMod {
	param([string]$Path)

	$utf8 = New-Object System.Text.UTF8Encoding $false
	$raw = [System.IO.File]::ReadAllText($Path, $utf8)
	$updated = $raw
	$updated = $updated -replace '(replace\s+common/mirrorauth\s+v1\.0\.0\s+=>\s+)\S+', '${1}../../common/mirrorauth'
	$updated = [regex]::Replace($updated, '(?m)^replace\s+common/idp\s+v1\.0\.0\s+=>\s+\S+\r?\n', '')
	$updated = [regex]::Replace($updated, '(?m)^\tcommon/idp v1\.0\.0(?: // indirect)?\r?\n', '')
	if ($updated -ne $raw) {
		[System.IO.File]::WriteAllText($Path, $updated, $utf8)
		Write-Host "Rewrote sync go.mod for community (stub mirrorauth, no enhanced/idp)"
	}
	return $raw
}

function Get-NvmSyncReleaseTag {
	param(
		[string]$Tag,
		[string]$Version
	)
	$t = $Tag.Trim()
	if (-not [string]::IsNullOrWhiteSpace($t)) {
		if ($t.StartsWith("v", [System.StringComparison]::OrdinalIgnoreCase)) {
			return $t
		}
		return "v$t"
	}
	$v = $Version.Trim()
	if ([string]::IsNullOrWhiteSpace($v)) {
		throw "CLI version is empty; cannot resolve sync release tag"
	}
	if ($v.StartsWith("v", [System.StringComparison]::OrdinalIgnoreCase)) {
		return $v
	}
	return "v$v"
}

function Install-NvmSyncFromRelease {
	param(
		[string]$Architecture,
		[string]$Destination,
		[string]$Repo,
		[string]$Tag,
		[string]$Version
	)

	$releaseTag = Get-NvmSyncReleaseTag -Tag $Tag -Version $Version
	$assetVersion = $releaseTag.TrimStart("v", "V")
	$assetName = Get-NvmSyncReleaseAssetName -Version $assetVersion -Architecture $Architecture
	$uri = "https://github.com/{0}/releases/download/{1}/{2}" -f $Repo.Trim(), $releaseTag, $assetName
	$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("nvm-sync-download-{0}-{1}.exe" -f $Architecture, [guid]::NewGuid().ToString("n"))

	Write-Host "Downloading prebuilt sync.exe"
	Write-Host "  Repo   -> $Repo"
	Write-Host "  Tag    -> $releaseTag"
	Write-Host "  Asset  -> $assetName"
	Write-Host "  URL    -> $uri"

	try {
		Invoke-WebRequest -Uri $uri -OutFile $tmp -UseBasicParsing
	}
	catch {
		throw @"
Failed to download sync.exe from $uri
$($_.Exception.Message)

Use a published community release that includes nvm-<version>-<arch>-sync.exe,
or pass -SyncReleaseTag / -SyncReleaseRepo. Sync source is private — compile only with maintainer access.
"@
	}

	if (-not (Test-Path -LiteralPath $tmp -PathType Leaf) -or ((Get-Item -LiteralPath $tmp).Length -le 0)) {
		throw "Downloaded sync asset is missing or empty: $tmp"
	}

	New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
	Copy-Item -LiteralPath $tmp -Destination $Destination -Force
	Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
	Assert-NvmFile -Path $Destination -Label "sync.exe (downloaded)"
	Write-Host "Sync ready (downloaded) -> $Destination"
	return $Destination
}

function Build-NvmSyncFromSource {
	param(
		[string]$Architecture,
		[string]$SyncSrcRoot,
		[string]$GoModPath,
		[string]$DefaultSyncExe,
		[string]$SyncExePath
	)

	$originalGoos = $env:GOOS
	$originalGoarch = $env:GOARCH
	$originalGowork = $env:GOWORK
	$originalGoMod = $null
	$srcPushed = $false

	Write-Host "Building sync.exe -> $SyncExePath (no worker DLLs)"
	try {
		Ensure-GoWinres
		$originalGoMod = Use-CommunitySyncGoMod -Path $GoModPath

		$env:GOWORK = "off"
		$env:GOOS = "windows"
		$env:GOARCH = if ($Architecture -eq "arm64") { "arm64" } else { "amd64" }

		Push-Location $SyncSrcRoot
		$srcPushed = $true
		& qgo exec prebuild
		if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
			throw "sync src prebuild failed with exit code $LASTEXITCODE"
		}

		& qgo build --no-cache
		if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
			throw "sync src build failed with exit code $LASTEXITCODE"
		}
	}
	finally {
		if ($srcPushed) {
			Pop-Location
		}
		if ($null -ne $originalGoMod) {
			$utf8 = New-Object System.Text.UTF8Encoding $false
			[System.IO.File]::WriteAllText($GoModPath, $originalGoMod, $utf8)
			Write-Host "Restored sync go.mod"
		}
		$env:GOOS = $originalGoos
		$env:GOARCH = $originalGoarch
		$env:GOWORK = $originalGowork
	}

	if (-not (Test-Path -LiteralPath $DefaultSyncExe -PathType Leaf)) {
		throw "sync.exe was not generated at $DefaultSyncExe"
	}

	if ([System.IO.Path]::GetFullPath($DefaultSyncExe) -ne [System.IO.Path]::GetFullPath($SyncExePath)) {
		Copy-Item -LiteralPath $DefaultSyncExe -Destination $SyncExePath -Force
		Write-Host "Copied sync.exe -> $SyncExePath"
	}

	Assert-NvmFile -Path $SyncExePath -Label "sync.exe"
	Write-Host "Sync ready -> $SyncExePath"
	Write-Host "Worker DLLs skipped (published by certified release to assets.nvm-windows.com)." -ForegroundColor Yellow
	return $SyncExePath
}

if ($DownloadSync) {
	Install-NvmSyncFromRelease `
		-Architecture $Architecture `
		-Destination $syncExePath `
		-Repo $SyncReleaseRepo `
		-Tag $SyncReleaseTag `
		-Version $ctx.CliVersion | Out-Null

	if ([System.IO.Path]::GetFullPath($defaultSyncExe) -ne [System.IO.Path]::GetFullPath($syncExePath)) {
		Copy-Item -LiteralPath $syncExePath -Destination $defaultSyncExe -Force
	}
}
elseif ($hasSyncSource) {
	Build-NvmSyncFromSource `
		-Architecture $Architecture `
		-SyncSrcRoot $syncSrcRoot `
		-GoModPath $goModPath `
		-DefaultSyncExe $defaultSyncExe `
		-SyncExePath $syncExePath | Out-Null
}
else {
	throw @"
Sync source not found: $syncSrcRoot

The sync repository is private. Either:
  - Pass -DownloadSync to fetch nvm-<version>-<arch>-sync.exe from the GitHub Release, or
  - Build with maintainer access to the sync submodule.
"@
}

# Stage release-named copy under .dist for GHA upload (compiled or downloaded).
$staged = Get-NvmSyncReleaseAssetPath -Version $ctx.CliVersion -Architecture $Architecture -DistRoot $ctx.DistRoot
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $staged) | Out-Null
Copy-Item -LiteralPath $syncExePath -Destination $staged -Force
Write-Host "Staged release asset -> $staged"

return $syncExePath
