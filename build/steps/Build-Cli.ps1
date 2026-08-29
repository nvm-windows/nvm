param(
	[ValidateSet("amd64", "arm64")]
	[string]$Architecture = "amd64",
	[string]$BinRoot = ""
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot "..\common.ps1")
$ctx = Initialize-NvmBuildContext -BinRoot $BinRoot

$cliSrc = Join-Path $ctx.RepoRoot "cli\src"
$defaultNvm = Join-Path (Get-NvmDefaultBinRoot) "nvm.exe"
$targetNvm = Join-Path $ctx.BinRoot "nvm.exe"

if (-not (Test-Path -LiteralPath $cliSrc -PathType Container)) {
	throw "CLI source not found: $cliSrc"
}

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

$originalGoos = $env:GOOS
$originalGoarch = $env:GOARCH
$originalGowork = $env:GOWORK
$pushed = $false

Write-Host "Building CLI -> $targetNvm"
try {
	Ensure-GoWinres
	$env:GOWORK = "off"
	$env:GOOS = "windows"
	$env:GOARCH = if ($Architecture -eq "arm64") { "arm64" } else { "amd64" }

	Push-Location $cliSrc
	$pushed = $true

	if (Test-Path -LiteralPath (Join-Path $cliSrc "winres\winres.json") -PathType Leaf) {
		& qgo exec prebuild
		if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
			throw "CLI prebuild failed with exit code $LASTEXITCODE"
		}
	}

	& qgo build --no-cache
	if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
		throw "CLI build failed with exit code $LASTEXITCODE"
	}
}
finally {
	if ($pushed) {
		Pop-Location
	}
	$env:GOOS = $originalGoos
	$env:GOARCH = $originalGoarch
	$env:GOWORK = $originalGowork
}

Assert-NvmFile -Path $defaultNvm -Label "nvm.exe"

if ([System.IO.Path]::GetFullPath($defaultNvm) -ne [System.IO.Path]::GetFullPath($targetNvm)) {
	New-Item -ItemType Directory -Force -Path (Split-Path -Parent $targetNvm) | Out-Null
	Copy-Item -LiteralPath $defaultNvm -Destination $targetNvm -Force
	Write-Host "Copied nvm.exe -> $targetNvm"
}

Assert-NvmFile -Path $targetNvm -Label "nvm.exe"
Write-Host "CLI ready -> $targetNvm"
return $targetNvm
