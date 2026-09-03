$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$setupPath = Join-Path $repoRoot 'installer\setup.iss'
$setup = Get-Content -LiteralPath $setupPath -Raw

function Assert-Contract([bool]$Condition, [string]$Message) {
    if (-not $Condition) {
        throw "Zero-admin installer contract failed: $Message"
    }
}

Assert-Contract ($setup -match '(?m)^PrivilegesRequired=lowest\s*$') 'installer must use lowest privileges'
Assert-Contract ($setup -match '(?m)^DefaultDirName=\{localappdata\}') 'default application directory must be user-local'
Assert-Contract ($setup -match '(?m)^Root: HKCU;') 'installer must contain user-scoped registry configuration'
Assert-Contract ($setup -notmatch "ShellExec\(\s*\r?\n\s*'runas'") 'normal installer flow must not invoke runas'
Assert-Contract ($setup -notmatch "RegDeleteValue\(HKLM") 'normal installer flow must not delete machine environment values'
Assert-Contract ($setup -notmatch 'Registering Windows Event Log source') 'normal installer flow must not register Event Log sources'
Assert-Contract ($setup -notmatch 'RunUpgraderHelper\(\)') 'normal installer flow must not invoke the privileged v1 upgrader'
Assert-Contract ($setup -match 'DetectLegacyMachineState\(\)') 'v1 migration must inspect machine-level leftovers'
Assert-Contract ($setup -match 'administrator permission is required') 'machine-level leftovers must explain why they remain'
Assert-Contract ($setup -match 'EscapeSingleQuotedPowerShellString\(NodePath\)') 'junction target paths must escape PowerShell apostrophes'
Assert-Contract ($setup -match 'EscapeSingleQuotedPowerShellString\(ShimPath\)') 'shim paths must escape PowerShell apostrophes'

Write-Host 'Zero-admin installer contract passed.'
