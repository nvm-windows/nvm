# Gate or publish a GitHub Release for the community Inno Setup build.
# Version comes from cli/src/manifest.json.
# Uploads per architecture:
#   nvm-<version>-<arch>-setup.exe
#   nvm-<version>-<arch>-sync.exe   (prebuilt sync for public -DownloadSync builds)
#
# Modes:
#   Gate    — fail fast before long build if tag burned / already complete
#   Publish — draft → upload assets → publish
#
# Requires: gh CLI, GH_TOKEN with contents:write (workflow github.token).

param(
	[Parameter(Mandatory = $true)]
	[ValidateSet("Gate", "Publish")]
	[string]$Mode,

	[Parameter(Mandatory = $true)]
	[ValidateSet("amd64", "arm64")]
	[string[]]$Architectures,

	[switch]$OverrideExisting,

	[bool]$Enabled = $true,

	[string]$Version = "",

	[string]$AssetRoot = ""
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot "..\common.ps1")

$architectures = @(
	$Architectures |
		ForEach-Object { $_.Trim().ToLowerInvariant() } |
		Where-Object { $_ -in @("amd64", "arm64") } |
		Select-Object -Unique
)
if ($architectures.Count -eq 0) {
	throw "Architectures must include amd64 and/or arm64"
}

$version = $Version.Trim()
if ([string]::IsNullOrWhiteSpace($version)) {
	$ctx = Initialize-NvmBuildContext
	$version = [string]$ctx.CliVersion
}

function Get-NvmReleaseTag {
	param([string]$Version)
	$v = $Version.Trim()
	if ([string]::IsNullOrWhiteSpace($v)) {
		throw "CLI version is empty"
	}
	if ($v.StartsWith("v", [System.StringComparison]::OrdinalIgnoreCase)) {
		return $v
	}
	return "v$v"
}

function Clear-NativeExitCode {
	$global:LASTEXITCODE = 0
}

function Invoke-GhCapture {
	param(
		[Parameter(Mandatory = $true)]
		[string[]]$GhArgs
	)
	$prevEap = $ErrorActionPreference
	$ErrorActionPreference = "Continue"
	try {
		$lines = @(& gh @GhArgs 2>&1)
		$code = $LASTEXITCODE
	}
	finally {
		$ErrorActionPreference = $prevEap
		Clear-NativeExitCode
	}
	return [pscustomobject]@{
		ExitCode = $code
		Text     = (($lines | ForEach-Object { "$_" }) -join "`n").Trim()
	}
}

function Test-ReleaseExists {
	param([string]$Tag)

	$view = Invoke-GhCapture -GhArgs @("release", "view", $Tag, "--json", "databaseId")
	if ($view.ExitCode -eq 0) {
		return $true
	}

	$api = Invoke-GhCapture -GhArgs @("api", "repos/{owner}/{repo}/releases/tags/$Tag", "--silent")
	return ($api.ExitCode -eq 0)
}

function Get-ReleaseView {
	param(
		[string]$Tag,
		[string]$JsonFields = "databaseId,url,isDraft,tagName"
	)
	$result = Invoke-GhCapture -GhArgs @("release", "view", $Tag, "--json", $JsonFields)
	if ($result.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($result.Text) -or ($result.Text -notmatch '^\s*\{')) {
		return $null
	}
	return ($result.Text | ConvertFrom-Json)
}

function Test-ReleaseIsDraft {
	param([string]$Tag)
	$view = Get-ReleaseView -Tag $Tag -JsonFields "isDraft"
	if ($null -eq $view) {
		return $false
	}
	return [bool]$view.isDraft
}

function Get-ReleaseAssetNames {
	param([string]$Tag)
	$names = New-Object System.Collections.Generic.List[string]
	$view = Get-ReleaseView -Tag $Tag -JsonFields "assets"
	if ($null -eq $view -or $null -eq $view.assets) {
		return , $names
	}
	foreach ($a in @($view.assets)) {
		$n = [string]$a.name
		if (-not [string]::IsNullOrWhiteSpace($n)) {
			$names.Add($n)
		}
	}
	return , $names
}

