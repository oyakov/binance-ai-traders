# Grafana Dashboard Import and Expansion Script
# This script imports and organizes all existing Grafana dashboards

param(
    [switch]$Force,
    [switch]$DryRun
)

Write-Host "=== Grafana Dashboard Import and Expansion ===" -ForegroundColor Green
Write-Host "Timestamp: $(Get-Date)" -ForegroundColor Yellow
Write-Host ""

# Check if Grafana is running
Write-Host "Checking Grafana service status..." -ForegroundColor Cyan
$grafanaStatus = docker-compose -f docker-compose-testnet.yml ps grafana-testnet --format "table {{.Status}}"
if ($grafanaStatus -notmatch "Up") {
    Write-Host "❌ Grafana is not running. Starting Grafana..." -ForegroundColor Red
    docker-compose -f docker-compose-testnet.yml up -d grafana-testnet
    Start-Sleep -Seconds 30
}

# Function to create directory structure
function New-DashboardDirectory {
    param([string]$Path)
    if (!(Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Host "Created directory: $Path" -ForegroundColor Green
    }
}

# Function to copy dashboard files
function Copy-DashboardFile {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Category
    )
    
    if (Test-Path $Source) {
        $destDir = Split-Path $Destination -Parent
        New-DashboardDirectory $destDir
        
        Copy-Item $Source $Destination -Force
        Write-Host "Copied $Category dashboard: $(Split-Path $Source -Leaf)" -ForegroundColor Green
        return $true
    } else {
        Write-Host "⚠️  Source file not found: $Source" -ForegroundColor Yellow
        return $false
    }
}

# Create comprehensive provisioning structure
Write-Host "Creating dashboard provisioning structure..." -ForegroundColor Cyan

$provisioningBase = "monitoring/grafana/provisioning/dashboards"
$categories = @(
    @{Name="binance-trading"; Path="$provisioningBase/binance-trading"},
    @{Name="system-monitoring"; Path="$provisioningBase/system-monitoring"},
    @{Name="analytics"; Path="$provisioningBase/analytics"},
    @{Name="strategies"; Path="$provisioningBase/strategies"},
    @{Name="enhanced-trading"; Path="$provisioningBase/enhanced-trading"},
    @{Name="kline-data"; Path="$provisioningBase/kline-data"},
    @{Name="system-health"; Path="$provisioningBase/system-health"}
)

foreach ($category in $categories) {
    New-DashboardDirectory $category.Path
}

# Import Binance Trading Dashboards
Write-Host "`n=== Importing Binance Trading Dashboards ===" -ForegroundColor Cyan
$binanceDashboards = @(
    @{Source="monitoring/grafana/dashboards/binance-trading/executive-overview.json"; Dest="$provisioningBase/binance-trading/executive-overview.json"},
    @{Source="monitoring/grafana/dashboards/binance-trading/macd-strategy.json"; Dest="$provisioningBase/binance-trading/macd-strategy.json"},
    @{Source="monitoring/grafana/dashboards/binance-trading/simple-health-dashboard.json"; Dest="$provisioningBase/binance-trading/simple-health-dashboard.json"},
    @{Source="monitoring/grafana/dashboards/binance-trading/trading-health.json"; Dest="$provisioningBase/binance-trading/trading-health.json"},
    @{Source="monitoring/grafana/dashboards/binance-trading/trading-operations.json"; Dest="$provisioningBase/binance-trading/trading-operations.json"},
    @{Source="monitoring/grafana/dashboards/binance-trading/trading-overview.json"; Dest="$provisioningBase/binance-trading/trading-overview.json"},
    @{Source="monitoring/grafana/dashboards/binance-macd-testnet.json"; Dest="$provisioningBase/binance-trading/binance-macd-testnet.json"}
)

foreach ($dashboard in $binanceDashboards) {
    Copy-DashboardFile $dashboard.Source $dashboard.Dest "Binance Trading"
}

# Import System Monitoring Dashboards
Write-Host "`n=== Importing System Monitoring Dashboards ===" -ForegroundColor Cyan
$systemDashboards = @(
    @{Source="monitoring/grafana/dashboards/system-monitoring/health-overview.json"; Dest="$provisioningBase/system-monitoring/health-overview.json"},
    @{Source="monitoring/grafana/dashboards/system-monitoring/infrastructure-health.json"; Dest="$provisioningBase/system-monitoring/infrastructure-health.json"},
    @{Source="monitoring/grafana/dashboards/system-monitoring/system-health.json"; Dest="$provisioningBase/system-monitoring/system-health.json"},
    @{Source="monitoring/grafana/dashboards/system-health-fixed.json"; Dest="$provisioningBase/system-monitoring/system-health-fixed.json"}
)

