<#
.SYNOPSIS
    Install SOPS and age with administrator privileges

.DESCRIPTION
    This script must be run as Administrator to install required tools.
    It will install SOPS and age for secrets encryption.

.EXAMPLE
    # Right-click PowerShell and "Run as Administrator", then:
    .\scripts\deployment\install-tools-admin.ps1
#>

#Requires -RunAsAdministrator

Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "  Installing Deployment Tools (SOPS & age)" -ForegroundColor Green
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host ""

# Clean up any stale Chocolatey locks
Write-Host "Cleaning up Chocolatey locks..." -ForegroundColor Yellow
$lockFiles = @(
    "C:\ProgramData\chocolatey\lib\998192b223a7e8576088e8ca4d22da7826387c75",
    "C:\ProgramData\chocolatey\lib\.lock"
)

foreach ($lockFile in $lockFiles) {
    if (Test-Path $lockFile) {
        try {
            Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
            Write-Host "  Removed lock file: $lockFile" -ForegroundColor Gray
        } catch {
            Write-Host "  Could not remove: $lockFile (may not exist)" -ForegroundColor Gray
        }
    }
}

# Clean up lib-bad directory
$libBad = "C:\ProgramData\chocolatey\lib-bad"
if (Test-Path $libBad) {
    try {
        Remove-Item $libBad -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  Removed lib-bad directory" -ForegroundColor Gray
    } catch {
        Write-Host "  Could not remove lib-bad (may not exist)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "Installing SOPS..." -ForegroundColor Yellow

try {
    choco install sops -y
    Write-Host "  SOPS installed successfully!" -ForegroundColor Green
} catch {
    Write-Host "  Error installing SOPS: $_" -ForegroundColor Red
    Write-Host "  Try manually: choco install sops -y --force" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Installing age..." -ForegroundColor Yellow

try {
    choco install age -y
    Write-Host "  age installed successfully!" -ForegroundColor Green
} catch {
    Write-Host "  Error installing age: $_" -ForegroundColor Red
    Write-Host "  Try manually: choco install age -y --force" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "  Verifying Installation" -ForegroundColor Green
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host ""

# Verify SOPS
try {
    $sopsVersion = sops --version 2>&1
    Write-Host "  SOPS: $sopsVersion" -ForegroundColor Green
} catch {
    Write-Host "  SOPS: NOT FOUND" -ForegroundColor Red
}

# Verify age
try {
    $ageVersion = age --version 2>&1
    Write-Host "  age: $ageVersion" -ForegroundColor Green
} catch {
    Write-Host "  age: NOT FOUND" -ForegroundColor Red
}

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next step: Run the deployment script" -ForegroundColor Yellow
Write-Host "  .\scripts\deployment\step-by-step-deploy.ps1" -ForegroundColor White
Write-Host ""

