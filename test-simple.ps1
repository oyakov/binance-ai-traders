Write-Host "=== Kline System Test ===" -ForegroundColor Green

# Test Binance API
Write-Host "`nTesting Binance API..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://testnet.binance.vision/api/v3/ping" -UseBasicParsing -TimeoutSec 10
    Write-Host "✓ Binance API: Accessible" -ForegroundColor Green
} catch {
    Write-Host "✗ Binance API: Not accessible" -ForegroundColor Red
}

# Test Prometheus
Write-Host "`nTesting Prometheus..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:9090/-/healthy" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ Prometheus: Running" -ForegroundColor Green
} catch {
    Write-Host "✗ Prometheus: Not accessible" -ForegroundColor Red
}

# Test Grafana
Write-Host "`nTesting Grafana..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3001/api/health" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ Grafana: Running" -ForegroundColor Green
} catch {
    Write-Host "✗ Grafana: Not accessible" -ForegroundColor Red
}

Write-Host "`n=== Summary ===" -ForegroundColor Green
Write-Host "Access Points:" -ForegroundColor Cyan
Write-Host "  Grafana: http://localhost:3001 (admin/admin)" -ForegroundColor White
Write-Host "  Prometheus: http://localhost:9090" -ForegroundColor White
