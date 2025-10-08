# Grafana Dashboard Import Script
Write-Host "=== Grafana Dashboard Import ===" -ForegroundColor Green
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

# Create directory structure
$provisioningBase = "monitoring/grafana/provisioning/dashboards"
$categories = @("binance-trading", "system-monitoring", "analytics", "strategies", "enhanced-trading", "kline-data", "system-health")

foreach ($category in $categories) {
    $path = "$provisioningBase/$category"
    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-Host "Created directory: $path" -ForegroundColor Green
    }
}

# Copy dashboards
Write-Host "`n=== Copying Dashboards ===" -ForegroundColor Cyan

# Binance Trading Dashboards
$binanceDashboards = @(
    "monitoring/grafana/dashboards/binance-trading/executive-overview.json",
    "monitoring/grafana/dashboards/binance-trading/macd-strategy.json",
    "monitoring/grafana/dashboards/binance-trading/simple-health-dashboard.json",
    "monitoring/grafana/dashboards/binance-trading/trading-health.json",
    "monitoring/grafana/dashboards/binance-trading/trading-operations.json",
    "monitoring/grafana/dashboards/binance-trading/trading-overview.json",
    "monitoring/grafana/dashboards/binance-macd-testnet.json"
)

foreach ($dashboard in $binanceDashboards) {
    if (Test-Path $dashboard) {
        $dest = $dashboard -replace "monitoring/grafana/dashboards/", "$provisioningBase/"
        $destDir = Split-Path $dest -Parent
        if (!(Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        Copy-Item $dashboard $dest -Force
        Write-Host "✅ Copied: $(Split-Path $dashboard -Leaf)" -ForegroundColor Green
    }
}

# System Monitoring Dashboards
$systemDashboards = @(
    "monitoring/grafana/dashboards/system-monitoring/health-overview.json",
    "monitoring/grafana/dashboards/system-monitoring/infrastructure-health.json",
    "monitoring/grafana/dashboards/system-monitoring/system-health.json",
    "monitoring/grafana/dashboards/system-health-fixed.json"
)

foreach ($dashboard in $systemDashboards) {
    if (Test-Path $dashboard) {
        $dest = $dashboard -replace "monitoring/grafana/dashboards/", "$provisioningBase/"
        $destDir = Split-Path $dest -Parent
        if (!(Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        Copy-Item $dashboard $dest -Force
        Write-Host "✅ Copied: $(Split-Path $dashboard -Leaf)" -ForegroundColor Green
    }
}

# Strategy Dashboards
$strategyDashboards = @(
    "monitoring/grafana/dashboards/strategies/btc-macd-strategy.json",
    "monitoring/grafana/dashboards/strategies/btc-price-chart.json",
    "monitoring/grafana/dashboards/strategies/eth-macd-strategy.json",
    "monitoring/grafana/dashboards/strategies/eth-price-chart.json",
    "monitoring/grafana/dashboards/strategies/order-tracker.json",
    "monitoring/grafana/dashboards/strategies/strategy-overview.json"
)

foreach ($dashboard in $strategyDashboards) {
    if (Test-Path $dashboard) {
        $dest = $dashboard -replace "monitoring/grafana/dashboards/", "$provisioningBase/"
        $destDir = Split-Path $dest -Parent
        if (!(Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        Copy-Item $dashboard $dest -Force
        Write-Host "✅ Copied: $(Split-Path $dashboard -Leaf)" -ForegroundColor Green
    }
}

# Kline Data Dashboards
$klineDashboards = @(
    "monitoring/grafana/dashboards/kline-data/kline-alerts.json",
    "monitoring/grafana/dashboards/kline-data/kline-collection-overview.json",
    "monitoring/grafana/dashboards/kline-data/kline-events-expanded.json",
    "monitoring/grafana/dashboards/kline-data/kline-master-dashboard.json",
    "monitoring/grafana/dashboards/kline-data/kline-price-charts.json",
    "monitoring/grafana/dashboards/kline-data/kline-storage-monitor.json",
    "monitoring/grafana/dashboards/kline-data/kline-streaming-monitor.json"
)

foreach ($dashboard in $klineDashboards) {
    if (Test-Path $dashboard) {
        $dest = $dashboard -replace "monitoring/grafana/dashboards/", "$provisioningBase/"
        $destDir = Split-Path $dest -Parent
        if (!(Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        Copy-Item $dashboard $dest -Force
        Write-Host "✅ Copied: $(Split-Path $dashboard -Leaf)" -ForegroundColor Green
    }
}

# Enhanced Trading Dashboards
$enhancedDashboards = @(
    "monitoring/grafana/dashboards/enhanced-trading/enhanced-trading-dashboard.json",
    "monitoring/grafana/dashboards/enhanced-trading-dashboard.json"
)

foreach ($dashboard in $enhancedDashboards) {
    if (Test-Path $dashboard) {
        $dest = $dashboard -replace "monitoring/grafana/dashboards/", "$provisioningBase/"
        $destDir = Split-Path $dest -Parent
        if (!(Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        Copy-Item $dashboard $dest -Force
        Write-Host "✅ Copied: $(Split-Path $dashboard -Leaf)" -ForegroundColor Green
    }
}

# Analytics Dashboards
$analyticsDashboards = @(
    "monitoring/grafana/dashboards/analytics/analytics-insights.json"
)

foreach ($dashboard in $analyticsDashboards) {
    if (Test-Path $dashboard) {
        $dest = $dashboard -replace "monitoring/grafana/dashboards/", "$provisioningBase/"
        $destDir = Split-Path $dest -Parent
        if (!(Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        Copy-Item $dashboard $dest -Force
        Write-Host "✅ Copied: $(Split-Path $dashboard -Leaf)" -ForegroundColor Green
    }
}

# Root level dashboards
$rootDashboards = @(
    "comprehensive-metrics-dashboard.json",
    "simple-dashboard.json"
)

foreach ($dashboard in $rootDashboards) {
    if (Test-Path $dashboard) {
        $dest = "$provisioningBase/binance-trading/$dashboard"
        Copy-Item $dashboard $dest -Force
        Write-Host "✅ Copied: $dashboard" -ForegroundColor Green
    }
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
Write-Host "✅ Updated provisioning configuration" -ForegroundColor Green

# Restart Grafana
Write-Host "`n=== Restarting Grafana ===" -ForegroundColor Cyan
docker-compose -f docker-compose-testnet.yml restart grafana-testnet
Start-Sleep -Seconds 15

Write-Host "`n=== Summary ===" -ForegroundColor Green
Write-Host "✅ Dashboard import completed successfully!" -ForegroundColor Green
Write-Host "📊 Grafana URL: http://localhost:3001" -ForegroundColor Cyan
Write-Host "🔑 Default Login: admin/admin" -ForegroundColor Cyan