foreach ($dashboard in $systemDashboards) {
    Copy-DashboardFile $dashboard.Source $dashboard.Dest "System Monitoring"
}

# Import Analytics Dashboards
Write-Host "`n=== Importing Analytics Dashboards ===" -ForegroundColor Cyan
$analyticsDashboards = @(
    @{Source="monitoring/grafana/dashboards/analytics/analytics-insights.json"; Dest="$provisioningBase/analytics/analytics-insights.json"}
)

foreach ($dashboard in $analyticsDashboards) {
    Copy-DashboardFile $dashboard.Source $dashboard.Dest "Analytics"
}

# Import Strategy Dashboards
Write-Host "`n=== Importing Strategy Dashboards ===" -ForegroundColor Cyan
$strategyDashboards = @(
    @{Source="monitoring/grafana/dashboards/strategies/btc-macd-strategy.json"; Dest="$provisioningBase/strategies/btc-macd-strategy.json"},
    @{Source="monitoring/grafana/dashboards/strategies/btc-price-chart.json"; Dest="$provisioningBase/strategies/btc-price-chart.json"},
    @{Source="monitoring/grafana/dashboards/strategies/eth-macd-strategy.json"; Dest="$provisioningBase/strategies/eth-macd-strategy.json"},
    @{Source="monitoring/grafana/dashboards/strategies/eth-price-chart.json"; Dest="$provisioningBase/strategies/eth-price-chart.json"},
    @{Source="monitoring/grafana/dashboards/strategies/order-tracker.json"; Dest="$provisioningBase/strategies/order-tracker.json"},
    @{Source="monitoring/grafana/dashboards/strategies/strategy-overview.json"; Dest="$provisioningBase/strategies/strategy-overview.json"}
)

foreach ($dashboard in $strategyDashboards) {
    Copy-DashboardFile $dashboard.Source $dashboard.Dest "Strategy"
}

# Import Enhanced Trading Dashboards
Write-Host "`n=== Importing Enhanced Trading Dashboards ===" -ForegroundColor Cyan
$enhancedDashboards = @(
    @{Source="monitoring/grafana/dashboards/enhanced-trading/enhanced-trading-dashboard.json"; Dest="$provisioningBase/enhanced-trading/enhanced-trading-dashboard.json"},
    @{Source="monitoring/grafana/dashboards/enhanced-trading-dashboard.json"; Dest="$provisioningBase/enhanced-trading/enhanced-trading-dashboard-main.json"}
)

foreach ($dashboard in $enhancedDashboards) {
    Copy-DashboardFile $dashboard.Source $dashboard.Dest "Enhanced Trading"
}

# Import Kline Data Dashboards
Write-Host "`n=== Importing Kline Data Dashboards ===" -ForegroundColor Cyan
$klineDashboards = @(
    @{Source="monitoring/grafana/dashboards/kline-data/kline-alerts.json"; Dest="$provisioningBase/kline-data/kline-alerts.json"},
    @{Source="monitoring/grafana/dashboards/kline-data/kline-collection-overview.json"; Dest="$provisioningBase/kline-data/kline-collection-overview.json"},
    @{Source="monitoring/grafana/dashboards/kline-data/kline-events-expanded.json"; Dest="$provisioningBase/kline-data/kline-events-expanded.json"},
    @{Source="monitoring/grafana/dashboards/kline-data/kline-master-dashboard.json"; Dest="$provisioningBase/kline-data/kline-master-dashboard.json"},
    @{Source="monitoring/grafana/dashboards/kline-data/kline-price-charts.json"; Dest="$provisioningBase/kline-data/kline-price-charts.json"},
    @{Source="monitoring/grafana/dashboards/kline-data/kline-storage-monitor.json"; Dest="$provisioningBase/kline-data/kline-storage-monitor.json"},
    @{Source="monitoring/grafana/dashboards/kline-data/kline-streaming-monitor.json"; Dest="$provisioningBase/kline-data/kline-streaming-monitor.json"}
)

foreach ($dashboard in $klineDashboards) {
    Copy-DashboardFile $dashboard.Source $dashboard.Dest "Kline Data"
}

# Import System Health Dashboards
Write-Host "`n=== Importing System Health Dashboards ===" -ForegroundColor Cyan
$healthDashboards = @(
    @{Source="monitoring/grafana/dashboards/simple-health-dashboard.json"; Dest="$provisioningBase/system-health/simple-health-dashboard.json"},
    @{Source="monitoring/grafana/dashboards/system-health-fixed.json"; Dest="$provisioningBase/system-health/system-health-fixed.json"}
)

