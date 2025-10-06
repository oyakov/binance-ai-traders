#!/usr/bin/env pwsh
# Generate Test Metrics for Kline Dashboards

Write-Host "=== Generating Test Metrics for Kline Dashboards ===" -ForegroundColor Green

# Test Prometheus connection
Write-Host "`n1. Testing Prometheus connection..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:9090/-/healthy" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ Prometheus is accessible" -ForegroundColor Green
} catch {
    Write-Host "✗ Prometheus not accessible: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Generate test metrics using Prometheus API
Write-Host "`n2. Generating test metrics..." -ForegroundColor Yellow

# Function to push metrics to Prometheus
function Push-Metric {
    param(
        [string]$MetricName,
        [string]$Value,
        [string]$Labels = ""
    )
    
    $timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    $metric = "$MetricName{$Labels} $Value $timestamp"
    
    try {
        $body = $metric
        Invoke-WebRequest -Uri "http://localhost:9090/api/v1/import/prometheus" -Method POST -Body $body -ContentType "text/plain" -UseBasicParsing | Out-Null
        Write-Host "✓ Pushed $MetricName = $Value" -ForegroundColor Green
    } catch {
        Write-Host "⚠ Failed to push $MetricName : $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Generate sample kline data
Write-Host "`n3. Generating sample kline data..." -ForegroundColor Yellow

# WebSocket connection status
Push-Metric "kline_websocket_connected" "1"

# Active streams
Push-Metric "kline_active_streams" "3"

# Messages received
Push-Metric "kline_messages_received_total" "1500"

# Messages processed
Push-Metric "kline_messages_processed_total" "1485"

# Records processed
Push-Metric "kline_records_total" "1485"

# Price data
Push-Metric "kline_price_open{symbol=\"BTCUSDT\",interval=\"1m\"}" "122350.50"
Push-Metric "kline_price_high{symbol=\"BTCUSDT\",interval=\"1m\"}" "122380.75"
Push-Metric "kline_price_low{symbol=\"BTCUSDT\",interval=\"1m\"}" "122340.25"
Push-Metric "kline_price_close{symbol=\"BTCUSDT\",interval=\"1m\"}" "122375.80"
Push-Metric "kline_volume{symbol=\"BTCUSDT\",interval=\"1m\"}" "15.75"

# Processing metrics
Push-Metric "kline_processing_queue_size" "5"
Push-Metric "kline_processing_duration_seconds_bucket{le=\"0.001\"}" "1200"
Push-Metric "kline_processing_duration_seconds_bucket{le=\"0.005\"}" "1400"
Push-Metric "kline_processing_duration_seconds_bucket{le=\"0.01\"}" "1480"
Push-Metric "kline_processing_duration_seconds_bucket{le=\"0.05\"}" "1485"
Push-Metric "kline_processing_duration_seconds_bucket{le=\"0.1\"}" "1485"
Push-Metric "kline_processing_duration_seconds_bucket{le=\"+Inf\"}" "1485"
Push-Metric "kline_processing_duration_seconds_count" "1485"
Push-Metric "kline_processing_duration_seconds_sum" "7.425"

# Storage metrics
Push-Metric "kline_records_stored_total" "1480"
Push-Metric "kline_elasticsearch_indexed_total" "1475"
Push-Metric "kline_storage_errors_total" "5"

# Error metrics
Push-Metric "kline_errors_total" "15"
Push-Metric "kline_websocket_errors_total" "2"
Push-Metric "kline_processing_errors_total" "8"
Push-Metric "kline_storage_errors_total" "5"

# JVM metrics
Push-Metric "jvm_memory_used_bytes{job=\"binance-data-collection-testnet\",area=\"heap\"}" "268435456"
Push-Metric "jvm_memory_max_bytes{job=\"binance-data-collection-testnet\",area=\"heap\"}" "1073741824"

Write-Host "`n4. Waiting for metrics to be available..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Test query
Write-Host "`n5. Testing metric queries..." -ForegroundColor Yellow
try {
    $query = "kline_websocket_connected"
    $response = Invoke-WebRequest -Uri "http://localhost:9090/api/v1/query?query=$query" -UseBasicParsing
    $result = $response.Content | ConvertFrom-Json
    if ($result.data.result.Count -gt 0) {
        Write-Host "✓ Metrics are available in Prometheus" -ForegroundColor Green
    } else {
        Write-Host "⚠ No metrics found in Prometheus" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠ Error querying metrics: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "`n=== Test Metrics Generated ===" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Check your Grafana dashboards now:" -ForegroundColor Cyan
Write-Host "   http://localhost:3001" -ForegroundColor White
Write-Host ""
Write-Host "📋 Expected to see:" -ForegroundColor Yellow
Write-Host "   • WebSocket Connection Status: 1 (Connected)" -ForegroundColor White
Write-Host "   • Active Streams: 3" -ForegroundColor White
Write-Host "   • Messages Received: 1500" -ForegroundColor White
Write-Host "   • BTCUSDT Price: ~122,375" -ForegroundColor White
Write-Host "   • Processing Queue Size: 5" -ForegroundColor White
Write-Host ""
Write-Host "🔄 Refresh your dashboard to see the data!" -ForegroundColor Yellow
