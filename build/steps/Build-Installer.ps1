param(
	[ValidateSet("amd64", "arm64")]
	[string]$Architecture = "amd64",
	[string]$BinRoot = ""
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot "..\common.ps1")
$ctx = Initialize-NvmBuildContext -BinRoot $BinRoot

$installerRoot = Join-Path $ctx.RepoRoot "installer"
$updaterScript = Join-Path $installerRoot "updater\build.ps1"
$bat = Join-Path $installerRoot "build-installer.bat"
$manifestPath = Get-NvmCliManifestPath

if (-not (Test-Path -LiteralPath $updaterScript -PathType Leaf)) {
	throw "Updater build script not found: $updaterScript"
}
if (-not (Test-Path -LiteralPath $bat -PathType Leaf)) {
	throw "Inno build script not found: $bat"
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$version = [string]$manifest.version
$aumid = [string]$manifest.appUserModelId
$appId = [string]$manifest.appId
if ([string]::IsNullOrWhiteSpace($version) -or [string]::IsNullOrWhiteSpace($aumid) -or [string]::IsNullOrWhiteSpace($appId)) {
	throw "installer manifest values (version, appUserModelId, appId) are required"
}

# Inno copies bin/.sync/* only when sync.exe exists; keep dir present, no DLLs.
New-Item -ItemType Directory -Force -Path (Join-Path $ctx.BinRoot ".sync") | Out-Null

Write-Host "Building updater..."
& $updaterScript -Architecture $Architecture
if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
	throw "updater build failed with exit code $LASTEXITCODE"
}
Assert-NvmFile -Path (Join-Path $installerRoot "updater\bin\nvm-upgrader.exe") -Label "nvm-upgrader.exe"

Write-Host "Building Inno Setup ($Architecture)..."
$prev = Get-Location
try {
	Set-Location $installerRoot
	& cmd /c ".\build-installer.bat $version $aumid $appId $Architecture"
	if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
		throw "build-installer.bat failed with exit code $LASTEXITCODE"
	}
}
finally {
	Set-Location $prev
}

$setup = Get-NvmInstallerSetupPath -Version $version -Architecture $Architecture -DistRoot $ctx.DistRoot
Assert-NvmFile -Path $setup -Label "Inno Setup installer"
Write-Host "Installer ready -> $setup"
return $setup
