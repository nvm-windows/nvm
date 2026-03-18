# setup-test-env.ps1
param(
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'

# Detect if we are dot-sourced (caller used ". .\setup-test-env.ps1")
$dotSourced = $MyInvocation.InvocationName -eq '.'

if (-not $Quiet) {
    Write-Host "Setting up NVM test-env..." -ForegroundColor Cyan
}

# Paths
$repoRoot = Get-Location
$distPath = Join-Path $repoRoot 'dist'
$assetsPath = Join-Path $repoRoot 'assets'
$testEnvPath = Join-Path $repoRoot 'test-env'
$nodejsPath = Join-Path $testEnvPath 'nodejs'
$settingsPath = Join-Path $testEnvPath 'settings.txt'

# Ensure test-env exists and is clean
if (Test-Path $testEnvPath) {
    Remove-Item -Recurse -Force $testEnvPath
}
New-Item -ItemType Directory -Path $testEnvPath | Out-Null

# Copy everything from dist into test-env
if (-not (Test-Path $distPath)) {
    throw "dist folder not found at $distPath. Build nvm.exe first."
}
Copy-Item -Path (Join-Path $distPath '*') -Destination $testEnvPath -Recurse -Force

# Copy elevation/helper scripts from assets into test-env (if present)
if (Test-Path $assetsPath) {
    Get-ChildItem $assetsPath -Include *.cmd, *.vbs -File |
    Copy-Item -Destination $testEnvPath -Force
}

# Write settings.txt into test-env
@"
root: $testEnvPath
path: $nodejsPath
arch: 64
proxy: none
"@ | Set-Content -Encoding ASCII $settingsPath

# Set env vars and PATH for this process
$env:NVM_HOME = $testEnvPath
$env:NVM_SYMLINK = $nodejsPath
$env:PATH = "$testEnvPath;$nodejsPath;$env:PATH"

if (-not $Quiet) {
    Write-Host "NVM_HOME   = $env:NVM_HOME"
    Write-Host "NVM_SYMLINK= $env:NVM_SYMLINK"
    Write-Host "settings.txt written to $settingsPath" -ForegroundColor Green
    Write-Host ""
}

# If dot-sourced, change directory and stay in this session
if ($dotSourced) {
    Set-Location $testEnvPath
    if (-not $Quiet) {
        Write-Host "Now in test-env: $(Get-Location)"
        Write-Host "Run:"
        Write-Host "  .\nvm.exe install 20.20.1"
        Write-Host "  .\nvm.exe use 20.20.1"
        Write-Host "  node -v"
    }
}
else {
    # Not dot-sourced: just print instructions
    if (-not $Quiet) {
        Write-Host ""
        Write-Host "Test env prepared at: $testEnvPath"
        Write-Host "To activate it in your current shell, run:" -ForegroundColor Yellow
        Write-Host "  `.` .\setup-test-env.ps1"
    }
}
