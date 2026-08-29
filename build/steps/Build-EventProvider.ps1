param(
	[ValidateSet("amd64", "arm64")]
	[string]$Architecture = "amd64",
	[string]$BinRoot = ""
)

# Build NVMWindows.Events.man + resource DLL next to nvm.exe.
# Required by common/eventlog.RegisterEventSource (wevtutil im /rf /mf /pf).
# Message resource DLL is not Authenticode-signed (certified Sign-Executables
# only signs .exe/.msi). Not a sync worker → no COSE.

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot "..\common.ps1")
$ctx = Initialize-NvmBuildContext -BinRoot $BinRoot

function Invoke-NvmTemplateRender {
	param(
		[Parameter(Mandatory = $true)][string]$TemplatePath,
		[Parameter(Mandatory = $true)][string]$OutputPath,
		[Parameter(Mandatory = $true)][hashtable]$Tokens
	)

	$content = Get-Content -LiteralPath $TemplatePath -Raw
	foreach ($entry in $Tokens.GetEnumerator()) {
		$content = $content.Replace($entry.Key, [string]$entry.Value)
	}
	$encoding = [System.Text.UTF8Encoding]::new($false)
	[System.IO.File]::WriteAllText([System.IO.Path]::GetFullPath($OutputPath), $content, $encoding)
}

function Resolve-WindowsSdkTool {
	param(
		[Parameter(Mandatory = $true)][string]$ToolName
	)

	$sdkBin = Join-Path ${env:ProgramFiles(x86)} "Windows Kits\10\bin"
	if (-not (Test-Path -LiteralPath $sdkBin -PathType Container)) {
		throw "Windows SDK bin root not found: $sdkBin"
	}

	$sdkVer = Get-ChildItem -LiteralPath $sdkBin -Directory -ErrorAction SilentlyContinue |
		Where-Object { $_.Name -match '^\d+\.\d+\.\d+\.\d+$' } |
		Sort-Object { [version]$_.Name } -Descending |
		Select-Object -First 1 -ExpandProperty Name

	if ([string]::IsNullOrWhiteSpace($sdkVer)) {
		throw "No Windows SDK version directory under $sdkBin"
	}

	$path = Join-Path $sdkBin "$sdkVer\x64\$ToolName"
	if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
		throw "$ToolName not found: $path"
	}
	return $path
}

