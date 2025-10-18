<#
.SYNOPSIS
    Encrypt environment files using Mozilla SOPS with age encryption

.DESCRIPTION
    This script encrypts sensitive environment files (testnet.env) using Mozilla SOPS
    and age encryption. The encrypted files can be safely committed to git.

.PARAMETER InputFile
    Path to plaintext environment file (default: testnet.env)

.PARAMETER OutputFile
    Path to encrypted output file (default: testnet.env.enc)

.PARAMETER Force
    Overwrite existing encrypted file without prompting

.PARAMETER Verify
    Verify encryption by attempting to decrypt after encryption

.EXAMPLE
    .\encrypt-secrets.ps1
    Encrypts testnet.env to testnet.env.enc

.EXAMPLE
    .\encrypt-secrets.ps1 -InputFile "production.env" -OutputFile "production.env.enc"
    Encrypts production environment file

.EXAMPLE
    .\encrypt-secrets.ps1 -Force -Verify
    Force overwrite and verify encryption

.NOTES
    Author: Binance AI Traders Security Team
    Version: 1.0
    Requires: SOPS and age installed (choco install sops age)
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$InputFile = "testnet.env",
    
    [Parameter()]
    [string]$OutputFile = "testnet.env.enc",
    
    [Parameter()]
    [switch]$Force,
    
    [Parameter()]
    [switch]$Verify
)

# Set strict mode
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Colors for output
$ColorReset = "`e[0m"
$ColorGreen = "`e[32m"
$ColorYellow = "`e[33m"
$ColorRed = "`e[31m"
$ColorCyan = "`e[36m"

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = $ColorReset
    )
    Write-Host "${Color}${Message}${ColorReset}"
}

# Main script
Write-ColorOutput "`n═══════════════════════════════════════════════════════" $ColorCyan
Write-ColorOutput "  Binance AI Traders - Secrets Encryption" $ColorCyan
Write-ColorOutput "═══════════════════════════════════════════════════════`n" $ColorCyan

# Check if SOPS is installed
Write-ColorOutput "Checking for SOPS installation..." $ColorYellow
try {
    $sopsVersion = sops --version 2>&1
    Write-ColorOutput "✓ SOPS found: $sopsVersion" $ColorGreen
} catch {
    Write-ColorOutput "✗ SOPS not found!" $ColorRed
    Write-ColorOutput "Install with: choco install sops" $ColorYellow
    exit 1
}

# Check if age is installed
Write-ColorOutput "Checking for age installation..." $ColorYellow
try {
    $ageVersion = age --version 2>&1
    Write-ColorOutput "✓ age found: $ageVersion" $ColorGreen
} catch {
    Write-ColorOutput "✗ age not found!" $ColorRed
    Write-ColorOutput "Install with: choco install age" $ColorYellow
    exit 1
}

# Check if .sops.yaml exists
$sopsConfigPath = ".sops.yaml"
if (-not (Test-Path $sopsConfigPath)) {
    Write-ColorOutput "✗ .sops.yaml configuration not found!" $ColorRed
    Write-ColorOutput "Create .sops.yaml with your age public key first." $ColorYellow
    exit 1
}

Write-ColorOutput "✓ .sops.yaml configuration found" $ColorGreen

# Check if input file exists
if (-not (Test-Path $InputFile)) {
    Write-ColorOutput "✗ Input file not found: $InputFile" $ColorRed
    Write-ColorOutput "Create $InputFile with your secrets first." $ColorYellow
    Write-ColorOutput "Use template: cp testnet.env.template $InputFile" $ColorYellow
    exit 1
}

Write-ColorOutput "✓ Input file found: $InputFile" $ColorGreen

# Read .sops.yaml to verify age key is configured
$sopsConfig = Get-Content $sopsConfigPath -Raw
if ($sopsConfig -match 'age1xxxx') {
    Write-ColorOutput "⚠️  WARNING: Default age key detected in .sops.yaml!" $ColorYellow
    Write-ColorOutput "Replace 'age1xxxx...' with your actual age public key." $ColorYellow
    $response = Read-Host "Continue anyway? (yes/no)"
    if ($response -ne "yes") {
        Write-ColorOutput "Operation cancelled." $ColorRed
        exit 1
    }
}

# Check for sensitive data in input file
Write-ColorOutput "`nScanning input file for sensitive data..." $ColorYellow
$content = Get-Content $InputFile -Raw
$hasSecrets = $false

$sensitivePatterns = @{
    "API Keys" = 'API_KEY=(?!<)[^\s]+'
    "Passwords" = 'PASSWORD=(?!<)[^\s]+'
    "Tokens" = 'TOKEN=(?!<)[^\s]+'
    "Secrets" = 'SECRET=(?!<)[^\s]+'
}

foreach ($pattern in $sensitivePatterns.Keys) {
    if ($content -match $sensitivePatterns[$pattern]) {
        Write-ColorOutput "  ✓ Found $pattern" $ColorGreen
        $hasSecrets = $true
    }
}

