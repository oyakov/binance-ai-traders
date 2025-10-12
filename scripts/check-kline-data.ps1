# Check Kline Data Collection Status
Write-Host "`n=== Kline Data Collection Diagnostics ===" -ForegroundColor Cyan

# 1. Check if containers are running
Write-Host "`n1. Container Status:" -ForegroundColor Yellow
docker ps --filter "name=testnet" --format "table {{.Names}}\t{{.Status}}" | Out-String | Write-Host

# 2. Check database for kline count and latest data
Write-Host "`n2. Database Kline Statistics:" -ForegroundColor Yellow
docker exec postgres-testnet psql -U testnet_user -d binance_trader_testnet -c "SELECT COUNT(*) as total_klines, MAX(display_time) as latest_time, MIN(display_time) as earliest_time FROM kline;" | Out-String | Write-Host

# 3. Check recent klines
Write-Host "`n3. Most Recent Klines:" -ForegroundColor Yellow
docker exec postgres-testnet psql -U testnet_user -d binance_trader_testnet -c "SELECT symbol, interval, display_time FROM kline ORDER BY display_time DESC LIMIT 5;" | Out-String | Write-Host

# 4. Check data collection service logs
Write-Host "`n4. Data Collection Service (last 15 lines):" -ForegroundColor Yellow
docker logs binance-data-collection-testnet --tail 15 | Out-String | Write-Host

# 5. Check data storage service logs
Write-Host "`n5. Data Storage Service (last 15 lines):" -ForegroundColor Yellow
docker logs binance-data-storage-testnet --tail 15 | Out-String | Write-Host

# 6. Check if data is flowing
Write-Host "`n6. Checking Data Flow:" -ForegroundColor Yellow
$beforeCount = docker exec postgres-testnet psql -U testnet_user -d binance_trader_testnet -t -c "SELECT COUNT(*) FROM kline;" | Out-String
$beforeCount = $beforeCount.Trim()
Write-Host "  Current kline count: $beforeCount" -ForegroundColor White

Write-Host "  Waiting 30 seconds for new data..." -ForegroundColor White
Start-Sleep -Seconds 30

$afterCount = docker exec postgres-testnet psql -U testnet_user -d binance_trader_testnet -t -c "SELECT COUNT(*) FROM kline;" | Out-String
$afterCount = $afterCount.Trim()
Write-Host "  New kline count: $afterCount" -ForegroundColor White

if ($afterCount -gt $beforeCount) {
    Write-Host "  ✓ Data is flowing! ($($afterCount - $beforeCount) new klines)" -ForegroundColor Green
} else {
    Write-Host "  ✗ No new data collected in 30 seconds" -ForegroundColor Red
}

Write-Host "`n=== Diagnostic Complete ===" -ForegroundColor Cyan

