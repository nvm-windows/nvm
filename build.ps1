# Compatibility wrapper. Canonical entrypoint: .\build\main.ps1
& (Join-Path $PSScriptRoot "build\main.ps1") @args
if ($null -ne $LASTEXITCODE) {
	exit $LASTEXITCODE
}