if (-not $hasSecrets) {
    Write-ColorOutput "⚠️  WARNING: No secrets found in input file!" $ColorYellow
    Write-ColorOutput "File may still contain template placeholders." $ColorYellow
    $response = Read-Host "Continue encryption anyway? (yes/no)"
    if ($response -ne "yes") {
        Write-ColorOutput "Operation cancelled." $ColorRed
        exit 1
    }
}

# Check if output file exists
if ((Test-Path $OutputFile) -and -not $Force) {
    Write-ColorOutput "⚠️  Output file already exists: $OutputFile" $ColorYellow
    $response = Read-Host "Overwrite? (yes/no)"
    if ($response -ne "yes") {
        Write-ColorOutput "Operation cancelled." $ColorRed
        exit 1
    }
}

# Encrypt the file
Write-ColorOutput "`nEncrypting $InputFile..." $ColorYellow

try {
    # Run SOPS encryption
    $process = Start-Process -FilePath "sops" `
        -ArgumentList "--encrypt", "--input-type", "dotenv", "--output-type", "dotenv", $InputFile `
        -RedirectStandardOutput $OutputFile `
        -RedirectStandardError "sops_error.txt" `
        -NoNewWindow `
        -Wait `
        -PassThru
    
    if ($process.ExitCode -ne 0) {
        $errorContent = Get-Content "sops_error.txt" -Raw
        throw "SOPS encryption failed: $errorContent"
    }
    
    # Clean up error file
    if (Test-Path "sops_error.txt") {
        Remove-Item "sops_error.txt" -Force
    }
    
    Write-ColorOutput "✓ Encryption successful!" $ColorGreen
    
    # Get file sizes
    $inputSize = (Get-Item $InputFile).Length
    $outputSize = (Get-Item $OutputFile).Length
    
    Write-ColorOutput "`nFile Information:" $ColorCyan
    Write-ColorOutput "  Input:  $InputFile ($inputSize bytes)" $ColorCyan
    Write-ColorOutput "  Output: $OutputFile ($outputSize bytes)" $ColorCyan
    
} catch {
    Write-ColorOutput "✗ Encryption failed: $_" $ColorRed
    exit 1
}

# Verify encryption if requested
if ($Verify) {
    Write-ColorOutput "`nVerifying encryption..." $ColorYellow
    
    try {
        # Try to decrypt (without saving)
        $decrypted = sops --decrypt --input-type dotenv $OutputFile 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✓ Verification successful - file can be decrypted" $ColorGreen
            
            # Check if decrypted content matches original (basic check)
            $originalLines = (Get-Content $InputFile | Where-Object { $_ -match '=' }).Count
            $decryptedLines = ($decrypted | Where-Object { $_ -match '=' }).Count
            
            if ($originalLines -eq $decryptedLines) {
                Write-ColorOutput "✓ Content integrity verified" $ColorGreen
            } else {
                Write-ColorOutput "⚠️  Line count mismatch - manual verification recommended" $ColorYellow
            }
        } else {
            Write-ColorOutput "✗ Verification failed - file may be corrupted" $ColorRed
            exit 1
        }
        
    } catch {
        Write-ColorOutput "✗ Verification error: $_" $ColorRed
        exit 1
    }
}

# Security recommendations
Write-ColorOutput "`n═══════════════════════════════════════════════════════" $ColorGreen
Write-ColorOutput "  Encryption Complete!" $ColorGreen
Write-ColorOutput "═══════════════════════════════════════════════════════`n" $ColorGreen

Write-ColorOutput "⚠️  IMPORTANT SECURITY STEPS:" $ColorYellow
Write-ColorOutput "  1. ✓ Encrypted file created: $OutputFile" $ColorGreen
Write-ColorOutput "  2. ⚠️  Delete plaintext file: Remove-Item $InputFile" $ColorYellow
Write-ColorOutput "  3. ✓ Commit encrypted file: git add $OutputFile" $ColorGreen
Write-ColorOutput "  4. ⚠️  NEVER commit plaintext: Verify with git status" $ColorYellow
Write-ColorOutput "  5. 🔐 Store age-key.txt securely (password manager)" $ColorYellow
Write-ColorOutput "  6. 📋 Document key location for team members" $ColorCyan

Write-ColorOutput "`n📋 DEPLOYMENT STEPS:" $ColorCyan
Write-ColorOutput "  1. Transfer $OutputFile to VPS" $ColorCyan
Write-ColorOutput "  2. Transfer age-key.txt to VPS (secure channel only)" $ColorCyan
Write-ColorOutput "  3. Decrypt on VPS: sops -d $OutputFile > $InputFile" $ColorCyan
Write-ColorOutput "  4. Deploy: docker compose --env-file $InputFile up -d" $ColorCyan

Write-ColorOutput "`n✓ Ready for secure deployment!`n" $ColorGreen

# Prompt to delete plaintext file
$response = Read-Host "Delete plaintext file $InputFile now for security? (yes/no)"
if ($response -eq "yes") {
    try {
        Remove-Item $InputFile -Force
        Write-ColorOutput "✓ Plaintext file deleted" $ColorGreen
    } catch {
        Write-ColorOutput "✗ Failed to delete: $_" $ColorRed
    }
} else {
    Write-ColorOutput "⚠️  Remember to delete $InputFile before committing!" $ColorYellow
}

exit 0

