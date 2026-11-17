# Compiles and runs installer preflight unit checks (timeout clamp, AV heuristics, ProgramData record).
# Usage: powershell -NoProfile -File installer\tests\Test-Preflight.ps1

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$testsRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$iss = Join-Path $testsRoot "PreflightTest.iss"
$iscc = Join-Path $env:LOCALAPPDATA "Programs\Inno Setup 6\ISCC.exe"
if (-not (Test-Path -LiteralPath $iscc)) {
	throw "Inno Setup compiler not found: $iscc"
}

$marker = Join-Path $env:LOCALAPPDATA "nvm-preflight-test-result.txt"
if (Test-Path -LiteralPath $marker) {
	Remove-Item -LiteralPath $marker -Force
}

$compileDir = Join-Path ([System.IO.Path]::GetTempPath()) ("nvm-inno-preflight-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $compileDir | Out-Null
try {
	& $iscc "/O$compileDir" "/Q" $iss
	if ($LASTEXITCODE -ne 0) {
		throw "ISCC failed with exit $LASTEXITCODE"
	}
	$setup = Join-Path $compileDir "preflight-compile-test.exe"
	if (-not (Test-Path -LiteralPath $setup)) {
		throw "Test installer was not created: $setup"
	}

	# Inno relaunches via /SL5; Start-Process -Wait waits for the real setup process.
	$proc = Start-Process -FilePath $setup -ArgumentList @("/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART") -Wait -PassThru -NoNewWindow
	if (-not (Test-Path -LiteralPath $marker)) {
		throw "Preflight marker was not written; InitializeSetup likely raised before PASS. exit=$($proc.ExitCode)"
	}
	$contents = Get-Content -LiteralPath $marker -Raw
	if ($contents -notmatch "PASS") {
		throw "Preflight marker did not contain PASS: $contents"
	}
	Write-Host "ok   PreflightTest passed"
}
finally {
	Remove-Item -LiteralPath $compileDir -Recurse -Force -ErrorAction SilentlyContinue
	Remove-Item -LiteralPath $marker -Force -ErrorAction SilentlyContinue
}
