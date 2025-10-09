Write-Host "=== Kline System Test ===" -ForegroundColor Green

# Test 1: Binance API
Write-Host "`n1. Testing Binance API..." -ForegroundColor Yellow
try {
    $url = "https://testnet.binance.vision/api/v3/ping"
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
    Write-Host "✓ Binance API: Accessible" -ForegroundColor Green
} catch {
    Write-Host "✗ Binance API: Not accessible" -ForegroundColor Red
}

# Test 2: Kline Data
Write-Host "`n2. Testing Kline Data..." -ForegroundColor Yellow
try {
    $url = "https://testnet.binance.vision/api/v3/klines?symbol=BTCUSDT" + "`&" + "interval=1m" + "`&" + "limit=1"
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
    $data = $response.Content | ConvertFrom-Json
    Write-Host "✓ Kline Data: Retrieved" -ForegroundColor Green
    Write-Host "  BTCUSDT Close: $($data[0][4])" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Kline Data: Failed" -ForegroundColor Red
}

# Test 3: Prometheus
Write-Host "`n3. Testing Prometheus..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:9090/-/healthy" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ Prometheus: Running" -ForegroundColor Green
} catch {
    Write-Host "✗ Prometheus: Not accessible" -ForegroundColor Red
}

# Test 4: Grafana
Write-Host "`n4. Testing Grafana..." -ForegroundColor Yellow
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
