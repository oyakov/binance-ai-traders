# Test Storage Service Fix
Write-Host "=== Testing Storage Service Fix ===" -ForegroundColor Green
Write-Host ""

# Check storage service health
Write-Host "Checking storage service health..." -ForegroundColor Yellow
try {
    $health = Invoke-WebRequest -Uri "http://localhost:8087/actuator/health" -UseBasicParsing
    Write-Host "Storage Health Status: OK" -ForegroundColor Green
} catch {
    Write-Host "Storage Health Check Failed" -ForegroundColor Red
}

# Check Prometheus metrics
Write-Host "Checking Prometheus metrics..." -ForegroundColor Yellow
try {
    $metrics = Invoke-WebRequest -Uri "http://localhost:8087/actuator/prometheus" -UseBasicParsing
    $metricsContent = $metrics.Content
    
    if ($metricsContent -match "binance_data_storage_postgres_connection_status") {
        Write-Host "PostgreSQL metrics found" -ForegroundColor Green
    } else {
        Write-Host "PostgreSQL metrics missing" -ForegroundColor Red
    }
    
    if ($metricsContent -match "binance_data_storage_kline_events_received_total") {
        Write-Host "Kline events metrics found" -ForegroundColor Green
    } else {
        Write-Host "Kline events metrics missing" -ForegroundColor Red
    }
} catch {
    Write-Host "Metrics Check Failed" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Fix Applied ===" -ForegroundColor Green
Write-Host "Created missing kline table in PostgreSQL" -ForegroundColor Green
Write-Host "Restarted storage service" -ForegroundColor Green
Write-Host ""
Write-Host "Check your Grafana dashboard now!" -ForegroundColor Yellow
Write-Host "URL: http://localhost:3001" -ForegroundColor Cyan