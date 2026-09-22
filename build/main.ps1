param(
	[ValidateSet("amd64", "arm64")]
	[string]$Architecture = "",
	[ValidateSet("All", "Cli", "Shims", "Sync")]
	[string]$Component = "All",
	[string]$BinRoot = "",
	[switch]$SkipInstaller,
	[switch]$DownloadSync,
	[string]$SyncReleaseTag = "",
	[string]$SyncReleaseRepo = "nvm-windows/nvm",
	[string]$Hotfix = "",
	[string]$Version = ""
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot "common.ps1")

if ([string]::IsNullOrWhiteSpace($Architecture)) {
	$Architecture = Resolve-NvmHostArchitecture
}

# Read base from on-disk manifest only (ignore leftover NVM_CLI_VERSION).
$manifestPath = Get-NvmCliManifestPath
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
	throw "CLI manifest not found: $manifestPath"
}
$base = [string](Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json).version
if ([string]::IsNullOrWhiteSpace($base)) {
	throw "CLI manifest does not define version: $manifestPath"
}

$hotfixSet = -not [string]::IsNullOrWhiteSpace($Hotfix)
$versionSet = -not [string]::IsNullOrWhiteSpace($Version)
if ($hotfixSet -and $versionSet) {
	throw "Hotfix and Version are mutually exclusive; set only one."
}

if ($versionSet) {
	$effective = $Version.Trim()
}
elseif ($hotfixSet) {
	$effective = Resolve-NvmHotfixVersion -BaseVersion $base -Hotfix $Hotfix
}
else {
	$effective = $base
}

$priorEnvVersion = [Environment]::GetEnvironmentVariable("NVM_CLI_VERSION")
$manifestStamped = $false
if ($effective -ne $base) {
	Set-NvmCliManifestVersion -Version $effective
	$manifestStamped = $true
	if ($versionSet) {
		Write-Host ("Version override -> {0} (base {1})" -f $effective, $base)
	}
	else {
		Write-Host ("Prerelease stamp -> {0} (base {1})" -f $effective, $base)
	}
}
$env:NVM_CLI_VERSION = $effective

try {
	$ctx = Initialize-NvmBuildContext -BinRoot $BinRoot
	$stepRoot = Join-Path $PSScriptRoot "steps"
	$commonArgs = @{
		Architecture = $Architecture
		BinRoot      = $ctx.BinRoot
	}
	$syncArgs = @{
		Architecture    = $Architecture
		BinRoot         = $ctx.BinRoot
		SyncReleaseTag  = $SyncReleaseTag
		SyncReleaseRepo = $SyncReleaseRepo
	}
	if ($DownloadSync) {
		$syncArgs["DownloadSync"] = $true
	}

	Write-Host "Community build"
	Write-Host "  RepoRoot         -> $($ctx.RepoRoot)"
	Write-Host "  BinRoot          -> $($ctx.BinRoot)"
	Write-Host "  Architecture     -> $Architecture"
	Write-Host "  Component        -> $Component"
	Write-Host "  SkipInstaller    -> $SkipInstaller"
	Write-Host "  DownloadSync     -> $DownloadSync"
	if ($DownloadSync) {
		Write-Host "  SyncReleaseTag   -> $(if ([string]::IsNullOrWhiteSpace($SyncReleaseTag)) { '(from CLI manifest)' } else { $SyncReleaseTag })"
		Write-Host "  SyncReleaseRepo  -> $SyncReleaseRepo"
	}
	if ($hotfixSet) {
		Write-Host "  Prerelease       -> $Hotfix"
	}
	if ($versionSet) {
		Write-Host "  Version          -> $Version"
	}
	Write-Host "  CLI version      -> $($ctx.CliVersion)"
	Write-Host "  Signing          -> Authenticode via Artifact Signing (exes + NVMWindows.Events.dll)"

	switch ($Component) {
		"All" {
			& (Join-Path $stepRoot "Build-Cli.ps1") @commonArgs
			& (Join-Path $stepRoot "Build-EventProvider.ps1") @commonArgs
			& (Join-Path $stepRoot "Build-Shims.ps1") @commonArgs
			& (Join-Path $stepRoot "Build-Sync.ps1") @syncArgs
		}
		"Cli" {
			& (Join-Path $stepRoot "Build-Cli.ps1") @commonArgs
			& (Join-Path $stepRoot "Build-EventProvider.ps1") @commonArgs
		}
		"Shims" {
			& (Join-Path $stepRoot "Build-Shims.ps1") @commonArgs
		}
		"Sync" {
			& (Join-Path $stepRoot "Build-Sync.ps1") @syncArgs
		}
	}

	$expected = Get-NvmExpectedExePaths -BinRoot $ctx.BinRoot -Component $Component
	Write-NvmPayloadSummary -Paths $expected -Title "Executables" -DisplayRoot $ctx.BinRoot -SkipJobSummary

	if ($Component -eq "All" -or $Component -eq "Cli") {
		$eventAssets = Get-NvmExpectedEventProviderPaths -BinRoot $ctx.BinRoot
		Write-NvmPayloadSummary -Paths $eventAssets -Title "Event provider" -DisplayRoot $ctx.BinRoot -SkipJobSummary
	}

	if ($Component -ne "All") {
		Write-Host "Skipping Inno Setup (requires -Component All; got $Component)." -ForegroundColor Yellow
	}
	elseif ($SkipInstaller) {
		Write-Host "Skipping Inno Setup (-SkipInstaller)." -ForegroundColor Yellow
	}
	else {
		& (Join-Path $stepRoot "Build-Installer.ps1") @commonArgs
		$setup = Get-NvmInstallerSetupPath -Version $ctx.CliVersion -Architecture $Architecture -DistRoot $ctx.DistRoot
		Write-NvmPayloadSummary -Paths @($setup) -Title "Installer" -DisplayRoot $ctx.RepoRoot
	}

	Write-Host "Build complete ($Component)."
}
finally {
	if ($manifestStamped) {
		Set-NvmCliManifestVersion -Version $base
	}
	if ($null -eq $priorEnvVersion -or $priorEnvVersion -eq "") {
		Remove-Item Env:NVM_CLI_VERSION -ErrorAction SilentlyContinue
	}
	else {
		$env:NVM_CLI_VERSION = $priorEnvVersion
	}
}
