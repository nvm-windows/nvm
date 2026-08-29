<#
.SYNOPSIS
Creates an unsigned, local WinGet manifest set for a community release.

.DESCRIPTION
Generates and hashes manifests only. This script never forks winget-pkgs,
opens a pull request, or submits a package.
#>
[CmdletBinding()]
param(
	[Parameter(Mandatory = $true)]
	[string]$ReleaseTag,

	[Parameter(Mandatory = $true)]
	[string]$Repository,

	[Parameter(Mandatory = $true)]
	[string]$InstallerDirectory,

	[Parameter(Mandatory = $true)]
	[string]$OutputDirectory
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$packageIdentifier = "AuthorSoftware.NVMforWindows"
$publisher = "Author Software Inc."
$packageName = "NVM for Windows"
$productCode = "40078385-F676-4C61-9A9C-F9028599D6D3_is1"

$tag = $ReleaseTag.Trim()
if ([string]::IsNullOrWhiteSpace($tag)) {
	throw "ReleaseTag must not be empty."
}
$version = $tag -replace '^[vV]', ''
if ([string]::IsNullOrWhiteSpace($version)) {
	throw "ReleaseTag does not contain a version: $ReleaseTag"
}
if ($Repository -notmatch '^[^/\s]+/[^/\s]+$') {
	throw "Repository must be owner/name: $Repository"
}

$installerRoot = [System.IO.Path]::GetFullPath($InstallerDirectory)
if (-not (Test-Path -LiteralPath $installerRoot -PathType Container)) {
	throw "Installer directory does not exist: $installerRoot"
}

$installers = @(
	@{ BuildArchitecture = "amd64"; WingetArchitecture = "x64" }
	@{ BuildArchitecture = "arm64"; WingetArchitecture = "arm64" }
)

$installerEntries = New-Object System.Collections.Generic.List[string]
foreach ($installer in $installers) {
	$assetName = "nvm-{0}-{1}-setup.exe" -f $version, $installer.BuildArchitecture
	$assetPath = Join-Path $installerRoot $assetName
	if (-not (Test-Path -LiteralPath $assetPath -PathType Leaf)) {
		throw "Required release asset missing: $assetPath"
	}

	$hash = (Get-FileHash -LiteralPath $assetPath -Algorithm SHA256).Hash.ToUpperInvariant()
	$assetUrl = "https://github.com/{0}/releases/download/{1}/{2}" -f $Repository, $tag, $assetName
	$installerEntries.Add(@"
- Architecture: $($installer.WingetArchitecture)
  InstallerUrl: $assetUrl
  InstallerSha256: $hash
"@.TrimEnd())
}

$manifestRoot = Join-Path $OutputDirectory ("manifests\a\AuthorSoftware\NVMforWindows\{0}" -f $version)
New-Item -ItemType Directory -Force -Path $manifestRoot | Out-Null

$versionManifest = @"
# yaml-language-server: `$schema=https://aka.ms/winget-manifest.version.1.9.0.schema.json
PackageIdentifier: $packageIdentifier
PackageVersion: $version
DefaultLocale: en-US
ManifestType: version
ManifestVersion: 1.9.0
"@

$localeManifest = @"
# yaml-language-server: `$schema=https://aka.ms/winget-manifest.defaultLocale.1.9.0.schema.json
PackageIdentifier: $packageIdentifier
PackageVersion: $version
PackageLocale: en-US
Publisher: $publisher
PublisherUrl: https://nvm-windows.com
PublisherSupportUrl: https://github.com/$Repository/issues
PackageName: $packageName
PackageUrl: https://github.com/$Repository
License: MIT
LicenseUrl: https://github.com/$Repository/blob/HEAD/LICENSE
Copyright: Copyright (c) 2026 $publisher
CopyrightUrl: https://github.com/$Repository/blob/HEAD/LICENSE
ShortDescription: Node.js version manager for Windows.
Moniker: nvm
Tags:
- node
- nodejs
- nvm
- nvm-windows
- version-manager
- windows
ReleaseNotesUrl: https://github.com/$Repository/releases/tag/$tag
ManifestType: defaultLocale
ManifestVersion: 1.9.0
"@

$installerManifest = @"
# yaml-language-server: `$schema=https://aka.ms/winget-manifest.installer.1.9.0.schema.json
PackageIdentifier: $packageIdentifier
PackageVersion: $version
InstallerLocale: en-US
InstallerType: inno
Scope: user
UpgradeBehavior: install
Commands:
- nvm
ProductCode: $productCode
AppsAndFeaturesEntries:
- Publisher: $publisher
  ProductCode: $productCode
ElevationRequirement: elevatesSelf
InstallationMetadata:
  DefaultInstallLocation: '%LocalAppData%\Author Software\nvm'
InstallerSwitches:
  Silent: /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
  SilentWithProgress: /SILENT /SUPPRESSMSGBOXES /NORESTART
Installers:
$($installerEntries -join "`n")
ManifestType: installer
ManifestVersion: 1.9.0
"@

$encoding = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText((Join-Path $manifestRoot "$packageIdentifier.yaml"), $versionManifest, $encoding)
[System.IO.File]::WriteAllText((Join-Path $manifestRoot "$packageIdentifier.locale.en-US.yaml"), $localeManifest, $encoding)
[System.IO.File]::WriteAllText((Join-Path $manifestRoot "$packageIdentifier.installer.yaml"), $installerManifest, $encoding)

Write-Host "Created WinGet dry-run manifests: $manifestRoot"
Get-ChildItem -LiteralPath $manifestRoot -File | ForEach-Object {
	Write-Host "  $($_.Name)"
}
