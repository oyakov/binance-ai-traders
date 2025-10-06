Write-Host "=== Quick Kline System Test ===" -ForegroundColor Green

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

# Test Binance API
Write-Host "`nTesting Binance API..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://testnet.binance.vision/api/v3/ping" -UseBasicParsing -TimeoutSec 10
    Write-Host "✓ Binance Testnet: Accessible" -ForegroundColor Green
} catch {
    Write-Host "✗ Binance Testnet: Not accessible" -ForegroundColor Red
}

# Test Kline Data
Write-Host "`nTesting Kline Data..." -ForegroundColor Yellow
try {
    $klineUrl = "https://testnet.binance.vision/api/v3/klines?symbol=BTCUSDT" + "`&" + "interval=1m" + "`&" + "limit=1"
    $response = Invoke-WebRequest -Uri $klineUrl -UseBasicParsing -TimeoutSec 10
    $data = $response.Content | ConvertFrom-Json
    Write-Host "✓ Kline Data: Retrieved 1 record" -ForegroundColor Green
    Write-Host "  BTCUSDT: Open=$($data[0][1]), Close=$($data[0][4])" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Kline Data: Failed" -ForegroundColor Red
}

Write-Host "`nAccess Points:" -ForegroundColor Cyan
Write-Host "  Grafana: http://localhost:3001 (admin/admin)" -ForegroundColor White
Write-Host "  Prometheus: http://localhost:9090" -ForegroundColor White
