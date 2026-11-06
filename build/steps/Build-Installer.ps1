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
# Prefer gate/hotfix stamp (NVM_CLI_VERSION / patched manifest) over raw file alone.
$version = $ctx.CliVersion
$aumid = [string]$manifest.appUserModelId
$appId = [string]$manifest.appId
if ([string]::IsNullOrWhiteSpace($version) -or [string]::IsNullOrWhiteSpace($aumid) -or [string]::IsNullOrWhiteSpace($appId)) {
	throw "installer manifest values (version, appUserModelId, appId) are required"
}

Write-Host "Installer version -> $version"

# Inno copies bin/.sync/* only when sync.exe exists; keep dir present, no DLLs.
New-Item -ItemType Directory -Force -Path (Join-Path $ctx.BinRoot ".sync") | Out-Null

# Pack-time malware seed into bin\utils so Inno harvests malware.db + head.cose.
# Live community feed GETs return 401 with temporary tokens; CI should set
# NVM_ACCESS_TOKEN (or NVM_LICENSE) so malware-refresh can authorize the CDN.
$utilsRoot = Join-Path $ctx.BinRoot "utils"
$malwareDbPath = Join-Path $utilsRoot "malware.db"
$malwareHeadPath = Join-Path $utilsRoot "head.cose"
$seedPresent = (Test-Path -LiteralPath $malwareDbPath -PathType Leaf) -and (Test-Path -LiteralPath $malwareHeadPath -PathType Leaf)
if (-not $seedPresent) {
	$syncExePath = Join-Path $utilsRoot "sync.exe"
	$token = [string]$env:NVM_ACCESS_TOKEN
	if ([string]::IsNullOrWhiteSpace($token)) {
		$token = [string]$env:NVM_LICENSE
	}
	if ((Test-Path -LiteralPath $syncExePath -PathType Leaf) -and -not [string]::IsNullOrWhiteSpace($token)) {
		Write-Host "Fetching malware.db seed via sync.exe malware-refresh (NVM_ACCESS_TOKEN/NVM_LICENSE set)"
		New-Item -ItemType Directory -Force -Path $utilsRoot | Out-Null
		$seedProc = Start-Process -FilePath $syncExePath -ArgumentList @("malware-refresh", "--root", $utilsRoot) -Wait -PassThru -NoNewWindow
		if ($null -ne $seedProc.ExitCode -and $seedProc.ExitCode -ne 0) {
			Write-Warning ("malware-refresh seed fetch exited {0}; installer will soft-continue without a shipped db" -f $seedProc.ExitCode)
		}
	}
	elseif (-not (Test-Path -LiteralPath $syncExePath -PathType Leaf)) {
		Write-Warning "sync.exe missing under bin\utils; cannot fetch malware.db seed"
	}
	else {
		Write-Warning "NVM_ACCESS_TOKEN/NVM_LICENSE unset; community malware.db seed skipped (CDN returns 401 for temporary tokens)"
	}
}
if ((Test-Path -LiteralPath $malwareDbPath -PathType Leaf) -and (Test-Path -LiteralPath $malwareHeadPath -PathType Leaf)) {
	Write-Host "Malware definition seed ready -> $malwareDbPath"
}
else {
	Write-Warning "Malware definition seed not present under bin\utils; setup may show NVM4117"
}

Write-Host "Building sparse identity package..."
$identityScript = Join-Path $PSScriptRoot "New-IdentityPackage.ps1"
if (Test-Path -LiteralPath $identityScript -PathType Leaf) {
	& $identityScript -Architecture $Architecture -BinRoot $ctx.BinRoot -Version $version
	$msix = Join-Path $ctx.BinRoot "identity\NVMWindows.msix"
	$signScript = Join-Path $PSScriptRoot "..\scripts\Sign-Executables.ps1"
	if ((Test-Path -LiteralPath $msix -PathType Leaf) -and (Test-Path -LiteralPath $signScript -PathType Leaf)) {
		try {
			& $signScript -Path @($msix)
			Write-Host "Signed identity package -> $msix"
		} catch {
			Write-Warning ("Identity .msix unsigned (signing skipped): {0}" -f $_.Exception.Message)
		}
	}
}

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
$archToken = Get-NvmReleaseArchToken -Architecture $Architecture
$newest = Get-ChildItem -LiteralPath $ctx.DistRoot -Filter ("nvm-{0}-{1}-setup*.exe" -f $version, $archToken) -ErrorAction SilentlyContinue |
	Sort-Object LastWriteTimeUtc -Descending |
	Select-Object -First 1
if ($null -ne $newest) {
	if ($newest.FullName -ne $setup) {
		Write-Warning ("Canonical setup was locked or stale. Newest build -> {0}" -f $newest.FullName)
		try {
			Copy-Item -LiteralPath $newest.FullName -Destination $setup -Force
			Write-Host "Replaced canonical setup -> $setup"
		}
		catch {
			Write-Warning ("Could not replace {0}. Run the timestamped file instead." -f $setup)
			$setup = $newest.FullName
		}
	}
}
Assert-NvmFile -Path $setup -Label "Inno Setup installer"
Write-Host "Installer ready -> $setup"
return $setup