function Test-ReleaseAssetNameMatchesArchitecture {
	param(
		[string]$Name,
		[string]$Architecture,
		[ValidateSet("setup", "sync", "any")]
		[string]$Kind = "any"
	)
	$arch = [regex]::Escape($Architecture)
	switch ($Kind) {
		"setup" { return ($Name -match ("-{0}-setup\.exe$" -f $arch)) }
		"sync" { return ($Name -match ("-{0}-sync\.exe$" -f $arch)) }
		default { return ($Name -match ("-{0}-(setup|sync)\.exe$" -f $arch)) }
	}
}

function Get-ReleaseAssetsForArchitecture {
	param(
		[string]$Tag,
		[string]$Architecture,
		[ValidateSet("setup", "sync", "any")]
		[string]$Kind = "any"
	)
	$matched = New-Object System.Collections.Generic.List[string]
	foreach ($name in (Get-ReleaseAssetNames -Tag $Tag)) {
		if (Test-ReleaseAssetNameMatchesArchitecture -Name $name -Architecture $Architecture -Kind $Kind) {
			$matched.Add($name)
		}
	}
	return , $matched
}

function Write-ReleaseEnv {
	param(
		[string]$Version,
		[string]$Tag
	)
	if (-not [string]::IsNullOrWhiteSpace($env:GITHUB_ENV)) {
		Add-Content -LiteralPath $env:GITHUB_ENV -Value "CLI_VERSION=$Version"
		Add-Content -LiteralPath $env:GITHUB_ENV -Value "RELEASE_TAG=$Tag"
	}
	if (-not [string]::IsNullOrWhiteSpace($env:GITHUB_OUTPUT)) {
		Add-Content -LiteralPath $env:GITHUB_OUTPUT -Value "version=$Version"
		Add-Content -LiteralPath $env:GITHUB_OUTPUT -Value "tag=$Tag"
	}
	Write-Host "CLI version -> $Version"
	Write-Host "Release tag -> $Tag"
	Write-Host ("Architectures -> {0}" -f ($architectures -join ", "))
}

function Get-ImmutableTagBurnHint {
	param([string]$Tag)
	return @"
Tag $Tag may be permanently reserved if it was ever published while immutable releases were enabled.
Deleting the release does NOT free the tag name in that case.

Bump ``cli/src/manifest.json`` version and re-run.
Preferred flow: create --draft → upload assets → edit --draft=false
"@
}

function New-NvmDraftRelease {
	param(
		[string]$Tag,
		[string]$Version
	)

	$noteArches = ($architectures -join ", ")
	$createArgs = @(
		"release", "create", $Tag,
		"--draft",
		"--title", $Tag,
		"--notes", ("NVM for Windows {0}`n`nUnsigned community build from ``cli/src/manifest.json`` version ``{1}``.`nArchitectures: {2}.`n`nAssets per arch: Inno Setup installer (`*-setup.exe`) and prebuilt ``sync.exe`` (`*-sync.exe`) for public ``-DownloadSync`` builds." -f $Tag, $Version, $noteArches)
	)
	if ($Version -match '(?i)(alpha|beta|rc|preview|pre)') {
		$createArgs += "--prerelease"
	}

	Write-Host ("Creating draft release {0}..." -f $Tag)
	$created = Invoke-GhCapture -GhArgs $createArgs
	if ($created.ExitCode -eq 0) {
		if (-not [string]::IsNullOrWhiteSpace($created.Text)) {
			Write-Host $created.Text
		}
		return
	}

	if (Test-ReleaseExists -Tag $Tag) {
		Write-Host ("Release {0} already exists after create exit {1}; continuing." -f $Tag, $created.ExitCode)
		return
	}

	if ($created.Text -match '(?i)Resource not accessible by integration|HTTP 403') {
		throw ("{0}`n`nGH_TOKEN cannot create releases (403). Use github.token with contents:write." -f $created.Text)
	}

	if ($created.Text -match '(?i)immutable|tag_name was used') {
		throw ("{0}`n`n{1}" -f $created.Text, (Get-ImmutableTagBurnHint -Tag $Tag))
	}

	if ($created.Text -match '(?i)creations being restricted|Repository rule') {
		throw ("{0}`n`nRuleset blocked tag/ref creation. Allow github-actions to create tags, or bypass for this repo." -f $created.Text)
	}

	throw ("gh release create --draft {0} failed with exit code {1}: {2}" -f $Tag, $created.ExitCode, $created.Text)
}

