# Test Grafana Table Data
Write-Host "`n=== Testing Kline Table Data ===" -ForegroundColor Cyan

# 1. Check if data exists
Write-Host "`n1. Checking if kline data exists:" -ForegroundColor Yellow
$count = docker exec postgres-testnet psql -U testnet_user -d binance_trader_testnet -t -A -c "SELECT COUNT(*) FROM kline;"
Write-Host "   Total klines: $count" -ForegroundColor $(if ($count -gt 0) {'Green'} else {'Red'})

# 2. Show recent klines
Write-Host "`n2. Recent kline data:" -ForegroundColor Yellow
docker exec postgres-testnet psql -U testnet_user -d binance_trader_testnet -c "SELECT symbol, interval, display_time, open, close FROM kline ORDER BY display_time DESC LIMIT 5;"

# 3. Check PostgreSQL datasource from Grafana
Write-Host "`n3. Checking Grafana datasources:" -ForegroundColor Yellow
docker exec grafana-testnet ls -la /etc/grafana/provisioning/datasources/

# 4. Show PostgreSQL datasource config
Write-Host "`n4. PostgreSQL datasource config:" -ForegroundColor Yellow
docker exec grafana-testnet cat /etc/grafana/provisioning/datasources/prometheus.yml

Write-Host "`n=== Diagnostic Complete ===" -ForegroundColor Cyan

