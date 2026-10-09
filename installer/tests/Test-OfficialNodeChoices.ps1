# Compiles the Inno Setup official-Node choices and runs adopt and drop
# against temporary files. Drop records msiexec instead of uninstalling Node.js.
# Usage: powershell -NoProfile -File installer\tests\Test-OfficialNodeChoices.ps1

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$testsRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$iss = Join-Path $testsRoot "OfficialNodeTest.iss"
$iscc = Join-Path $env:LOCALAPPDATA "Programs\Inno Setup 6\ISCC.exe"
if (-not (Test-Path -LiteralPath $iscc)) {
	throw "Inno Setup compiler not found: $iscc"
}

$failures = New-Object System.Collections.Generic.List[string]
$productCode = "{AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE}"

function Add-Failure([string]$Message) {
	$failures.Add($Message)
	Write-Host "FAIL $Message"
}

function Assert-True([bool]$Condition, [string]$Message) {
	if ($Condition) {
		Write-Host "ok   $Message"
		return
	}
	Add-Failure $Message
}

$compileDir = Join-Path ([System.IO.Path]::GetTempPath()) ("nvm-inno-officialnode-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $compileDir | Out-Null
& $iscc "/O$compileDir" "/Q" $iss
if ($LASTEXITCODE -ne 0) {
	throw "ISCC failed with exit $LASTEXITCODE"
}
$setup = Join-Path $compileDir "officialnode-choice-test.exe"
if (-not (Test-Path -LiteralPath $setup)) {
	throw "Test installer was not created: $setup"
}

function Read-Result([string]$Path) {
	$map = @{}
	if (-not (Test-Path -LiteralPath $Path)) {
		return $map
	}
	foreach ($line in Get-Content -LiteralPath $Path) {
		$parts = $line -split "=", 2
		if ($parts.Count -eq 2) {
			$map[$parts[0]] = $parts[1]
		}
	}
	return $map
}

function Invoke-InnoChoice {
	param(
		[string]$OfficialNode,
		[switch]$Found,
		[switch]$MissingNode,
		[switch]$SkipProduct
	)

	$case = Join-Path $compileDir ("case-" + [guid]::NewGuid().ToString("N"))
	$source = Join-Path $case "official"
	$modules = Join-Path $case "npm-modules\left-pad"
	$installs = Join-Path $case "installs"
	$app = Join-Path $case "app"
	New-Item -ItemType Directory -Force -Path $source, $modules, $installs, $app | Out-Null
	if (-not $MissingNode) {
		Set-Content -LiteralPath (Join-Path $source "node.exe") -Value "node" -Encoding ascii
	}
	Set-Content -LiteralPath (Join-Path $source "node.lib") -Value "lib" -Encoding ascii
	Set-Content -LiteralPath (Join-Path $modules "index.js") -Value "module" -Encoding ascii

	$resultPath = Join-Path $case "result.txt"
	$logPath = Join-Path $case "uninstall.txt"
	$installLog = Join-Path $case "install.log"
	$args = @(
		"/VERYSILENT",
		"/SUPPRESSMSGBOXES",
		"/NORESTART",
		"/DIR=$app",
		"/OFFICIALNODE=$OfficialNode",
		"/NODESOURCE=$source",
		"/INSTALLROOT=$installs",
		"/OFFICIALNODEMODULES=$(Split-Path -Parent $modules)",
		"/OFFICIALNODELOG=$logPath",
		"/OFFICIALNODERESULT=$resultPath",
		"/INSTALLLOG=$installLog"
	)
	if ($Found) { $args += "/NODEFOUND=1" }
	if ($SkipProduct) { $args += "/SKIPPRODUCT=1" }

	$proc = Start-Process -FilePath $setup -ArgumentList $args -Wait -PassThru
	$destNode = Join-Path $installs "v22.14.0\node.exe"
	$destLib = Join-Path $installs "v22.14.0\node.lib"
	$destModule = Join-Path $installs "v22.14.0\node_modules\left-pad\index.js"
	$copied = (Test-Path -LiteralPath $destNode) -and (Test-Path -LiteralPath $destLib) -and (Test-Path -LiteralPath $destModule)
	$uninstallText = ""
	if (Test-Path -LiteralPath $logPath) {
		$uninstallText = (Get-Content -LiteralPath $logPath -Raw).Trim()
	}
	[pscustomobject]@{
		Exit       = $proc.ExitCode
		Result     = Read-Result $resultPath
		Copied     = $copied
		SourceRemains = Test-Path -LiteralPath (Join-Path $source "node.lib")
		Uninstall  = $uninstallText
		InstallLog = if (Test-Path -LiteralPath $installLog) { Get-Content -LiteralPath $installLog -Raw } else { "" }
	}
}

try {
	$adopt = Invoke-InnoChoice "adopt" -Found
	Assert-True ($adopt.Exit -eq 0) "adopt exits 0"
	Assert-True ($adopt.Result["action"] -eq "adopt") "adopt keeps the adopt action"
	Assert-True ($adopt.Result["copyfailed"] -eq "0" -and $adopt.Result["dropfailed"] -eq "0") "adopt copy and uninstall succeed"
	Assert-True $adopt.Copied "adopt copies Node.js and global modules into v22.14.0"
	Assert-True $adopt.SourceRemains "adopt leaves the official tree in place for uninstall"
	Assert-True ($adopt.Uninstall -match [regex]::Escape($productCode) -and $adopt.Uninstall -match "/x" -and $adopt.Uninstall -match "/qn") "adopt records a silent msiexec uninstall"

	$drop = Invoke-InnoChoice "drop" -Found
	Assert-True ($drop.Exit -eq 0) "drop exits 0"
	Assert-True ($drop.Result["action"] -eq "drop") "drop keeps the drop action"
	Assert-True ($drop.Result["copyfailed"] -eq "0" -and $drop.Result["dropfailed"] -eq "0") "drop uninstall succeeds without a copy failure"
	Assert-True (-not $drop.Copied) "drop does not copy official Node.js"
	Assert-True $drop.SourceRemains "drop leaves the official tree for the recorded uninstall"
	Assert-True ($drop.Uninstall -match [regex]::Escape($productCode) -and $drop.Uninstall -match "/x" -and $drop.Uninstall -match "/qn") "drop records a silent msiexec uninstall"

	$ignore = Invoke-InnoChoice "ignore" -Found
	Assert-True ($ignore.Exit -eq 0 -and $ignore.Result["action"] -eq "adopt" -and $ignore.Copied) "ignore is treated as adopt"

	$other = Invoke-InnoChoice "adopt-keep" -Found
	Assert-True ($other.Exit -eq 0 -and $other.Result["action"] -eq "adopt" -and $other.Copied) "unsupported values are treated as adopt"

	$absent = Invoke-InnoChoice "drop"
	Assert-True ($absent.Exit -eq 0) "missing official Node exits 0"
	Assert-True (-not $absent.Copied -and [string]::IsNullOrWhiteSpace($absent.Uninstall)) "missing official Node does not copy or uninstall"

	$broken = Invoke-InnoChoice "adopt" -Found -MissingNode
	Assert-True ($broken.Exit -eq 0) "adopt with a missing node.exe still removes official Node"
	Assert-True ($broken.Result["copyfailed"] -eq "1") "adopt records the failed copy"
	Assert-True (-not $broken.Copied) "a failed copy does not leave a Node.js version"
	Assert-True ($broken.Uninstall -match "/x") "a failed copy still uninstalls official Node"

	$noCommand = Invoke-InnoChoice "drop" -Found -SkipProduct
	Assert-True ($noCommand.Exit -ne 0) "drop without an uninstall command fails the install"
	Assert-True ($noCommand.InstallLog -match "No uninstall command") "drop without an uninstall command records the failure"
	Assert-True (-not $noCommand.Copied -and [string]::IsNullOrWhiteSpace($noCommand.Uninstall)) "a failed drop does not copy or launch uninstall"
} finally {
	if (Test-Path -LiteralPath $compileDir) {
		Remove-Item -LiteralPath $compileDir -Recurse -Force -ErrorAction SilentlyContinue
	}
}

if ($failures.Count -gt 0) {
	Write-Host ""
	Write-Host "$($failures.Count) failure(s)"
	exit 1
}

Write-Host ""
Write-Host "Inno official Node choices passed"
exit 0
