#!/usr/bin/env pwsh
# Import Kline Dashboards via Grafana API

Write-Host "=== Importing Kline Dashboards to Grafana ===" -ForegroundColor Green

# Wait for Grafana to be fully ready
Write-Host "Waiting for Grafana to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Test Grafana connection
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3001/api/health" -UseBasicParsing -TimeoutSec 10
    Write-Host "✓ Grafana is ready" -ForegroundColor Green
} catch {
    Write-Host "✗ Grafana not ready: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Create Prometheus data source
Write-Host "`nCreating Prometheus data source..." -ForegroundColor Yellow
$datasource = @{
    name = "Prometheus Testnet"
    type = "prometheus"
    access = "proxy"
    url = "http://prometheus-testnet:9090"
    isDefault = $true
    editable = $true
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "http://localhost:3001/api/datasources" -Method POST -Body $datasource -ContentType "application/json" -Headers @{Authorization="Basic YWRtaW46YWRtaW4="} -UseBasicParsing
    Write-Host "✓ Prometheus data source created" -ForegroundColor Green
} catch {
    Write-Host "⚠ Data source may already exist" -ForegroundColor Yellow
}

# Function to import dashboard
function Import-Dashboard {
    param(
        [string]$FilePath,
        [string]$DashboardName
    )
    
    if (-not (Test-Path $FilePath)) {
        Write-Host "⚠ Dashboard file not found: $FilePath" -ForegroundColor Yellow
        return
    }
    
    try {
        $dashboardJson = Get-Content -Path $FilePath -Raw
        $dashboard = $dashboardJson | ConvertFrom-Json
        
        $importPayload = @{
            dashboard = $dashboard.dashboard
            overwrite = $true
        } | ConvertTo-Json -Depth 10
        
        $response = Invoke-WebRequest -Uri "http://localhost:3001/api/dashboards/db" -Method POST -Body $importPayload -ContentType "application/json" -Headers @{Authorization="Basic YWRtaW46YWRtaW4="} -UseBasicParsing
        
        if ($response.StatusCode -eq 200) {
            Write-Host "✓ $DashboardName imported successfully" -ForegroundColor Green
        } else {
            Write-Host "⚠ $DashboardName import returned status: $($response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "✗ Failed to import $DashboardName : $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Import dashboards
Write-Host "`nImporting Kline Dashboards..." -ForegroundColor Yellow

$dashboards = @(
    @{Path="monitoring/grafana/dashboards/kline-data/kline-master-dashboard.json"; Name="Kline Data Master Dashboard"},
    @{Path="monitoring/grafana/dashboards/kline-data/kline-collection-overview.json"; Name="Kline Collection Overview"},
    @{Path="monitoring/grafana/dashboards/kline-data/kline-price-charts.json"; Name="Live Price Charts"},
    @{Path="monitoring/grafana/dashboards/kline-data/kline-streaming-monitor.json"; Name="Kline Streaming Monitor"},
    @{Path="monitoring/grafana/dashboards/kline-data/kline-storage-monitor.json"; Name="Kline Storage Monitor"},
    @{Path="monitoring/grafana/dashboards/kline-data/kline-alerts.json"; Name="Kline Alerts and Health"}
)

foreach ($dashboard in $dashboards) {
    Import-Dashboard -FilePath $dashboard.Path -DashboardName $dashboard.Name
}

Write-Host "`n=== Dashboard Import Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Access Grafana at: http://localhost:3001" -ForegroundColor Cyan
Write-Host "   Username: admin" -ForegroundColor White
Write-Host "   Password: admin" -ForegroundColor White
Write-Host ""
Write-Host "📋 Available Dashboards:" -ForegroundColor Yellow
Write-Host "   • Kline Data Master Dashboard - Main overview" -ForegroundColor White
Write-Host "   • Kline Collection Overview - Data collection monitoring" -ForegroundColor White
Write-Host "   • Live Price Charts - Real-time price visualization" -ForegroundColor White
Write-Host "   • Kline Streaming Monitor - WebSocket streaming health" -ForegroundColor White
Write-Host "   • Kline Storage Monitor - Database and Elasticsearch monitoring" -ForegroundColor White
Write-Host "   • Kline Alerts and Health - Alerting and system health" -ForegroundColor White
Write-Host ""
Write-Host "🎯 Note: Dashboards will show 'No data' until metrics are implemented" -ForegroundColor Yellow
