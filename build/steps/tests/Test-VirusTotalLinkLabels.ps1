# Usage: powershell -NoProfile -File build/steps/tests/Test-VirusTotalLinkLabels.ps1

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$script = Join-Path (Split-Path -Parent $PSScriptRoot) "Update-VirusTotalReleaseNotes.ps1"
. $script

function Assert-Equal([string]$Expected, [string]$Actual, [string]$Label) {
	if ($Expected -cne $Actual) {
		throw "FAIL $Label`n expected: $Expected`n actual:   $Actual"
	}
	Write-Host "ok   $Label"
}

Assert-Equal `
	"NVM for Windows v2.0.1 x64 Virus Report" `
	(Get-NvmVirusTotalLinkLabel -FileName "nvm-2.0.1-x64-setup.exe" -VersionLabel "2.0.1") `
	"x64 setup"
Assert-Equal `
	"NVM for Windows v2.0.1 arm64 Virus Report" `
	(Get-NvmVirusTotalLinkLabel -FileName "nvm-2.0.1-arm64-setup.exe" -VersionLabel "2.0.1") `
	"arm64 setup"
Assert-Equal `
	"NVM for Windows v2.0.1 Sync Tool x64 Virus Report" `
	(Get-NvmVirusTotalLinkLabel -FileName "nvm-2.0.1-x64-sync.exe" -VersionLabel "2.0.1") `
	"x64 sync"
Assert-Equal `
	"NVM for Windows v2.0.1 Sync Tool arm64 Virus Report" `
	(Get-NvmVirusTotalLinkLabel -FileName "nvm-2.0.1-arm64-sync.exe" -VersionLabel "2.0.1") `
	"arm64 sync"
Assert-Equal `
	"NVM for Windows v2.1.0-beta.14 arm64 Virus Report" `
	(Get-NvmVirusTotalLinkLabel -FileName "nvm-2.1.0-beta.14-arm64-setup.exe" -VersionLabel "2.1.0-beta.14") `
	"beta arm64 setup"

Write-Host "VirusTotal link label tests passed"
