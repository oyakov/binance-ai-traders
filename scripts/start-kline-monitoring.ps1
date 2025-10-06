#!/usr/bin/env pwsh
# Start Kline Data Monitoring Stack
# This script starts Grafana with the new kline monitoring dashboards

Write-Host "=== Starting Kline Data Monitoring Stack ===" -ForegroundColor Green

# Check if Docker is running
Write-Host "`n1. Checking Docker status..." -ForegroundColor Yellow
try {
    docker version | Out-Null
    Write-Host "✓ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker is not running. Please start Docker first." -ForegroundColor Red
    exit 1
}

# Check if testnet environment is running
Write-Host "`n2. Checking testnet environment..." -ForegroundColor Yellow
$testnetRunning = docker-compose -f docker-compose-testnet.yml ps --services --filter "status=running" | Measure-Object | Select-Object -ExpandProperty Count

if ($testnetRunning -lt 5) {
    Write-Host "⚠ Testnet environment not fully running. Starting infrastructure..." -ForegroundColor Yellow
    Write-Host "Starting infrastructure services..." -ForegroundColor Cyan
    docker-compose -f docker-compose-testnet.yml up -d postgres-testnet elasticsearch-testnet kafka-testnet zookeeper-testnet schema-registry-testnet
    
    Write-Host "Waiting for services to be ready..." -ForegroundColor Cyan
    Start-Sleep -Seconds 30
    
    Write-Host "Starting application services..." -ForegroundColor Cyan
    docker-compose -f docker-compose-testnet.yml up -d binance-data-collection-testnet binance-data-storage-testnet
} else {
    Write-Host "✓ Testnet environment is running" -ForegroundColor Green
}

# Start Prometheus for metrics collection
Write-Host "`n3. Starting Prometheus..." -ForegroundColor Yellow
docker-compose -f monitoring/docker-compose.grafana-testnet.yml up -d prometheus-testnet

# Wait for Prometheus to be ready
Write-Host "Waiting for Prometheus to be ready..." -ForegroundColor Cyan
Start-Sleep -Seconds 15

# Start Grafana with kline dashboards
Write-Host "`n4. Starting Grafana with Kline Dashboards..." -ForegroundColor Yellow
docker-compose -f monitoring/docker-compose.grafana-testnet.yml up -d grafana-testnet

# Wait for Grafana to be ready
Write-Host "Waiting for Grafana to be ready..." -ForegroundColor Cyan
Start-Sleep -Seconds 20

# Check service health
Write-Host "`n5. Checking service health..." -ForegroundColor Yellow

# Check Prometheus
try {
    $prometheusHealth = Invoke-WebRequest -Uri "http://localhost:9090/-/healthy" -UseBasicParsing -TimeoutSec 5
    if ($prometheusHealth.StatusCode -eq 200) {
        Write-Host "✓ Prometheus is healthy" -ForegroundColor Green
    } else {
        Write-Host "⚠ Prometheus health check failed" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠ Prometheus health check failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Check Grafana
try {
    $grafanaHealth = Invoke-WebRequest -Uri "http://localhost:3001/api/health" -UseBasicParsing -TimeoutSec 5
    if ($grafanaHealth.StatusCode -eq 200) {
        Write-Host "✓ Grafana is healthy" -ForegroundColor Green
    } else {
        Write-Host "⚠ Grafana health check failed" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠ Grafana health check failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Display access information
Write-Host "`n=== Kline Monitoring Stack Started ===" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Grafana Dashboards:" -ForegroundColor Cyan
Write-Host "   URL: http://localhost:3001" -ForegroundColor White
Write-Host "   Username: admin" -ForegroundColor White
Write-Host "   Password: admin" -ForegroundColor White
Write-Host ""
Write-Host "📈 Available Dashboards:" -ForegroundColor Cyan
Write-Host "   • Kline Data Master Dashboard - Main overview" -ForegroundColor White
Write-Host "   • Kline Collection Overview - Data collection monitoring" -ForegroundColor White
Write-Host "   • Live Price Charts - Real-time price visualization" -ForegroundColor White
Write-Host "   • Kline Streaming Monitor - WebSocket streaming health" -ForegroundColor White
Write-Host "   • Kline Storage Monitor - Database and Elasticsearch monitoring" -ForegroundColor White
Write-Host "   • Kline Alerts & Health - Alerting and system health" -ForegroundColor White
Write-Host ""
Write-Host "🔍 Prometheus Metrics:" -ForegroundColor Cyan
Write-Host "   URL: http://localhost:9090" -ForegroundColor White
Write-Host ""
Write-Host "📋 Service Status:" -ForegroundColor Cyan
docker-compose -f monitoring/docker-compose.grafana-testnet.yml ps

Write-Host "`n=== Next Steps ===" -ForegroundColor Green
Write-Host "1. Open Grafana at http://localhost:3001" -ForegroundColor White
Write-Host "2. Navigate to 'Kline Data Monitoring' folder" -ForegroundColor White
Write-Host "3. Start with the 'Kline Data Master Dashboard'" -ForegroundColor White
Write-Host "4. Configure alerts and thresholds as needed" -ForegroundColor White
Write-Host "5. Use template variables to filter by symbol and interval" -ForegroundColor White

Write-Host "`n🎯 To test data collection, run:" -ForegroundColor Yellow
Write-Host "   .\simple-kline-monitor.ps1" -ForegroundColor White

Write-Host "`n=== Monitoring Stack Ready! ===" -ForegroundColor Green