function Get-ReleaseUploadState {
	param([string]$Tag)

	$view = Get-ReleaseView -Tag $Tag -JsonFields "isDraft,url,databaseId"
	if ($null -eq $view) {
		throw ("Release {0} not visible to GH_TOKEN. Check contents:write on github.token." -f $Tag)
	}
	return [pscustomobject]@{
		IsDraft    = [bool]$view.isDraft
		Url        = [string]$view.url
		DatabaseId = [string]$view.databaseId
	}
}

function Publish-NvmDraftRelease {
	param([string]$Tag)

	Write-Host ("Publishing draft release {0}..." -f $Tag)
	$pub = Invoke-GhCapture -GhArgs @("release", "edit", $Tag, "--draft=false")
	if ($pub.ExitCode -ne 0) {
		throw ("gh release edit {0} --draft=false failed with exit code {1}: {2}" -f $Tag, $pub.ExitCode, $pub.Text)
	}
}

function Remove-ReleaseAssetsForArchitecture {
	param(
		[string]$Tag,
		[string]$Architecture
	)
	$names = Get-ReleaseAssetsForArchitecture -Tag $Tag -Architecture $Architecture -Kind "any"
	if ($names.Count -eq 0) {
		Write-Host ("No existing {0} setup/sync assets on {1} to remove." -f $Architecture, $Tag)
		return
	}
	foreach ($name in $names) {
		Write-Host ("Removing release asset {0}..." -f $name)
		$del = Invoke-GhCapture -GhArgs @("release", "delete-asset", $Tag, $name, "--yes")
		if ($del.ExitCode -ne 0) {
			throw "gh release delete-asset $Tag $name failed with exit code $($del.ExitCode): $($del.Text)"
		}
	}
}

function Get-NvmReleaseUploadPaths {
	param(
		[string]$Architecture,
		[string]$SearchRoot,
		[ValidateSet("setup", "sync")]
		[string]$Kind
	)

	$paths = New-Object System.Collections.Generic.List[string]
	if (-not (Test-Path -LiteralPath $SearchRoot -PathType Container)) {
		return , $paths
	}

	Get-ChildItem -LiteralPath $SearchRoot -File -Recurse -ErrorAction SilentlyContinue |
		Where-Object {
			$_.Extension -ieq ".exe" -and
			(Test-ReleaseAssetNameMatchesArchitecture -Name $_.Name -Architecture $Architecture -Kind $Kind)
		} |
		ForEach-Object { $paths.Add($_.FullName) }

	$byName = @{}
	foreach ($p in $paths) {
		$name = [System.IO.Path]::GetFileName($p)
		if (-not $byName.ContainsKey($name)) {
			$byName[$name] = $p
		}
		else {
			Write-Host ("Release upload: skip duplicate name {0} ({1})" -f $name, $p)
		}
	}
	$unique = New-Object System.Collections.Generic.List[string]
	foreach ($name in ($byName.Keys | Sort-Object)) {
		$unique.Add([string]$byName[$name])
	}
	return , $unique
}

$tag = Get-NvmReleaseTag -Version $version
Write-ReleaseEnv -Version $version -Tag $tag

if (-not $Enabled) {
	Write-Host "GitHub Release publish disabled (publish_release unchecked)." -ForegroundColor Yellow
	Clear-NativeExitCode
	return
}

