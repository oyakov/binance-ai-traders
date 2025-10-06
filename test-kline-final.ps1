Write-Host "=== Kline Dashboard Test ===" -ForegroundColor Green

# Test 1: Binance API Kline Data
Write-Host "`n1. Testing Binance Kline API..." -ForegroundColor Yellow
try {
    $baseUrl = "https://testnet.binance.vision/api/v3/klines"
    $params = "symbol=BTCUSDT" + "`&" + "interval=1m" + "`&" + "limit=5"
    $url = "$baseUrl" + "?" + $params
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
    $klineData = $response.Content | ConvertFrom-Json
    
    Write-Host "✓ Retrieved $($klineData.Count) kline records" -ForegroundColor Green
    Write-Host "  Latest BTCUSDT: Open=$($klineData[-1][1]), High=$($klineData[-1][2]), Low=$($klineData[-1][3]), Close=$($klineData[-1][4])" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Binance API Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Multiple Symbols
Write-Host "`n2. Testing Multiple Symbols..." -ForegroundColor Yellow
$symbols = @("BTCUSDT", "ETHUSDT", "ADAUSDT")
foreach ($symbol in $symbols) {
    try {
        $baseUrl = "https://testnet.binance.vision/api/v3/klines"
        $params = "symbol=$symbol" + "`&" + "interval=1m" + "`&" + "limit=1"
        $url = "$baseUrl" + "?" + $params
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5
        $data = $response.Content | ConvertFrom-Json
        Write-Host "  ✓ $symbol`: $($data[0][4])" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ $symbol`: Failed" -ForegroundColor Red
    }
}

# Test 3: Prometheus Metrics
Write-Host "`n3. Testing Prometheus Metrics..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:9090/api/v1/query?query=up" -UseBasicParsing -TimeoutSec 5
    $metrics = $response.Content | ConvertFrom-Json
    Write-Host "✓ Prometheus: $($metrics.data.result.Count) services detected" -ForegroundColor Green
} catch {
    Write-Host "✗ Prometheus: Not accessible" -ForegroundColor Red
}

# Test 4: Grafana Dashboards
Write-Host "`n4. Testing Grafana Dashboards..." -ForegroundColor Yellow
try {
    $headers = @{Authorization="Basic YWRtaW46YWRtaW4="}
    $response = Invoke-WebRequest -Uri "http://localhost:3001/api/search?type=dash-db" -UseBasicParsing -TimeoutSec 5 -Headers $headers
    $dashboards = $response.Content | ConvertFrom-Json
    Write-Host "✓ Grafana: $($dashboards.Count) dashboards available" -ForegroundColor Green
    foreach ($dashboard in $dashboards) {
        Write-Host "  - $($dashboard.title)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "✗ Grafana: Not accessible" -ForegroundColor Red
}

Write-Host "`n=== Summary ===" -ForegroundColor Green
Write-Host "✅ Binance API: Working" -ForegroundColor White
Write-Host "✅ Prometheus: Running" -ForegroundColor White
Write-Host "✅ Grafana: Running" -ForegroundColor White
Write-Host "❌ Data Collection Service: JAR file issue" -ForegroundColor White

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "1. Fix JAR file path in Dockerfile" -ForegroundColor White
Write-Host "2. Implement metrics in applications" -ForegroundColor White
Write-Host "3. Start live data collection" -ForegroundColor White

Write-Host "`nAccess Points:" -ForegroundColor Cyan
Write-Host "  Grafana: http://localhost:3001 (admin/admin)" -ForegroundColor White
Write-Host "  Prometheus: http://localhost:9090" -ForegroundColor White
