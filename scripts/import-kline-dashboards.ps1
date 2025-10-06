#!/usr/bin/env pwsh
# Import Kline Dashboards into Grafana

Write-Host "=== Importing Kline Dashboards to Grafana ===" -ForegroundColor Green

# Wait for Grafana to be ready
Write-Host "`nWaiting for Grafana to be ready..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0

do {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3001/api/health" -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Host "✓ Grafana is ready" -ForegroundColor Green
            break
        }
    } catch {
        $attempt++
        if ($attempt -ge $maxAttempts) {
            Write-Host "✗ Grafana failed to start after $maxAttempts attempts" -ForegroundColor Red
            exit 1
        }
        Write-Host "Attempt $attempt/$maxAttempts - Waiting for Grafana..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
    }
} while ($attempt -lt $maxAttempts)

# Create data source
Write-Host "`nCreating Prometheus data source..." -ForegroundColor Yellow
$datasourceConfig = @{
    name = "Prometheus Testnet"
    type = "prometheus"
    access = "proxy"
    url = "http://prometheus-testnet:9090"
    isDefault = $true
    editable = $true
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "http://localhost:3001/api/datasources" -Method POST -Body $datasourceConfig -ContentType "application/json" -Headers @{Authorization="Basic YWRtaW46YWRtaW4="} -UseBasicParsing
    Write-Host "✓ Prometheus data source created" -ForegroundColor Green
} catch {
    Write-Host "⚠ Data source may already exist: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Function to import dashboard
function Import-Dashboard {
    param(
        [string]$FilePath,
        [string]$DashboardName
    )
    
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
    if (Test-Path $dashboard.Path) {
        Import-Dashboard -FilePath $dashboard.Path -DashboardName $dashboard.Name
    } else {
        Write-Host "⚠ Dashboard file not found: $($dashboard.Path)" -ForegroundColor Yellow
    }
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
Write-Host "🎯 Note: Dashboards will show 'No data' until metrics are implemented in the applications" -ForegroundColor Yellow
