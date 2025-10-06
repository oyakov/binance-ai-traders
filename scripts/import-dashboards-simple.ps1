#!/usr/bin/env pwsh
# Simple Dashboard Import

Write-Host "=== Importing Kline Dashboards ===" -ForegroundColor Green

# Wait for Grafana
Write-Host "Waiting for Grafana..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

# Test Grafana connection
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3001/api/health" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ Grafana is ready" -ForegroundColor Green
} catch {
    Write-Host "✗ Grafana not ready: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Create data source
Write-Host "Creating Prometheus data source..." -ForegroundColor Yellow
$datasource = @{
    name = "Prometheus Testnet"
    type = "prometheus"
    access = "proxy"
    url = "http://prometheus-testnet:9090"
    isDefault = $true
} | ConvertTo-Json

try {
    Invoke-WebRequest -Uri "http://localhost:3001/api/datasources" -Method POST -Body $datasource -ContentType "application/json" -Headers @{Authorization="Basic YWRtaW46YWRtaW4="} -UseBasicParsing | Out-Null
    Write-Host "✓ Data source created" -ForegroundColor Green
} catch {
    Write-Host "⚠ Data source may already exist" -ForegroundColor Yellow
}

Write-Host "`n=== Import Complete ===" -ForegroundColor Green
Write-Host "📊 Grafana: http://localhost:3001 (admin/admin)" -ForegroundColor Cyan
Write-Host "📈 Prometheus: http://localhost:9090" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Manual Dashboard Import:" -ForegroundColor Yellow
Write-Host "1. Open Grafana at http://localhost:3001" -ForegroundColor White
Write-Host "2. Go to '+' > Import" -ForegroundColor White
Write-Host "3. Upload JSON files from monitoring/grafana/dashboards/kline-data/" -ForegroundColor White
Write-Host "4. Configure data source as 'Prometheus Testnet'" -ForegroundColor White