if ([string]::IsNullOrWhiteSpace($env:GH_TOKEN) -and [string]::IsNullOrWhiteSpace($env:GITHUB_TOKEN)) {
	throw "GH_TOKEN or GITHUB_TOKEN required for release Gate/Publish"
}

$repoRoot = Get-NvmRepoRoot
$defaultSearchRoot = if (-not [string]::IsNullOrWhiteSpace($AssetRoot)) {
	[System.IO.Path]::GetFullPath($AssetRoot)
}
else {
	$repoRoot
}

switch ($Mode) {
	"Gate" {
		if (-not (Test-ReleaseExists -Tag $tag)) {
			Write-Host ("Probing draft create for {0}..." -f $tag)
			New-NvmDraftRelease -Tag $tag -Version $version
			Write-Host ("Draft {0} ready — build may proceed." -f $tag)
			Clear-NativeExitCode
			return
		}

		$isDraft = Test-ReleaseIsDraft -Tag $tag
		$missing = New-Object System.Collections.Generic.List[string]
		$conflicts = New-Object System.Collections.Generic.List[string]

		foreach ($arch in $architectures) {
			$setupAssets = Get-ReleaseAssetsForArchitecture -Tag $tag -Architecture $arch -Kind "setup"
			$syncAssets = Get-ReleaseAssetsForArchitecture -Tag $tag -Architecture $arch -Kind "sync"
			$complete = ($setupAssets.Count -gt 0 -and $syncAssets.Count -gt 0)

			if (-not $complete) {
				$missing.Add($arch) | Out-Null
				Write-Host ("Release {0} ({1}) incomplete for {2}: setup={3} sync={4}." -f $tag, $(if ($isDraft) { "draft" } else { "published" }), $arch, $setupAssets.Count, $syncAssets.Count)
				continue
			}
			if ($OverrideExisting) {
				Write-Host ("Release {0} has complete {1} assets; override_existing_release=true — will replace after build:" -f $tag, $arch)
				@($setupAssets) + @($syncAssets) | ForEach-Object { Write-Host ("  - {0}" -f $_) }
				continue
			}
			foreach ($name in (@($setupAssets) + @($syncAssets))) {
				$conflicts.Add("${arch}: $name") | Out-Null
			}
		}

		if ($conflicts.Count -gt 0) {
			throw @"
Release $tag already has setup+sync assets for selected architecture(s):
$($conflicts | ForEach-Object { "  - $_" } | Out-String)
Re-run with override_existing_release=true to replace them (immutable must be OFF), or bump cli/src/manifest.json version.
"@
		}

		if ($missing.Count -eq 0 -and -not $OverrideExisting) {
			throw @"
Release $tag already has setup.exe + sync.exe for all selected architecture(s): $($architectures -join ', ').
Nothing to build/publish. Bump cli/src/manifest.json version, or re-run with override_existing_release=true (immutable must be OFF).
"@
		}

		if (-not $isDraft -and $missing.Count -gt 0) {
			Write-Host ("Published release {0} missing {1} — will upload after build (requires immutable OFF)." -f $tag, ($missing -join ", ")) -ForegroundColor Yellow
		}
	}

	"Publish" {
		if (-not (Test-ReleaseExists -Tag $tag)) {
			New-NvmDraftRelease -Tag $tag -Version $version
		}

		$state = Get-ReleaseUploadState -Tag $tag
		if ($state.IsDraft) {
			Write-Host ("Target release {0} is draft — upload setup+sync then publish." -f $tag)
		}
		else {
			Write-Host ("Target release {0} is already published — uploading with --clobber (immutable must be OFF)." -f $tag) -ForegroundColor Yellow
		}

		foreach ($arch in $architectures) {
			$setupAssets = Get-ReleaseAssetsForArchitecture -Tag $tag -Architecture $arch -Kind "setup"
			$syncAssets = Get-ReleaseAssetsForArchitecture -Tag $tag -Architecture $arch -Kind "sync"
			$hasAny = ($setupAssets.Count -gt 0 -or $syncAssets.Count -gt 0)
			$complete = ($setupAssets.Count -gt 0 -and $syncAssets.Count -gt 0)

			if ($complete -and -not $OverrideExisting) {
				throw ("Release {0} already has complete {1} setup+sync assets and override_existing_release is false." -f $tag, $arch)
			}
			if ($hasAny -and $OverrideExisting) {
				Remove-ReleaseAssetsForArchitecture -Tag $tag -Architecture $arch
			}
			elseif ($hasAny -and -not $complete) {
				Write-Host ("Release {0} incomplete for {1} (setup={2} sync={3}) — uploading missing assets without purge." -f $tag, $arch, $setupAssets.Count, $syncAssets.Count) -ForegroundColor Yellow
			}
		}

		$upload = New-Object System.Collections.Generic.List[string]
		$uploadSeenPath = @{}
		$uploadSeenName = @{}
		foreach ($arch in $architectures) {
			foreach ($kind in @("setup", "sync")) {
				$existingKind = Get-ReleaseAssetsForArchitecture -Tag $tag -Architecture $arch -Kind $kind
				if ($existingKind.Count -gt 0 -and -not $OverrideExisting) {
					Write-Host ("Keeping existing {0} asset(s) for {1}; skip upload of that kind." -f $kind, $arch)
					continue
				}
				$found = Get-NvmReleaseUploadPaths -Architecture $arch -SearchRoot $defaultSearchRoot -Kind $kind
				if ($found.Count -eq 0) {
					throw ("No {0}-{1}.exe found under {2}" -f $arch, $kind, $defaultSearchRoot)
				}
				if ($found.Count -gt 1) {
					Write-Host ("WARNING: multiple {0}-{1}.exe matches; uploading first unique names only." -f $arch, $kind) -ForegroundColor Yellow
				}
				foreach ($p in $found) {
					$base = [System.IO.Path]::GetFileName($p)
					if ($uploadSeenPath.ContainsKey($p) -or $uploadSeenName.ContainsKey($base)) {
						continue
					}
					$uploadSeenPath[$p] = $true
					$uploadSeenName[$base] = $true
					$upload.Add($p)
				}
			}
		}

		if ($upload.Count -eq 0) {
			throw ("Nothing to upload for {0} (all setup+sync assets already present)." -f $tag)
		}

		Write-Host ("Uploading {0} asset(s) to {1}..." -f $upload.Count, $tag)
		$upload | ForEach-Object { Write-Host ("  + {0}" -f $_) }

		$up = Invoke-GhCapture -GhArgs (@("release", "upload", $tag) + @($upload.ToArray()) + @("--clobber"))
		if ($up.ExitCode -ne 0) {
			throw "gh release upload $tag failed with exit code $($up.ExitCode): $($up.Text)"
		}

		if ($state.IsDraft) {
			Publish-NvmDraftRelease -Tag $tag
		}
		else {
			Write-Host ("Release {0} was already published — skipped draft→publish." -f $tag)
		}

		$view = Get-ReleaseView -Tag $tag -JsonFields "url,databaseId,isDraft"
		if ($null -eq $view -or [string]::IsNullOrWhiteSpace([string]$view.databaseId)) {
			throw "Unable to read GitHub release databaseId for $tag after publish"
		}
		$url = [string]$view.url
		$releaseId = [string]$view.databaseId
		Write-Host ("Release ready -> {0} (id {1}, draft={2})" -f $url, $releaseId, $view.isDraft)
		if (-not [string]::IsNullOrWhiteSpace($env:GITHUB_STEP_SUMMARY)) {
			$archList = $architectures -join ", "
			Add-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Value ("## GitHub Release`n`n[{0}]({1})`n`nArchitectures: {2}`n`nRelease ID: ``{3}```n`nAssets: ``*-setup.exe`` + ``*-sync.exe``" -f $tag, $url, $archList, $releaseId)
		}
	}
}

Clear-NativeExitCode
