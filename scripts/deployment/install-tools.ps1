<#
.SYNOPSIS
    Install SOPS and age for deployment (REQUIRES ADMINISTRATOR)

.DESCRIPTION
    Installs SOPS via Chocolatey and age from GitHub releases.
    Must be run as Administrator.

.EXAMPLE
    # Right-click PowerShell, "Run as Administrator", then:
    Set-ExecutionPolicy Bypass -Scope Process -Force
    .\scripts\deployment\install-tools.ps1
#>

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host ""
    Write-Host "===============================================================" -ForegroundColor Red
    Write-Host "  ERROR: This script requires Administrator privileges!" -ForegroundColor Red
    Write-Host "===============================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please:" -ForegroundColor Yellow
    Write-Host "  1. Close this PowerShell window" -ForegroundColor White
    Write-Host "  2. Right-click PowerShell" -ForegroundColor White
    Write-Host "  3. Select 'Run as Administrator'" -ForegroundColor White
    Write-Host "  4. Run this script again" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "  Installing Deployment Tools (SOPS & age)" -ForegroundColor Green
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host ""

# Clean up Chocolatey lock files
Write-Host "Step 1: Cleaning up Chocolatey..." -ForegroundColor Yellow
$lockFiles = @(
    "C:\ProgramData\chocolatey\lib\998192b223a7e8576088e8ca4d22da7826387c75",
    "C:\ProgramData\chocolatey\lib\.lock"
)

foreach ($lockFile in $lockFiles) {
    if (Test-Path $lockFile) {
        try {
            Remove-Item $lockFile -Force -ErrorAction Stop
            Write-Host "  Removed lock: $(Split-Path $lockFile -Leaf)" -ForegroundColor Gray
        } catch {
            Write-Host "  Lock file not found (OK)" -ForegroundColor Gray
        }
    }
}

# Clean up lib-bad
if (Test-Path "C:\ProgramData\chocolatey\lib-bad") {
    try {
        Remove-Item "C:\ProgramData\chocolatey\lib-bad" -Recurse -Force -ErrorAction Stop
        Write-Host "  Removed lib-bad directory" -ForegroundColor Gray
    } catch {
        # Ignore
    }
}

Write-Host "  Cleanup complete!" -ForegroundColor Green
Write-Host ""

# Install SOPS via Chocolatey
Write-Host "Step 2: Installing SOPS..." -ForegroundColor Yellow

try {
    $sopsCheck = Get-Command sops -ErrorAction SilentlyContinue
    if ($sopsCheck) {
        Write-Host "  SOPS already installed: $($sopsCheck.Version)" -ForegroundColor Green
    } else {
        choco install sops -y --force
        Write-Host "  SOPS installed successfully!" -ForegroundColor Green
    }
} catch {
    Write-Host "  Error installing SOPS: $_" -ForegroundColor Red
    Write-Host "  Try manually: choco install sops -y --force" -ForegroundColor Yellow
}

Write-Host ""

# Install age from GitHub (not available in Chocolatey)
Write-Host "Step 3: Installing age..." -ForegroundColor Yellow

try {
    $ageCheck = Get-Command age -ErrorAction SilentlyContinue
    if ($ageCheck) {
        Write-Host "  age already installed!" -ForegroundColor Green
    } else {
        Write-Host "  Downloading age from GitHub..." -ForegroundColor Gray
        
        # Download latest age release for Windows
        $ageVersion = "v1.1.1"
        $ageUrl = "https://github.com/FiloSottile/age/releases/download/$ageVersion/age-$ageVersion-windows-amd64.zip"
        $tempZip = "$env:TEMP\age.zip"
        $tempExtract = "$env:TEMP\age"
        
        # Download
        Invoke-WebRequest -Uri $ageUrl -OutFile $tempZip -UseBasicParsing
        Write-Host "  Downloaded age $ageVersion" -ForegroundColor Gray
        
        # Extract
        Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force
        
        # Find the age directory (it's nested)
        $ageDir = Get-ChildItem -Path $tempExtract -Directory | Select-Object -First 1
        
        # Copy to Program Files
        $installPath = "C:\Program Files\age"
        if (-not (Test-Path $installPath)) {
            New-Item -ItemType Directory -Path $installPath -Force | Out-Null
        }
        
        Copy-Item "$($ageDir.FullName)\*" -Destination $installPath -Force
        Write-Host "  Installed to: $installPath" -ForegroundColor Gray
        
        # Add to PATH
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
        if ($currentPath -notlike "*$installPath*") {
            [Environment]::SetEnvironmentVariable("Path", "$currentPath;$installPath", "Machine")
            $env:Path = "$env:Path;$installPath"
            Write-Host "  Added to system PATH" -ForegroundColor Gray
        }
        
        # Cleanup
        Remove-Item $tempZip -Force -ErrorAction SilentlyContinue
        Remove-Item $tempExtract -Recurse -Force -ErrorAction SilentlyContinue
        
        Write-Host "  age installed successfully!" -ForegroundColor Green
    }
} catch {
    Write-Host "  Error installing age: $_" -ForegroundColor Red
    Write-Host "  Manual installation:" -ForegroundColor Yellow
    Write-Host "    1. Download from: https://github.com/FiloSottile/age/releases" -ForegroundColor White
    Write-Host "    2. Extract age.exe and age-keygen.exe" -ForegroundColor White
    Write-Host "    3. Copy to C:\Program Files\age\" -ForegroundColor White
    Write-Host "    4. Add to PATH" -ForegroundColor White
}

Write-Host ""
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "  Verifying Installation" -ForegroundColor Green
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host ""

# Verify SOPS
Write-Host "Checking SOPS..." -ForegroundColor Yellow
try {
    $sopsVersion = sops --version 2>&1
    Write-Host "  SOPS: $sopsVersion" -ForegroundColor Green
    $sopsInstalled = $true
} catch {
    Write-Host "  SOPS: NOT FOUND" -ForegroundColor Red
    $sopsInstalled = $false
}

# Verify age
Write-Host "Checking age..." -ForegroundColor Yellow
try {
    $ageVersion = age --version 2>&1
    Write-Host "  age: $ageVersion" -ForegroundColor Green
    $ageInstalled = $true
} catch {
    Write-Host "  age: NOT FOUND (try restarting PowerShell)" -ForegroundColor Yellow
    $ageInstalled = $false
}

Write-Host ""

if ($sopsInstalled -and $ageInstalled) {
    Write-Host "===============================================================" -ForegroundColor Green
    Write-Host "  SUCCESS! All tools installed" -ForegroundColor Green
    Write-Host "===============================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Close this Administrator PowerShell" -ForegroundColor White
    Write-Host "  2. Open a NEW PowerShell (normal, not admin)" -ForegroundColor White
    Write-Host "  3. cd C:\Projects\binance-ai-traders" -ForegroundColor White
    Write-Host "  4. Run: .\scripts\deployment\step-by-step-deploy.ps1" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "===============================================================" -ForegroundColor Yellow
    Write-Host "  PARTIAL SUCCESS - Some tools missing" -ForegroundColor Yellow
    Write-Host "===============================================================" -ForegroundColor Yellow
    Write-Host ""
    if (-not $ageInstalled) {
        Write-Host "age may need a PowerShell restart to be available." -ForegroundColor Yellow
        Write-Host "Close this window and open a new PowerShell to test." -ForegroundColor White
    }
    Write-Host ""
}

