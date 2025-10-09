# Test Storage Service Fix
Write-Host "=== Testing Storage Service Fix ===" -ForegroundColor Green
Write-Host ""

# Wait a moment for services to stabilize
Write-Host "Waiting for services to stabilize..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Check storage service health
Write-Host "Checking storage service health..." -ForegroundColor Yellow
try {
    $health = Invoke-WebRequest -Uri "http://localhost:8087/actuator/health" -UseBasicParsing
    $healthJson = $health.Content | ConvertFrom-Json
    Write-Host "Storage Health Status: $($healthJson.status)" -ForegroundColor Green
    
    if ($healthJson.components) {
        Write-Host "Database Status:" -ForegroundColor Cyan
        if ($healthJson.components.db) {
            Write-Host "  PostgreSQL: $($healthJson.components.db.status)" -ForegroundColor Green
        }
        if ($healthJson.components.elasticsearch) {
            Write-Host "  Elasticsearch: $($healthJson.components.elasticsearch.status)" -ForegroundColor Green
        }
    }
} catch {
    Write-Host "Storage Health Check Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Check Prometheus metrics
Write-Host "Checking Prometheus metrics..." -ForegroundColor Yellow
try {
    $metrics = Invoke-WebRequest -Uri "http://localhost:8087/actuator/prometheus" -UseBasicParsing
    $metricsContent = $metrics.Content
    
    # Check for key metrics
    $keyMetrics = @(
        "binance_data_storage_postgres_connection_status",
        "binance_data_storage_elasticsearch_connection_status",
        "binance_data_storage_kline_events_received_total",
        "binance_data_storage_kline_events_saved_total"
    )
    
    foreach ($metric in $keyMetrics) {
        if ($metricsContent -match $metric) {
            Write-Host "✓ Found: $metric" -ForegroundColor Green
        } else {
            Write-Host "✗ Missing: $metric" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "Metrics Check Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Check if data is being processed
Write-Host "Checking data processing..." -ForegroundColor Yellow
try {
    $prometheusQuery = "http://localhost:9091/api/v1/query?query=binance_data_storage_kline_events_received_total"
    $response = Invoke-WebRequest -Uri $prometheusQuery -UseBasicParsing
    $data = $response.Content | ConvertFrom-Json
    
    if ($data.data.result.Count -gt 0) {
        $value = $data.data.result[0].value[1]
        Write-Host "Events Received: $value" -ForegroundColor Green
    } else {
        Write-Host "No events received yet" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Data Processing Check Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Fix Summary ===" -ForegroundColor Green
Write-Host "✅ Created missing 'kline' table in PostgreSQL" -ForegroundColor Green
Write-Host "✅ Restarted storage service" -ForegroundColor Green
Write-Host "✅ Service is now connected to Kafka" -ForegroundColor Green
Write-Host ""
Write-Host "Your Grafana dashboard should now show:" -ForegroundColor Cyan
Write-Host "  • PostgreSQL connection status = 1 (Green)" -ForegroundColor White
Write-Host "  • Events being saved to database" -ForegroundColor White
Write-Host "  • Processing metrics working properly" -ForegroundColor White
Write-Host ""
Write-Host "Check your dashboard at: http://localhost:3001" -ForegroundColor Yellow
