#!/usr/bin/env pwsh
# Comprehensive Kline System Test

Write-Host "=== Kline Data Collection & Dashboard Test ===" -ForegroundColor Green

# Test 1: Check infrastructure services
Write-Host "`n1. Testing Infrastructure Services..." -ForegroundColor Yellow

# Check PostgreSQL
try {
    $pgResponse = Invoke-WebRequest -Uri "http://localhost:5433" -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
    Write-Host "✓ PostgreSQL: Port accessible" -ForegroundColor Green
} catch {
    Write-Host "✗ PostgreSQL: Not accessible on port 5433" -ForegroundColor Red
}

# Check Elasticsearch
try {
    $esResponse = Invoke-WebRequest -Uri "http://localhost:9202" -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
    Write-Host "✓ Elasticsearch: Port accessible" -ForegroundColor Green
} catch {
    Write-Host "✗ Elasticsearch: Not accessible on port 9202" -ForegroundColor Red
}

# Check Kafka
try {
    $kafkaResponse = Invoke-WebRequest -Uri "http://localhost:9095" -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
    Write-Host "✓ Kafka: Port accessible" -ForegroundColor Green
} catch {
    Write-Host "✗ Kafka: Not accessible on port 9095" -ForegroundColor Red
}

# Test 2: Check monitoring services
Write-Host "`n2. Testing Monitoring Services..." -ForegroundColor Yellow

# Check Prometheus
try {
    $promResponse = Invoke-WebRequest -Uri "http://localhost:9090/-/healthy" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ Prometheus: Running and healthy" -ForegroundColor Green
} catch {
    Write-Host "✗ Prometheus: Not accessible" -ForegroundColor Red
}

# Check Grafana
try {
    $grafanaResponse = Invoke-WebRequest -Uri "http://localhost:3001/api/health" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ Grafana: Running and healthy" -ForegroundColor Green
} catch {
    Write-Host "✗ Grafana: Not accessible" -ForegroundColor Red
}

# Test 3: Test Binance API connectivity
Write-Host "`n3. Testing Binance API Connectivity..." -ForegroundColor Yellow

try {
    $binanceResponse = Invoke-WebRequest -Uri "https://testnet.binance.vision/api/v3/ping" -UseBasicParsing -TimeoutSec 10
    if ($binanceResponse.StatusCode -eq 200) {
        Write-Host "✓ Binance Testnet API: Accessible" -ForegroundColor Green
    } else {
        Write-Host "✗ Binance Testnet API: Unexpected response code $($binanceResponse.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Binance Testnet API: Not accessible - $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Test kline data retrieval
Write-Host "`n4. Testing Kline Data Retrieval..." -ForegroundColor Yellow

try {
    $klineResponse = Invoke-WebRequest -Uri "https://testnet.binance.vision/api/v3/klines?symbol=BTCUSDT&interval=1m&limit=5" -UseBasicParsing -TimeoutSec 10
    if ($klineResponse.StatusCode -eq 200) {
        $klineData = $klineResponse.Content | ConvertFrom-Json
        Write-Host "✓ Kline Data: Retrieved $($klineData.Count) records" -ForegroundColor Green
        Write-Host "  Sample: Open=$($klineData[0][1]), High=$($klineData[0][2]), Low=$($klineData[0][3]), Close=$($klineData[0][4])" -ForegroundColor Cyan
    } else {
        Write-Host "✗ Kline Data: Failed to retrieve" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Kline Data: Error - $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Check Prometheus metrics
Write-Host "`n5. Testing Prometheus Metrics..." -ForegroundColor Yellow

try {
    $metricsResponse = Invoke-WebRequest -Uri "http://localhost:9090/api/v1/query?query=up" -UseBasicParsing -TimeoutSec 5
    if ($metricsResponse.StatusCode -eq 200) {
        $metricsData = $metricsResponse.Content | ConvertFrom-Json
        Write-Host "✓ Prometheus Metrics: Available" -ForegroundColor Green
        Write-Host "  Services detected: $($metricsData.data.result.Count)" -ForegroundColor Cyan
    } else {
        Write-Host "✗ Prometheus Metrics: Failed to query" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Prometheus Metrics: Error - $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Test Grafana dashboards
Write-Host "`n6. Testing Grafana Dashboards..." -ForegroundColor Yellow

try {
    $dashboardsResponse = Invoke-WebRequest -Uri "http://localhost:3001/api/search?type=dash-db" -UseBasicParsing -TimeoutSec 5 -Headers @{Authorization="Basic YWRtaW46YWRtaW4="}
    if ($dashboardsResponse.StatusCode -eq 200) {
        $dashboards = $dashboardsResponse.Content | ConvertFrom-Json
        Write-Host "✓ Grafana Dashboards: $($dashboards.Count) dashboards available" -ForegroundColor Green
        foreach ($dashboard in $dashboards) {
            Write-Host "  - $($dashboard.title)" -ForegroundColor Cyan
        }
    } else {
        Write-Host "✗ Grafana Dashboards: Failed to retrieve" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Grafana Dashboards: Error - $($_.Exception.Message)" -ForegroundColor Red
}

# Test 7: Create test kline data in database
Write-Host "`n7. Testing Database Connectivity..." -ForegroundColor Yellow

try {
    # Test PostgreSQL connection
    $env:PGPASSWORD = "testnet_password"
    $dbTest = psql -h localhost -p 5433 -U testnet_user -d testnet_db -c "SELECT version();" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ PostgreSQL: Connected successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ PostgreSQL: Connection failed" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ PostgreSQL: Error - $($_.Exception.Message)" -ForegroundColor Red
}

# Summary
Write-Host "`n=== Test Summary ===" -ForegroundColor Green
Write-Host "Infrastructure: PostgreSQL, Elasticsearch, Kafka" -ForegroundColor White
Write-Host "Monitoring: Prometheus, Grafana" -ForegroundColor White
Write-Host "External API: Binance Testnet" -ForegroundColor White
Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "1. Fix data collection service JAR issue" -ForegroundColor White
Write-Host "2. Implement metrics in applications" -ForegroundColor White
Write-Host "3. Start live kline data collection" -ForegroundColor White
Write-Host "4. Monitor dashboards for live data" -ForegroundColor White

Write-Host "`n📊 Access Points:" -ForegroundColor Cyan
Write-Host "  Grafana: http://localhost:3001 (admin/admin)" -ForegroundColor White
Write-Host "  Prometheus: http://localhost:9090" -ForegroundColor White
Write-Host "  PostgreSQL: localhost:5433" -ForegroundColor White
Write-Host "  Elasticsearch: localhost:9202" -ForegroundColor White
