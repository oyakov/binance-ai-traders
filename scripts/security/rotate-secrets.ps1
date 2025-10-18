<#
.SYNOPSIS
    Rotate secrets and credentials for binance-ai-traders

.DESCRIPTION
    This script facilitates secure rotation of passwords, tokens, and API keys.
    Recommended to run every 90 days or immediately after a security incident.

.PARAMETER RotateAll
    Rotate all secrets (passwords, tokens, API keys)

.PARAMETER RotatePasswords
    Rotate only database and service passwords

.PARAMETER RotateApiKeys
    Rotate only API keys

.PARAMETER RotateTokens
    Rotate only authentication tokens

.PARAMETER BackupExisting
    Create backup of current secrets before rotation

.EXAMPLE
    .\rotate-secrets.ps1 -RotateAll -BackupExisting
    Rotates all secrets and creates backup

.EXAMPLE
    .\rotate-secrets.ps1 -RotatePasswords
    Rotates only passwords

.NOTES
    Author: Binance AI Traders Security Team
    Version: 1.0
    Requires: Active deployment for rotation
#>

[CmdletBinding()]
param(
    [Parameter()]
    [switch]$RotateAll,
    
    [Parameter()]
    [switch]$RotatePasswords,
    
    [Parameter()]
    [switch]$RotateApiKeys,
    
    [Parameter()]
    [switch]$RotateTokens,
    
    [Parameter()]
    [switch]$BackupExisting
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
Write-ColorOutput "  Binance AI Traders - Secret Rotation" $ColorCyan
Write-ColorOutput "═══════════════════════════════════════════════════════`n" $ColorCyan

# If no specific rotation specified, default to RotateAll
if (-not ($RotateAll -or $RotatePasswords -or $RotateApiKeys -or $RotateTokens)) {
    Write-ColorOutput "⚠️  No rotation type specified. Use -RotateAll or specific flags." $ColorYellow
    Write-ColorOutput "`nAvailable options:" $ColorCyan
    Write-ColorOutput "  -RotateAll         Rotate everything" $ColorCyan
    Write-ColorOutput "  -RotatePasswords   Rotate service passwords only" $ColorCyan
    Write-ColorOutput "  -RotateApiKeys     Rotate API keys only" $ColorCyan
    Write-ColorOutput "  -RotateTokens      Rotate auth tokens only" $ColorCyan
    Write-ColorOutput "  -BackupExisting    Create backup before rotation" $ColorCyan
    exit 1
}

# Warning about the impact
Write-ColorOutput "⚠️  WARNING: Secret rotation requires service restart!" $ColorYellow
Write-ColorOutput "This operation will:" $ColorYellow
Write-ColorOutput "  1. Generate new secrets" $ColorYellow
Write-ColorOutput "  2. Update configuration files" $ColorYellow
Write-ColorOutput "  3. Require service restart to apply changes" $ColorYellow
Write-ColorOutput "  4. Potentially cause brief downtime" $ColorYellow

$response = Read-Host "`nContinue with rotation? (yes/no)"
if ($response -ne "yes") {
    Write-ColorOutput "Operation cancelled." $ColorRed
    exit 0
}

# Check if encrypted file exists
$encryptedFile = "testnet.env.enc"
if (-not (Test-Path $encryptedFile)) {
    Write-ColorOutput "✗ Encrypted file not found: $encryptedFile" $ColorRed
    Write-ColorOutput "Run this script from repository root." $ColorYellow
    exit 1
}

# Backup existing secrets if requested
if ($BackupExisting) {
    Write-ColorOutput "`nCreating backup of existing secrets..." $ColorYellow
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFile = "testnet.env.enc.backup_$timestamp"
    
    try {
        Copy-Item $encryptedFile $backupFile
        Write-ColorOutput "✓ Backup created: $backupFile" $ColorGreen
    } catch {
        Write-ColorOutput "✗ Backup failed: $_" $ColorRed
        exit 1
    }
}

# Decrypt existing file
Write-ColorOutput "`nDecrypting existing secrets..." $ColorYellow
try {
    $decryptScript = Join-Path $PSScriptRoot "decrypt-secrets.ps1"
    & $decryptScript -Force
} catch {
    Write-ColorOutput "✗ Decryption failed: $_" $ColorRed
    exit 1
}

# Load existing secrets
$envFile = "testnet.env"
if (-not (Test-Path $envFile)) {
    Write-ColorOutput "✗ Decrypted file not found: $envFile" $ColorRed
    exit 1
}

$existingSecrets = @{}
Get-Content $envFile | ForEach-Object {
    if ($_ -match '^([^=]+)=(.*)$') {
        $existingSecrets[$matches[1]] = $matches[2]
    }
}

# Generate new secrets based on rotation type
$newSecrets = @{}

if ($RotateAll -or $RotatePasswords) {
    Write-ColorOutput "`nGenerating new passwords..." $ColorYellow
    
    # Generate new passwords
    $setupScript = Join-Path $PSScriptRoot "setup-secrets.ps1"
    $tempOutput = New-TemporaryFile
    
    & $setupScript -OutputFile $tempOutput.FullName -Length 32
    
    # Read generated passwords
    Get-Content $tempOutput.FullName | ForEach-Object {
        if ($_ -match '^(.*PASSWORD|.*SECRET)=(.*)$') {
            $newSecrets[$matches[1]] = $matches[2]
        }
    }
    
    Remove-Item $tempOutput.FullName -Force
    Write-ColorOutput "✓ New passwords generated" $ColorGreen
}

if ($RotateAll -or $RotateApiKeys) {
    Write-ColorOutput "`nGenerating new API keys..." $ColorYellow
    
    $setupScript = Join-Path $PSScriptRoot "setup-secrets.ps1"
    $tempOutput = New-TemporaryFile
    
    & $setupScript -GenerateApiKeys -OutputFile $tempOutput.FullName
    
    # Read generated API keys
    Get-Content $tempOutput.FullName | ForEach-Object {
        if ($_ -match '^(API_KEY_.*)=(.*)$') {
            $newSecrets[$matches[1]] = $matches[2]
        }
    }
    
    Remove-Item $tempOutput.FullName -Force
    Write-ColorOutput "✓ New API keys generated" $ColorGreen
}

if ($RotateAll -or $RotateTokens) {
    Write-ColorOutput "`nGenerating new tokens..." $ColorYellow
    
    # Generate new tokens
    $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    $tokenKeys = @('PROMETHEUS_BEARER_TOKEN', 'SESSION_SECRET')
    
    foreach ($key in $tokenKeys) {
        $token = -join ((1..64) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
        $newSecrets[$key] = $token
    }
    
    Write-ColorOutput "✓ New tokens generated" $ColorGreen
}

# Create updated environment file
Write-ColorOutput "`nCreating updated environment file..." $ColorYellow

$updatedContent = Get-Content $envFile
foreach ($key in $newSecrets.Keys) {
    $updatedContent = $updatedContent -replace "^$key=.*", "$key=$($newSecrets[$key])"
}

# Save updated file
Set-Content -Path $envFile -Value $updatedContent -NoNewline

# Display rotation summary
Write-ColorOutput "`n═══════════════════════════════════════════════════════" $ColorGreen
Write-ColorOutput "  Rotation Summary" $ColorGreen
Write-ColorOutput "═══════════════════════════════════════════════════════`n" $ColorGreen

Write-ColorOutput "Rotated secrets:" $ColorCyan
foreach ($key in $newSecrets.Keys | Sort-Object) {
    Write-ColorOutput "  ✓ $key" $ColorGreen
}

Write-ColorOutput "`n📋 NEXT STEPS:" $ColorYellow
Write-ColorOutput "  1. Review updated testnet.env file" $ColorYellow
Write-ColorOutput "  2. Encrypt: .\scripts\security\encrypt-secrets.ps1 -Force" $ColorYellow
Write-ColorOutput "  3. Commit: git add testnet.env.enc && git commit -m 'Rotate secrets'" $ColorYellow
Write-ColorOutput "  4. Deploy: Transfer to VPS and restart services" $ColorYellow
Write-ColorOutput "  5. Verify: Test all services after restart" $ColorYellow
Write-ColorOutput "  6. Update: Update any external systems using these secrets" $ColorYellow

Write-ColorOutput "`n⚠️  IMPORTANT:" $ColorRed
Write-ColorOutput "  - Service restart required for changes to take effect" $ColorRed
Write-ColorOutput "  - Update Binance API keys manually if rotated" $ColorRed
Write-ColorOutput "  - Update monitoring alerts if token rotated" $ColorRed
Write-ColorOutput "  - Document rotation in change log" $ColorYellow

Write-ColorOutput "`n✓ Secret rotation complete!`n" $ColorGreen

exit 0

