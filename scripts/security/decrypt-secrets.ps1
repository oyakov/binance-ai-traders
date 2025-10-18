<#
.SYNOPSIS
    Decrypt SOPS-encrypted environment files for deployment

.DESCRIPTION
    This script decrypts Mozilla SOPS encrypted environment files using age encryption.
    Used during deployment to VPS to access secrets.

.PARAMETER InputFile
    Path to encrypted environment file (default: testnet.env.enc)

.PARAMETER OutputFile
    Path to decrypted output file (default: testnet.env)

.PARAMETER AgeKeyFile
    Path to age private key file (default: age-key.txt or $env:SOPS_AGE_KEY_FILE)

.PARAMETER Force
    Overwrite existing plaintext file without prompting

.PARAMETER Display
    Display decrypted content without saving to file

.EXAMPLE
    .\decrypt-secrets.ps1
    Decrypts testnet.env.enc to testnet.env

.EXAMPLE
    .\decrypt-secrets.ps1 -Display
    Shows decrypted content without saving

.EXAMPLE
    .\decrypt-secrets.ps1 -AgeKeyFile "C:\secure\age-key.txt"
    Decrypts using specific age key file

.NOTES
    Author: Binance AI Traders Security Team
    Version: 1.0
    Requires: SOPS and age installed
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$InputFile = "testnet.env.enc",
    
    [Parameter()]
    [string]$OutputFile = "testnet.env",
    
    [Parameter()]
    [string]$AgeKeyFile = "",
    
    [Parameter()]
    [switch]$Force,
    
    [Parameter()]
    [switch]$Display
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
Write-ColorOutput "  Binance AI Traders - Secrets Decryption" $ColorCyan
Write-ColorOutput "═══════════════════════════════════════════════════════`n" $ColorCyan

# Check if SOPS is installed
Write-ColorOutput "Checking for SOPS installation..." $ColorYellow
try {
    $null = sops --version 2>&1
    Write-ColorOutput "✓ SOPS found" $ColorGreen
} catch {
    Write-ColorOutput "✗ SOPS not found!" $ColorRed
    Write-ColorOutput "Install with: choco install sops" $ColorYellow
    exit 1
}

# Check if input file exists
if (-not (Test-Path $InputFile)) {
    Write-ColorOutput "✗ Encrypted file not found: $InputFile" $ColorRed
    exit 1
}

Write-ColorOutput "✓ Encrypted file found: $InputFile" $ColorGreen

# Determine age key file location
if ($AgeKeyFile -eq "") {
    if ($env:SOPS_AGE_KEY_FILE) {
        $AgeKeyFile = $env:SOPS_AGE_KEY_FILE
        Write-ColorOutput "✓ Using age key from environment: $AgeKeyFile" $ColorGreen
    } elseif (Test-Path "age-key.txt") {
        $AgeKeyFile = "age-key.txt"
        Write-ColorOutput "✓ Using age key: $AgeKeyFile" $ColorGreen
    } elseif (Test-Path "$env:HOME\.age-key.txt") {
        $AgeKeyFile = "$env:HOME\.age-key.txt"
        Write-ColorOutput "✓ Using age key: $AgeKeyFile" $ColorGreen
    } else {
        Write-ColorOutput "✗ Age key file not found!" $ColorRed
        Write-ColorOutput "Specify with -AgeKeyFile or set SOPS_AGE_KEY_FILE environment variable" $ColorYellow
        exit 1
    }
}

# Verify age key file exists
if (-not (Test-Path $AgeKeyFile)) {
    Write-ColorOutput "✗ Age key file not found: $AgeKeyFile" $ColorRed
    exit 1
}

# Set environment variable for SOPS
$env:SOPS_AGE_KEY_FILE = $AgeKeyFile

# Check if output file exists (if not displaying)
if (-not $Display) {
    if ((Test-Path $OutputFile) -and -not $Force) {
        Write-ColorOutput "⚠️  Output file already exists: $OutputFile" $ColorYellow
        $response = Read-Host "Overwrite? (yes/no)"
        if ($response -ne "yes") {
            Write-ColorOutput "Operation cancelled." $ColorRed
            exit 1
        }
    }
}

# Decrypt the file
Write-ColorOutput "`nDecrypting $InputFile..." $ColorYellow

