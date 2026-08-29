param(
	[switch]$StopOnError,
	[switch]$RequireSync,
	[ValidateSet("amd64", "arm64")]
	[string]$Architecture
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$installerRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $installerRoot ".."))
$statuses = New-Object System.Collections.Generic.List[object]

if ([string]::IsNullOrWhiteSpace($Architecture)) {
	if ([System.Environment]::Is64BitProcess) {
		if ([System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture -eq [System.Runtime.InteropServices.Architecture]::Arm64) {
			$Architecture = "arm64"
		} else {
			$Architecture = "amd64"
		}
	} else {
		$Architecture = "amd64"
	}
}

Write-Host "Building installer pipeline for architecture: $Architecture"

function Add-Status {
	param(
		[string]$Component,
		[string]$Step,
		[string]$Status,
		[string]$Message,
		[double]$Seconds
	)

	$statuses.Add([PSCustomObject]@{
		Component = $Component
		Step      = $Step
		Status    = $Status
		Seconds   = [Math]::Round($Seconds, 2)
		Message   = $Message
	})
}

function Invoke-Step {
	param(
		[string]$Component,
		[string]$Step,
		[string]$WorkingDirectory,
		[scriptblock]$Action
	)

	Write-Host "`n[$Component] $Step"
	$sw = [System.Diagnostics.Stopwatch]::StartNew()
	$locationPushed = $false

	try {
		Push-Location $WorkingDirectory
		$locationPushed = $true
		& $Action
		if ($LASTEXITCODE -ne $null -and $LASTEXITCODE -ne 0) {
			throw "Command exited with code $LASTEXITCODE"
		}

		$sw.Stop()
		Add-Status -Component $Component -Step $Step -Status "OK" -Message "Completed" -Seconds $sw.Elapsed.TotalSeconds
		Write-Host "[$Component] OK"
		return $true
	}
	catch {
		$sw.Stop()
		Add-Status -Component $Component -Step $Step -Status "FAILED" -Message $_.Exception.Message -Seconds $sw.Elapsed.TotalSeconds
		Write-Host "[$Component] FAILED: $($_.Exception.Message)" -ForegroundColor Red

		if ($StopOnError) {
			throw
		}

		return $false
	}
	finally {
		if ($locationPushed) {
			Pop-Location
		}
	}
}

function Build-Cli {
	$componentRoot = Join-Path $repoRoot "cli"
	$workingDir = $componentRoot

	if (-not (Test-Path (Join-Path $componentRoot "manifest.json")) -and
			(Test-Path (Join-Path $componentRoot "src\manifest.json"))) {
		$workingDir = Join-Path $componentRoot "src"
	}

	Invoke-Step -Component "cli" -Step "qgo exec prebuild" -WorkingDirectory $workingDir -Action {
		qgo exec prebuild
	}

	Invoke-Step -Component "cli" -Step "qgo build --no-cache" -WorkingDirectory $workingDir -Action {
		$env:GOARCH = if ($Architecture -eq "arm64") { "arm64" } else { "amd64" }
		qgo build --no-cache
	}
}

function Build-Shim {
	$componentRoot = Join-Path $repoRoot "shim"
	Invoke-Step -Component "shim" -Step "build.ps1" -WorkingDirectory $componentRoot -Action {
		.\build.ps1 -Architecture $Architecture
	}
}

function Build-Sync {
	$componentRoot = Join-Path $repoRoot "sync"
	$srcDir = Join-Path $componentRoot "src"
	$assetsDir = Join-Path $componentRoot "assets"
	$buildDir = Join-Path $componentRoot "build\build"
	if (-not (Test-Path $buildDir)) {
		$buildDir = Join-Path $componentRoot "build"
	}

	$syncAvailable =
		(Test-Path $componentRoot -PathType Container) -and
		(Test-Path $srcDir -PathType Container) -and
		(Test-Path $assetsDir -PathType Container) -and
		(Test-Path $buildDir -PathType Container)

	if (-not $syncAvailable) {
		$msg = "Sync component is unavailable (missing sync source/build directories)."
		if ($RequireSync) {
			Add-Status -Component "sync" -Step "availability check" -Status "FAILED" -Message "$msg Pass -RequireSync:`$false (or omit it) to allow skipping." -Seconds 0
			Write-Host "[sync] FAILED: $msg" -ForegroundColor Red
			if ($StopOnError) {
				throw $msg
			}
			return $false
		}

		Add-Status -Component "sync" -Step "availability check" -Status "SKIPPED" -Message "$msg Skipping sync build." -Seconds 0
		Write-Host "[sync] SKIPPED: $msg" -ForegroundColor Yellow
		return $true
	}

	$ok = $true

	if (-not (Invoke-Step -Component "sync" -Step "qgo build (build tool)" -WorkingDirectory $buildDir -Action {
		$env:GOARCH = if ($Architecture -eq "arm64") { "arm64" } else { "amd64" }
		qgo build
	})) {
		$ok = $false
	}

	if (-not (Invoke-Step -Component "sync" -Step "qgo exec prebuild (app)" -WorkingDirectory (Join-Path $componentRoot "src") -Action {
		qgo exec prebuild
	})) {
		$ok = $false
	}

	if (-not (Invoke-Step -Component "sync" -Step "qgo build --no-cache (app)" -WorkingDirectory (Join-Path $componentRoot "src") -Action {
		$env:GOARCH = if ($Architecture -eq "arm64") { "arm64" } else { "amd64" }
		qgo build --no-cache
	})) {
		$ok = $false
	}

	if (-not (Invoke-Step -Component "sync" -Step "sync-build.exe build ./assets -o ../bin/.sync" -WorkingDirectory $componentRoot -Action {
		.\sync-build.exe build ./assets -o ../bin/.sync
	})) {
		$ok = $false
	}

	return $ok
}

function Build-Updater {
	$updaterRoot = Join-Path $installerRoot "updater"
	Invoke-Step -Component "installer" -Step "updater\build.ps1" -WorkingDirectory $updaterRoot -Action {
		.\build.ps1 -Architecture $Architecture
	}
}

function Build-Installer {
	$manifestPath = Join-Path $repoRoot "cli\src\manifest.json"
	if (-not (Test-Path $manifestPath)) {
		$manifestPath = Join-Path $repoRoot "nvm\src\manifest.json"
	}

	if (-not (Test-Path $manifestPath)) {
		throw "installer manifest.json was not found"
	}

	$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
	$installerVersion = $manifest.version
	$installerAumid = $manifest.appUserModelId
	$installerAppId = $manifest.appId

	if ([string]::IsNullOrWhiteSpace($installerVersion) -or [string]::IsNullOrWhiteSpace($installerAumid) -or [string]::IsNullOrWhiteSpace($installerAppId)) {
		throw "installer manifest values are required before invoking build-installer.bat"
	}

	Invoke-Step -Component "installer" -Step "build-installer.bat" -WorkingDirectory $installerRoot -Action {
		cmd /c .\build-installer.bat $installerVersion $installerAumid $installerAppId $Architecture
	}
}

function Build-EventProvider {
	$step = Join-Path $repoRoot "build\steps\Build-EventProvider.ps1"
	Invoke-Step -Component "eventlog" -Step "Build-EventProvider.ps1" -WorkingDirectory $repoRoot -Action {
		& $step -Architecture $Architecture
	}
}

try {
	[void](Build-Cli)
	[void](Build-EventProvider)
	[void](Build-Shim)
	[void](Build-Sync)
	[void](Build-Updater)
	[void](Build-Installer)
}
catch {
	Write-Host "Build aborted: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nBuild Status Summary"
Write-Host "===================="
$statuses | Format-Table -AutoSize Component, Step, Status, Seconds, Message

$failedSteps = @($statuses | Where-Object { $_.Status -eq "FAILED" })

if ($failedSteps.Count -eq 0) {
	Write-Host "`nOverall Status: SUCCESS" -ForegroundColor Green
	exit 0
}

$failedComponents = @($failedSteps | Select-Object -ExpandProperty Component -Unique)
Write-Host "`nOverall Status: FAILED ($($failedComponents.Count) component(s): $([string]::Join(', ', $failedComponents)))" -ForegroundColor Red
exit 1
