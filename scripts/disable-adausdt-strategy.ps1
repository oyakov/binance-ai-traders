# Disable ADAUSDT Strategy - Emergency Fix
# This script temporarily disables the failing ADAUSDT 1d strategy
# 
# Reason: Only 9 daily klines available, but strategy needs 21 (MACD 7/14/7)
# Date: October 11, 2025

$configFile = "binance-trader-macd/src/main/resources/testnet-strategies.yml"

Write-Host "=== Disabling ADAUSDT Strategy ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "Current issue: ADAUSDT 1d strategy has insufficient data"
Write-Host "Available: 9 daily klines"
Write-Host "Required: 21 daily klines (for MACD 7/14/7)"
Write-Host ""

# Check if file exists
if (-not (Test-Path $configFile)) {
    Write-Host "ERROR: Config file not found: $configFile" -ForegroundColor Red
    exit 1
}

# Backup the file
$backupFile = "$configFile.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Copy-Item $configFile $backupFile
Write-Host "✓ Backup created: $backupFile" -ForegroundColor Green

# Read the file
$content = Get-Content $configFile -Raw

# Replace enabled: true with enabled: false for balanced-ada strategy
$newContent = $content -replace '(balanced-ada:[\s\S]*?enabled:\s+)true', '$1false'

# Write the modified content
Set-Content -Path $configFile -Value $newContent

Write-Host "✓ Updated $configFile" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Rebuild the trader service: docker-compose -f docker-compose-testnet.yml build binance-trader-macd-testnet"
Write-Host "2. Restart the service: docker-compose -f docker-compose-testnet.yml restart binance-trader-macd-testnet"
Write-Host "3. Verify logs: docker logs binance-trader-macd-testnet --tail 50"
Write-Host ""
Write-Host "To re-enable the strategy later:" -ForegroundColor Yellow
Write-Host "- Wait for 12+ more days of daily klines (need 21 total)"
Write-Host "- OR implement historical data backfill"
Write-Host "- OR change to 4h timeframe with standard MACD(12,26,9)"
Write-Host ""