try {
    if ($Display) {
        # Display decrypted content
        Write-ColorOutput "`nDecrypted Content:" $ColorCyan
        Write-ColorOutput "─────────────────────────────────────────────────────" $ColorCyan
        $decrypted = sops --decrypt --input-type dotenv $InputFile 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            throw "Decryption failed: $decrypted"
        }
        
        # Display with masking of sensitive values
        foreach ($line in $decrypted) {
            if ($line -match '^([^=]+)=(.*)$') {
                $key = $matches[1]
                $value = $matches[2]
                
                # Mask sensitive values
                if ($key -match '(PASSWORD|SECRET|KEY|TOKEN)') {
                    $maskedValue = if ($value.Length -gt 8) {
                        $value.Substring(0, 4) + "****" + $value.Substring($value.Length - 4)
                    } else {
                        "********"
                    }
                    Write-ColorOutput "$key=$maskedValue" $ColorYellow
                } else {
                    Write-ColorOutput "$key=$value" $ColorGreen
                }
            } else {
                Write-ColorOutput $line $ColorCyan
            }
        }
        Write-ColorOutput "─────────────────────────────────────────────────────" $ColorCyan
        
    } else {
        # Decrypt to file
        $process = Start-Process -FilePath "sops" `
            -ArgumentList "--decrypt", "--input-type", "dotenv", "--output-type", "dotenv", $InputFile `
            -RedirectStandardOutput $OutputFile `
            -RedirectStandardError "sops_error.txt" `
            -NoNewWindow `
            -Wait `
            -PassThru
        
        if ($process.ExitCode -ne 0) {
            $errorContent = Get-Content "sops_error.txt" -Raw
            throw "SOPS decryption failed: $errorContent"
        }
        
        # Clean up error file
        if (Test-Path "sops_error.txt") {
            Remove-Item "sops_error.txt" -Force
        }
        
        Write-ColorOutput "✓ Decryption successful!" $ColorGreen
        
        # Set restrictive permissions on plaintext file
        try {
            $acl = Get-Acl $OutputFile
            $acl.SetAccessRuleProtection($true, $false)
            $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                $env:USERNAME,
                "FullControl",
                "Allow"
            )
            $acl.SetAccessRule($accessRule)
            Set-Acl $OutputFile $acl
            Write-ColorOutput "✓ Restrictive permissions set on $OutputFile" $ColorGreen
        } catch {
            Write-ColorOutput "⚠️  Warning: Could not set restrictive permissions: $_" $ColorYellow
        }
        
        # Get file sizes
        $inputSize = (Get-Item $InputFile).Length
        $outputSize = (Get-Item $OutputFile).Length
        
        Write-ColorOutput "`nFile Information:" $ColorCyan
        Write-ColorOutput "  Input:  $InputFile ($inputSize bytes)" $ColorCyan
        Write-ColorOutput "  Output: $OutputFile ($outputSize bytes)" $ColorCyan
    }
    
} catch {
    Write-ColorOutput "✗ Decryption failed: $_" $ColorRed
    exit 1
}

if (-not $Display) {
    # Security warnings
    Write-ColorOutput "`n═══════════════════════════════════════════════════════" $ColorGreen
    Write-ColorOutput "  Decryption Complete!" $ColorGreen
    Write-ColorOutput "═══════════════════════════════════════════════════════`n" $ColorGreen

    Write-ColorOutput "⚠️  SECURITY WARNINGS:" $ColorYellow
    Write-ColorOutput "  1. Plaintext file contains sensitive secrets!" $ColorRed
    Write-ColorOutput "  2. DO NOT commit $OutputFile to git" $ColorRed
    Write-ColorOutput "  3. Delete $OutputFile after deployment" $ColorYellow
    Write-ColorOutput "  4. Keep age-key.txt in secure location" $ColorYellow
    Write-ColorOutput "  5. Use secrets only on secure deployment server" $ColorYellow

    Write-ColorOutput "`n📋 DEPLOYMENT USAGE:" $ColorCyan
    Write-ColorOutput "  docker compose --env-file $OutputFile up -d" $ColorCyan

    Write-ColorOutput "`n🗑️  CLEANUP AFTER DEPLOYMENT:" $ColorCyan
    Write-ColorOutput "  Remove-Item $OutputFile -Force" $ColorCyan
}

Write-ColorOutput "`n✓ Operation complete!`n" $ColorGreen

exit 0

