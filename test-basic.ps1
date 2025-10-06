Write-Host "=== Basic Kline Test ===" -ForegroundColor Green

# Test 1: Binance API
Write-Host "`n1. Testing Binance API..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://testnet.binance.vision/api/v3/ping" -UseBasicParsing -TimeoutSec 10
    Write-Host "✓ Binance API: Accessible" -ForegroundColor Green
} catch {
    Write-Host "✗ Binance API: Not accessible" -ForegroundColor Red
}

# Test 2: Prometheus
Write-Host "`n2. Testing Prometheus..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:9090/-/healthy" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ Prometheus: Running" -ForegroundColor Green
} catch {
    Write-Host "✗ Prometheus: Not accessible" -ForegroundColor Red
}

# Test 3: Grafana
Write-Host "`n3. Testing Grafana..." -ForegroundColor Yellow
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
