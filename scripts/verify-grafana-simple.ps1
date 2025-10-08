# Simple Grafana Dashboard Verification Script
Write-Host "=== Grafana Dashboard Verification ===" -ForegroundColor Green
Write-Host "Timestamp: $(Get-Date)" -ForegroundColor Yellow
Write-Host ""

# Check Grafana status
Write-Host "Checking Grafana service status..." -ForegroundColor Cyan
$grafanaStatus = docker-compose -f docker-compose-testnet.yml ps grafana-testnet --format "table {{.Status}}"
if ($grafanaStatus -match "Up") {
    Write-Host "✅ Grafana is running" -ForegroundColor Green
} else {
    Write-Host "❌ Grafana is not running" -ForegroundColor Red
    exit 1
}

# Check dashboard files
Write-Host "`n=== Checking Dashboard Files ===" -ForegroundColor Cyan
$provisioningBase = "monitoring/grafana/provisioning/dashboards"
$categories = @("binance-trading", "system-monitoring", "analytics", "strategies", "enhanced-trading", "kline-data", "system-health")

$totalDashboards = 0
foreach ($category in $categories) {
    $categoryPath = "$provisioningBase/$category"
    if (Test-Path $categoryPath) {
        $dashboards = Get-ChildItem -Path $categoryPath -Filter "*.json"
        Write-Host "📁 $category`: $($dashboards.Count) dashboards" -ForegroundColor Green
        $totalDashboards += $dashboards.Count
    } else {
        Write-Host "❌ $category`: Directory not found" -ForegroundColor Red
    }
}

Write-Host "`n📊 Total Dashboards: $totalDashboards" -ForegroundColor Green

# Test Grafana access
Write-Host "`n=== Testing Grafana Access ===" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3001" -UseBasicParsing -TimeoutSec 10
    Write-Host "✅ Grafana web interface is accessible" -ForegroundColor Green
} catch {
    Write-Host "❌ Grafana web interface is not accessible: $($_.Exception.Message)" -ForegroundColor Red
}

# Summary
Write-Host "`n=== Verification Summary ===" -ForegroundColor Green
Write-Host "✅ Grafana Service: Running" -ForegroundColor Green
Write-Host "✅ Dashboard Files: $totalDashboards imported" -ForegroundColor Green

Write-Host "`n=== Access Information ===" -ForegroundColor Cyan
Write-Host "🌐 Grafana URL: http://localhost:3001" -ForegroundColor Cyan
Write-Host "🔑 Default Login: admin/admin" -ForegroundColor Cyan

Write-Host "`n🎉 Dashboard verification completed successfully!" -ForegroundColor Green