foreach ($dashboard in $healthDashboards) {
    Copy-DashboardFile $dashboard.Source $dashboard.Dest "System Health"
}

# Import root-level dashboards
Write-Host "`n=== Importing Root Level Dashboards ===" -ForegroundColor Cyan
$rootDashboards = @(
    @{Source="comprehensive-metrics-dashboard.json"; Dest="$provisioningBase/binance-trading/comprehensive-metrics-dashboard.json"},
    @{Source="simple-dashboard.json"; Dest="$provisioningBase/binance-trading/simple-dashboard.json"}
)

foreach ($dashboard in $rootDashboards) {
    Copy-DashboardFile $dashboard.Source $dashboard.Dest "Root Level"
}

# Update provisioning configuration
Write-Host "`n=== Updating Provisioning Configuration ===" -ForegroundColor Cyan

$provisioningConfig = @"
apiVersion: 1

providers:
  - name: 'binance-trading-dashboards'
    orgId: 1
    folder: 'Binance Trading'
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards/binance-trading

  - name: 'system-monitoring-dashboards'
    orgId: 1
    folder: 'System Monitoring'
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards/system-monitoring

  - name: 'analytics-dashboards'
    orgId: 1
    folder: 'Analytics & Insights'
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards/analytics

  - name: 'strategy-dashboards'
    orgId: 1
    folder: 'Trading Strategies'
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards/strategies

  - name: 'enhanced-trading-dashboards'
    orgId: 1
    folder: 'Enhanced Trading'
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards/enhanced-trading

  - name: 'kline-data-dashboards'
    orgId: 1
    folder: 'Kline Data Monitoring'
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards/kline-data

  - name: 'system-health-dashboards'
    orgId: 1
    folder: 'System Health'
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards/system-health
"@

$provisioningConfig | Out-File -FilePath "monitoring/grafana/provisioning/dashboards/testnet-dashboards.yml" -Encoding UTF8
Write-Host "Updated provisioning configuration" -ForegroundColor Green

# Restart Grafana to apply changes
if (!$DryRun) {
    Write-Host "`n=== Restarting Grafana to Apply Changes ===" -ForegroundColor Cyan
    docker-compose -f docker-compose-testnet.yml restart grafana-testnet
    Start-Sleep -Seconds 15
    
    Write-Host "`n=== Verifying Grafana Status ===" -ForegroundColor Cyan
    $status = docker-compose -f docker-compose-testnet.yml ps grafana-testnet --format "table {{.Status}}"
    Write-Host "Grafana Status: $status" -ForegroundColor $(if ($status -match "Up") {"Green"} else {"Red"})
}

# Summary
Write-Host "`n=== Import Summary ===" -ForegroundColor Green
Write-Host "✅ Binance Trading Dashboards: $($binanceDashboards.Count)" -ForegroundColor Green
Write-Host "✅ System Monitoring Dashboards: $($systemDashboards.Count)" -ForegroundColor Green
Write-Host "✅ Analytics Dashboards: $($analyticsDashboards.Count)" -ForegroundColor Green
Write-Host "✅ Strategy Dashboards: $($strategyDashboards.Count)" -ForegroundColor Green
Write-Host "✅ Enhanced Trading Dashboards: $($enhancedDashboards.Count)" -ForegroundColor Green
Write-Host "✅ Kline Data Dashboards: $($klineDashboards.Count)" -ForegroundColor Green
Write-Host "✅ System Health Dashboards: $($healthDashboards.Count)" -ForegroundColor Green
Write-Host "✅ Root Level Dashboards: $($rootDashboards.Count)" -ForegroundColor Green

$totalDashboards = $binanceDashboards.Count + $systemDashboards.Count + $analyticsDashboards.Count + $strategyDashboards.Count + $enhancedDashboards.Count + $klineDashboards.Count + $healthDashboards.Count + $rootDashboards.Count

Write-Host "`n🎉 Total Dashboards Imported: $totalDashboards" -ForegroundColor Green
Write-Host "📊 Grafana URL: http://localhost:3001" -ForegroundColor Cyan
Write-Host "🔑 Default Login: admin/admin" -ForegroundColor Cyan

if (!$DryRun) {
    Write-Host "`n✅ Dashboard import completed successfully!" -ForegroundColor Green
} else {
    Write-Host "`n🔍 Dry run completed. Use -Force to apply changes." -ForegroundColor Yellow
}
