<#
.SYNOPSIS
    Generate strong random passwords and API keys for binance-ai-traders deployment

.DESCRIPTION
    This script generates cryptographically secure random passwords and API keys
    for all services in the binance-ai-traders stack. Values can be manually
    added to testnet.env or automatically updated.

.PARAMETER GenerateApiKeys
    Generate API keys in format: btai_testnet_<32-random-chars>

.PARAMETER OutputFile
    Path to output environment file (default: testnet.env)

.PARAMETER Length
    Password length (default: 32, minimum: 24)

.EXAMPLE
    .\setup-secrets.ps1
    Generates all secrets and displays them

.EXAMPLE
    .\setup-secrets.ps1 -GenerateApiKeys
    Generates secrets including API keys

.EXAMPLE
    .\setup-secrets.ps1 -OutputFile "testnet.env" -Length 64
    Generates 64-character secrets and saves to testnet.env

.NOTES
    Author: Binance AI Traders Security Team
    Version: 1.0
    Requires: PowerShell 5.1 or higher
#>

[CmdletBinding()]
param(
    [Parameter()]
    [switch]$GenerateApiKeys,
    
    [Parameter()]
    [string]$OutputFile = "",
    
    [Parameter()]
    [ValidateRange(24, 128)]
    [int]$Length = 32
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

function Generate-SecurePassword {
    param(
        [int]$PasswordLength = 32
    )
    
    # Character sets
    $lowercase = 'abcdefghijklmnopqrstuvwxyz'
    $uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    $numbers = '0123456789'
    $symbols = '!@#$%^&*()_+-=[]{}|;:,.<>?'
    
    # Ensure at least one character from each set
    $password = @()
    $password += $lowercase[(Get-Random -Maximum $lowercase.Length)]
    $password += $uppercase[(Get-Random -Maximum $uppercase.Length)]
    $password += $numbers[(Get-Random -Maximum $numbers.Length)]
    $password += $symbols[(Get-Random -Maximum $symbols.Length)]
    
    # Fill remaining length with random characters from all sets
    $allChars = $lowercase + $uppercase + $numbers + $symbols
    for ($i = $password.Count; $i -lt $PasswordLength; $i++) {
        $password += $allChars[(Get-Random -Maximum $allChars.Length)]
    }
    
    # Shuffle the password array
    $password = $password | Get-Random -Count $password.Count
    
    return -join $password
}

function Generate-AlphanumericToken {
    param(
        [int]$TokenLength = 32
    )
    
    $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    $token = @()
    
    for ($i = 0; $i -lt $TokenLength; $i++) {
        $token += $chars[(Get-Random -Maximum $chars.Length)]
    }
    
    return -join $token
}

function Generate-ApiKey {
    param(
        [string]$Prefix = "btai_testnet_"
    )
    
    $randomPart = Generate-AlphanumericToken -TokenLength 32
    return "${Prefix}${randomPart}"
}

function Generate-HexToken {
    param(
        [int]$ByteLength = 32
    )
    
    $bytes = New-Object byte[] $ByteLength
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $rng.GetBytes($bytes)
    $rng.Dispose()
    
    return [BitConverter]::ToString($bytes).Replace('-', '').ToLower()
}

# Main script
Write-ColorOutput "`n═══════════════════════════════════════════════════════" $ColorCyan
Write-ColorOutput "  Binance AI Traders - Secrets Generator" $ColorCyan
Write-ColorOutput "═══════════════════════════════════════════════════════`n" $ColorCyan

Write-ColorOutput "Generating cryptographically secure secrets..." $ColorYellow
Write-ColorOutput "Password length: $Length characters`n" $ColorYellow

# Generate all secrets
$secrets = @{
    # PostgreSQL
    "POSTGRES_PASSWORD" = Generate-SecurePassword -PasswordLength $Length
    
    # Elasticsearch
    "ELASTICSEARCH_PASSWORD" = Generate-SecurePassword -PasswordLength $Length
    
    # Grafana
    "GF_SECURITY_ADMIN_PASSWORD" = Generate-SecurePassword -PasswordLength $Length
    
    # Kafka SASL (optional)
    "KAFKA_SASL_PASSWORD" = Generate-SecurePassword -PasswordLength $Length
    
    # Session secret
    "SESSION_SECRET" = Generate-HexToken -ByteLength 64
    
    # Prometheus bearer token
    "PROMETHEUS_BEARER_TOKEN" = Generate-HexToken -ByteLength 32
}

# Generate API keys if requested
if ($GenerateApiKeys) {
    $secrets["API_KEY_ADMIN"] = Generate-ApiKey
    $secrets["API_KEY_MONITORING"] = Generate-ApiKey
    $secrets["API_KEY_READONLY"] = Generate-ApiKey
}

# Display generated secrets
Write-ColorOutput "═══════════════════════════════════════════════════════" $ColorGreen
Write-ColorOutput "  Generated Secrets (copy to testnet.env)" $ColorGreen
Write-ColorOutput "═══════════════════════════════════════════════════════`n" $ColorGreen

foreach ($key in $secrets.Keys | Sort-Object) {
    $value = $secrets[$key]
    Write-ColorOutput "${key}=" -NoNewline $ColorCyan
    Write-ColorOutput $value $ColorGreen
}

Write-ColorOutput "`n═══════════════════════════════════════════════════════" $ColorGreen

# Save to file if specified
if ($OutputFile -ne "") {
    try {
        $outputPath = Resolve-Path $OutputFile -ErrorAction SilentlyContinue
        if (-not $outputPath) {
            $outputPath = Join-Path (Get-Location) $OutputFile
        }
        
        Write-ColorOutput "`nSaving secrets to: $outputPath" $ColorYellow
        
        # Check if file exists
        if (Test-Path $outputPath) {
            $response = Read-Host "File exists. Overwrite? (yes/no)"
            if ($response -ne "yes") {
                Write-ColorOutput "Operation cancelled." $ColorRed
                exit 1
            }
        }
        
        # Read template if exists
        $templatePath = "testnet.env.template"
        if (Test-Path $templatePath) {
            $content = Get-Content $templatePath -Raw
            
            # Replace placeholders with generated secrets
            foreach ($key in $secrets.Keys) {
                $value = $secrets[$key]
                # Match patterns like: KEY=<placeholder>
                $pattern = "$key=<[^>]+>"
                $replacement = "$key=$value"
                $content = $content -replace $pattern, $replacement
            }
            
            # Save modified content
            Set-Content -Path $outputPath -Value $content -NoNewline
            
            Write-ColorOutput "✓ Secrets saved successfully!" $ColorGreen
        } else {
            # Create new file with just the secrets
            $content = "# Generated secrets - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n`n"
            foreach ($key in $secrets.Keys | Sort-Object) {
                $content += "$key=$($secrets[$key])`n"
            }
            
            Set-Content -Path $outputPath -Value $content -NoNewline
            Write-ColorOutput "✓ Secrets file created!" $ColorGreen
        }
        
    } catch {
        Write-ColorOutput "✗ Error saving to file: $_" $ColorRed
        exit 1
    }
}

# Security warnings
Write-ColorOutput "`n⚠️  SECURITY WARNINGS:" $ColorYellow
Write-ColorOutput "  1. Store these secrets in a secure password manager" $ColorYellow
Write-ColorOutput "  2. Never commit plaintext testnet.env to git" $ColorYellow
Write-ColorOutput "  3. Encrypt with: .\scripts\security\encrypt-secrets.ps1" $ColorYellow
Write-ColorOutput "  4. Delete plaintext testnet.env after encryption" $ColorYellow
Write-ColorOutput "  5. Rotate secrets every 90 days or after compromise" $ColorYellow

# Next steps
Write-ColorOutput "`n📋 NEXT STEPS:" $ColorCyan
Write-ColorOutput "  1. Copy secrets to testnet.env file" $ColorCyan
Write-ColorOutput "  2. Add your Binance testnet API keys" $ColorCyan
Write-ColorOutput "  3. Encrypt: .\scripts\security\encrypt-secrets.ps1" $ColorCyan
Write-ColorOutput "  4. Verify: sops testnet.env.enc" $ColorCyan
Write-ColorOutput "  5. Commit testnet.env.enc to git (encrypted is safe)" $ColorCyan

Write-ColorOutput "`n✓ Secret generation complete!`n" $ColorGreen

exit 0

