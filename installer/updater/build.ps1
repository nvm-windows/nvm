param(
	[string]$OutputExe = "bin\nvm-upgrader.exe",
	[ValidateSet("ReleaseSmall", "ReleaseSafe", "ReleaseFast", "Debug")]
	[string]$BuildProfile = "ReleaseSmall",
	[ValidateSet("amd64", "arm64")]
	[string]$Architecture
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($Architecture)) {
	if ([System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture -eq [System.Runtime.InteropServices.Architecture]::Arm64) {
		$Architecture = "arm64"
	} else {
		$Architecture = "amd64"
	}
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$outputPath = [System.IO.Path]::GetFullPath((Join-Path $scriptRoot $OutputExe))
$outputDir = Split-Path -Parent $outputPath

if (!(Test-Path $outputDir)) {
	New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

Push-Location $scriptRoot
try {
	# x86_64-windows-gnu if compiling on Linux, otherwise x86_64-windows-msvc
	zig build-exe -target $(if ($Architecture -eq 'arm64') { 'aarch64-windows-msvc' } else { 'x86_64-windows-msvc' }) .\main.zig -O $BuildProfile -fstrip -femit-bin=nvm-upgrader
	Copy-Item -Force .\nvm-upgrader $outputPath
	go-winres patch --in .\winres\winres.json --no-backup $outputPath
}
finally {
	Remove-Item .\nvm-upgrader -ErrorAction SilentlyContinue
	Remove-Item .\nvm-upgrader.pdb -ErrorAction SilentlyContinue
	Pop-Location
}
