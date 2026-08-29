param(
	[ValidateSet("amd64", "arm64")]
	[string]$Architecture = "amd64",
	[string]$BinRoot = ""
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot "..\common.ps1")
$ctx = Initialize-NvmBuildContext -BinRoot $BinRoot

$shimBuildScript = Join-Path $ctx.RepoRoot "shim\build.ps1"
$rcEditBootstrapPath = Join-Path $ctx.RepoRoot "shim\scripts\.tools\rcedit-x64.exe"

if (-not (Test-Path -LiteralPath $shimBuildScript -PathType Leaf)) {
	throw "Shim build script not found: $shimBuildScript"
}

# Community shims: no enhanced/zig registry override (HKCU only).
if ($env:RCEDIT_PATH) {
	if (-not (Test-Path -LiteralPath $env:RCEDIT_PATH -PathType Leaf)) {
		throw "RCEDIT_PATH is set but missing: $($env:RCEDIT_PATH)"
	}
}
else {
	$rcEditDir = Split-Path -Parent $rcEditBootstrapPath
	New-Item -ItemType Directory -Force -Path $rcEditDir | Out-Null
	if (-not (Test-Path -LiteralPath $rcEditBootstrapPath -PathType Leaf)) {
		Write-Host "Downloading rcedit -> $rcEditBootstrapPath"
		Invoke-WebRequest -Uri "https://github.com/electron/rcedit/releases/download/v2.0.0/rcedit-x64.exe" -OutFile $rcEditBootstrapPath
	}
	$env:RCEDIT_PATH = $rcEditBootstrapPath
}

Write-Host "Building shims -> $($ctx.BinRoot)"
& $shimBuildScript `
	-OutputDir $ctx.BinRoot `
	-Architecture $Architecture `
	-Version $ctx.CliVersion
if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
	throw "Shim build failed with exit code $LASTEXITCODE"
}

$outputs = @(
	(Assert-NvmFile -Path (Join-Path $ctx.BinRoot ".shim\node.exe") -Label "node.exe"),
	(Assert-NvmFile -Path (Join-Path $ctx.BinRoot "utils\reshim.exe") -Label "reshim.exe"),
	(Assert-NvmFile -Path (Join-Path $ctx.BinRoot "utils\proxy.exe") -Label "proxy.exe")
)

Write-Host "Shims ready -> $($ctx.BinRoot)"
return $outputs