function Resolve-LinkExe {
	param(
		[ValidateSet("amd64", "arm64")]
		[string]$Architecture
	)

	$vsRoots = @(
		(Join-Path ${env:ProgramFiles} "Microsoft Visual Studio"),
		(Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio")
	) | Where-Object { Test-Path -LiteralPath $_ -PathType Container }

	$hostArch = if ($Architecture -eq "arm64") { "arm64" } else { "x64" }
	$patterns = @(
		"Hostx64\\$hostArch",
		"Hostarm64\\$hostArch",
		"Hostx86\\$hostArch"
	)

	foreach ($root in $vsRoots) {
		$candidates = Get-ChildItem -LiteralPath $root -Recurse -Filter "link.exe" -ErrorAction SilentlyContinue |
			Where-Object {
				$full = $_.FullName
				foreach ($p in $patterns) {
					if ($full -match $p) { return $true }
				}
				return $false
			} |
			Select-Object -ExpandProperty FullName

		$pick = @($candidates) | Select-Object -First 1
		if (-not [string]::IsNullOrWhiteSpace($pick)) {
			return $pick
		}
	}

	throw "link.exe not found under Visual Studio (need Host*\$hostArch for $Architecture)"
}

$installerRoot = Join-Path $ctx.RepoRoot "installer"
$templatePath = Join-Path $installerRoot "NVMWindows.Events.man.template"
if (-not (Test-Path -LiteralPath $templatePath -PathType Leaf)) {
	throw "Event provider template missing: $templatePath"
}

$manifestPath = Get-NvmCliManifestPath
$cliManifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json

$eventProviderDisplayName = [string]$cliManifest.appLabel
if ([string]::IsNullOrWhiteSpace($eventProviderDisplayName)) {
	throw "manifest.json missing appLabel for event provider display name"
}

$eventProviderManifestFileName = [string]$cliManifest.eventLabel
if ([string]::IsNullOrWhiteSpace($eventProviderManifestFileName)) {
	throw "manifest.json missing eventLabel for event provider manifest filename"
}

$eventProviderChannelLeafName = "Operational"
$eventProviderName = $eventProviderDisplayName
$eventProviderChannelPrefix = $eventProviderDisplayName
$eventProviderChannelName = "$eventProviderChannelPrefix/$eventProviderChannelLeafName"
$eventResourceDllFileName = [System.IO.Path]::ChangeExtension($eventProviderManifestFileName, ".dll")

$eventManifestOut = Join-Path $ctx.BinRoot $eventProviderManifestFileName
$eventResourceDllOut = Join-Path $ctx.BinRoot $eventResourceDllFileName

$tokens = @{
	"__EVENT_PROVIDER_NAME__"                 = $eventProviderName
	"__EVENT_PROVIDER_DISPLAY_NAME__"         = $eventProviderDisplayName
	"__EVENT_PROVIDER_CHANNEL_DISPLAY_NAME__" = $eventProviderChannelLeafName
	"__EVENT_PROVIDER_ORGANIZATION__"         = $eventProviderDisplayName
	"__EVENT_PROVIDER_CHANNEL_PREFIX__"       = $eventProviderChannelPrefix
	"__EVENT_PROVIDER_CHANNEL_NAME__"         = $eventProviderChannelName
	"__EVENT_PROVIDER_MANIFEST_FILE_NAME__"   = $eventProviderManifestFileName
	"__EVENT_RESOURCE_DLL_NAME__"             = $eventResourceDllFileName
	"__EVENT_RESOURCE_DLL_FILE_NAME__"        = $eventResourceDllFileName
}

Write-Host "Building event provider assets ($Architecture)..."
Invoke-NvmTemplateRender -TemplatePath $templatePath -OutputPath $eventManifestOut -Tokens $tokens

$mcExePath = Resolve-WindowsSdkTool -ToolName "mc.exe"
$rcExePath = Resolve-WindowsSdkTool -ToolName "rc.exe"
$linkExePath = Resolve-LinkExe -Architecture $Architecture
$machine = if ($Architecture -eq "arm64") { "ARM64" } else { "X64" }

$dllTempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("nvm-evtres-{0}" -f [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $dllTempDir -Force | Out-Null
try {
	Push-Location $dllTempDir
	& $mcExePath -z NVMWindowsEvents $eventManifestOut 2>&1 | ForEach-Object { Write-Host $_ }
	if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
		throw "mc.exe failed (exit $LASTEXITCODE) for $eventManifestOut"
	}
	& $rcExePath "NVMWindowsEvents.rc" 2>&1 | ForEach-Object { Write-Host $_ }
	if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
		throw "rc.exe failed (exit $LASTEXITCODE)"
	}
	& $linkExePath /DLL /NOENTRY "/MACHINE:$machine" "NVMWindowsEvents.res" "/OUT:$eventResourceDllOut" 2>&1 |
		ForEach-Object { Write-Host $_ }
	if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
		throw "link.exe failed (exit $LASTEXITCODE)"
	}
}
finally {
	Pop-Location -ErrorAction SilentlyContinue
	Remove-Item -LiteralPath $dllTempDir -Recurse -Force -ErrorAction SilentlyContinue
}

Assert-NvmFile -Path $eventManifestOut -Label $eventProviderManifestFileName | Out-Null
Assert-NvmFile -Path $eventResourceDllOut -Label $eventResourceDllFileName | Out-Null
Write-Host "Event provider ready -> $eventManifestOut"
Write-Host "Event resource DLL  -> $eventResourceDllOut"
# Authenticode N/A for message resource DLL (certified same). COSE N/A (sync workers only).
Write-Host "Signing            -> none (Events.dll is wevtutil message resource; not Authenticode/COSE)"

return @{
	Manifest = $eventManifestOut
	Dll      = $eventResourceDllOut
}
