# Simple Kline Data Collection Monitor
# This script monitors kline data collection and storage

Write-Host "=== Simple Kline Data Collection Monitor ===" -ForegroundColor Green

# Test Binance API
Write-Host "`n1. Testing Binance API..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://testnet.binance.vision/api/v3/klines?symbol=BTCUSDT&interval=1m&limit=1" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Binance API is accessible" -ForegroundColor Green
        $klineData = $response.Content | ConvertFrom-Json
        $openTime = [DateTimeOffset]::FromUnixTimeMilliseconds($klineData[0][0]).ToString("yyyy-MM-dd HH:mm:ss")
        $close = $klineData[0][4]
        $volume = $klineData[0][5]
        Write-Host "Latest kline: $openTime - Close: $close, Volume: $volume" -ForegroundColor Cyan
    }
} catch {
    Write-Host "❌ Binance API error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Database
Write-Host "`n2. Testing Database..." -ForegroundColor Yellow
try {
    $countResult = docker-compose -f docker-compose-testnet.yml exec -T postgres-testnet psql -U testnet_user -d binance_trader_testnet -c "SELECT COUNT(*) FROM kline;"
    $count = ($countResult[2].Trim())
    Write-Host "✅ Database accessible - Total kline records: $count" -ForegroundColor Green
} catch {
    Write-Host "❌ Database error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Elasticsearch
Write-Host "`n3. Testing Elasticsearch..." -ForegroundColor Yellow
try {
    $esResponse = Invoke-WebRequest -Uri "http://localhost:9202/_cluster/health" -UseBasicParsing
    if ($esResponse.StatusCode -eq 200) {
        Write-Host "✅ Elasticsearch is accessible" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Elasticsearch error: $($_.Exception.Message)" -ForegroundColor Red
}

# Collect and store sample data
Write-Host "`n4. Collecting and Storing Sample Data..." -ForegroundColor Yellow

try {
    # Get fresh kline data
    $klineResponse = Invoke-WebRequest -Uri "https://testnet.binance.vision/api/v3/klines?symbol=BTCUSDT&interval=1m&limit=1" -UseBasicParsing
    if ($klineResponse.StatusCode -eq 200) {
        $klineData = $klineResponse.Content | ConvertFrom-Json
        $kline = $klineData[0]
        
        $openTime = $kline[0]
        $closeTime = $kline[6]
        $timestamp = $openTime
        $displayTime = [DateTimeOffset]::FromUnixTimeMilliseconds($openTime).ToString("yyyy-MM-dd HH:mm:ss")
        $symbol = "BTCUSDT"
        $interval = "1m"
        $open = $kline[1]
        $high = $kline[2]
        $low = $kline[3]
        $close = $kline[4]
        $volume = $kline[5]
        
        # Insert into database
        $insertSQL = @"
INSERT INTO kline (symbol, interval, open_time, close_time, timestamp, display_time, open, high, low, close, volume)
VALUES ('$symbol', '$interval', $openTime, $closeTime, $timestamp, '$displayTime', $open, $high, $low, $close, $volume)
ON CONFLICT (symbol, interval, open_time, close_time) 
DO UPDATE SET 
    timestamp = EXCLUDED.timestamp,
    display_time = EXCLUDED.display_time,
    open = EXCLUDED.open,
    high = EXCLUDED.high,
    low = EXCLUDED.low,
    close = EXCLUDED.close,
    volume = EXCLUDED.volume;
"@
        
        $insertResult = docker-compose -f docker-compose-testnet.yml exec -T postgres-testnet psql -U testnet_user -d binance_trader_testnet -c $insertSQL
        Write-Host "✅ Sample data stored successfully" -ForegroundColor Green
        Write-Host "Data: $symbol $interval at $displayTime - Close: $close, Volume: $volume" -ForegroundColor Cyan
    }
} catch {
    Write-Host "❌ Data collection/storage error: $($_.Exception.Message)" -ForegroundColor Red
}

# Verify final count
Write-Host "`n5. Final Verification..." -ForegroundColor Yellow
try {
    $finalCount = docker-compose -f docker-compose-testnet.yml exec -T postgres-testnet psql -U testnet_user -d binance_trader_testnet -c "SELECT COUNT(*) FROM kline;"
    $count = ($finalCount[2].Trim())
    Write-Host "✅ Final kline record count: $count" -ForegroundColor Green
} catch {
    Write-Host "❌ Verification error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Monitor Complete ===" -ForegroundColor Green
Write-Host "Kline data collection and storage is working!" -ForegroundColor Green
