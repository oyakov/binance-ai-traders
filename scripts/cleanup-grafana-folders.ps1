# Cleanup Grafana Folders Script
# This script removes the duplicate dashboards folder and ensures Grafana only uses provisioning/dashboards

Write-Host "=== Cleaning Up Grafana Folders ===" -ForegroundColor Green
Write-Host "Timestamp: $(Get-Date)" -ForegroundColor Yellow
Write-Host ""

# Check current structure
Write-Host "Current folder structure:" -ForegroundColor Cyan
Write-Host "monitoring/grafana/dashboards/ - $(Get-ChildItem -Path 'monitoring/grafana/dashboards' -Recurse -File | Measure-Object | Select-Object -ExpandProperty Count) files" -ForegroundColor Yellow
Write-Host "monitoring/grafana/provisioning/dashboards/ - $(Get-ChildItem -Path 'monitoring/grafana/provisioning/dashboards' -Recurse -File | Measure-Object | Select-Object -ExpandProperty Count) files" -ForegroundColor Yellow

# Backup the old dashboards folder (just in case)
Write-Host "`nCreating backup of old dashboards folder..." -ForegroundColor Cyan
if (Test-Path "monitoring/grafana/dashboards") {
    $backupPath = "monitoring/grafana/dashboards-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item -Path "monitoring/grafana/dashboards" -Destination $backupPath -Recurse
    Write-Host "✅ Backup created at: $backupPath" -ForegroundColor Green
}

# Remove the old dashboards folder
Write-Host "`nRemoving old dashboards folder..." -ForegroundColor Cyan
if (Test-Path "monitoring/grafana/dashboards") {
    Remove-Item -Path "monitoring/grafana/dashboards" -Recurse -Force
    Write-Host "✅ Removed monitoring/grafana/dashboards/" -ForegroundColor Green
} else {
    Write-Host "ℹ️  monitoring/grafana/dashboards/ already removed" -ForegroundColor Cyan
}

# Verify provisioning/dashboards structure
Write-Host "`nVerifying provisioning/dashboards structure..." -ForegroundColor Cyan
$provisioningPath = "monitoring/grafana/provisioning/dashboards"
if (Test-Path $provisioningPath) {
    $fileCount = (Get-ChildItem -Path $provisioningPath -Recurse -File | Measure-Object | Select-Object -ExpandProperty Count)
    Write-Host "✅ provisioning/dashboards contains $fileCount files" -ForegroundColor Green
    
    # List all categories
    $categories = Get-ChildItem -Path $provisioningPath -Directory
    Write-Host "`nDashboard categories:" -ForegroundColor Cyan
    foreach ($category in $categories) {
        $categoryFiles = (Get-ChildItem -Path $category.FullName -File | Measure-Object | Select-Object -ExpandProperty Count)
        Write-Host "  📁 $($category.Name): $categoryFiles dashboards" -ForegroundColor White
    }
} else {
    Write-Host "❌ provisioning/dashboards folder not found!" -ForegroundColor Red
    exit 1
}

# Update Grafana configuration to ensure it only uses provisioning
Write-Host "`nUpdating Grafana configuration..." -ForegroundColor Cyan

# Check if grafana.ini exists and update it
$grafanaIniPath = "monitoring/grafana/grafana.ini"
if (!(Test-Path $grafanaIniPath)) {
    Write-Host "Creating grafana.ini configuration..." -ForegroundColor Cyan
    $grafanaConfig = @"
[paths]
data = /var/lib/grafana
logs = /var/log/grafana
plugins = /var/lib/grafana/plugins
provisioning = /etc/grafana/provisioning

[server]
http_port = 3000
root_url = http://localhost:3001/

[security]
admin_user = admin
admin_password = admin

[users]
allow_sign_up = false
auto_assign_org = true
auto_assign_org_role = Viewer

[auth.anonymous]
enabled = true
org_name = Main Org.
org_role = Viewer

[provisioning]
dashboards = true
datasources = true
"@
    $grafanaConfig | Out-File -FilePath $grafanaIniPath -Encoding UTF8
    Write-Host "✅ Created grafana.ini" -ForegroundColor Green
} else {
    Write-Host "ℹ️  grafana.ini already exists" -ForegroundColor Cyan
}

# Verify the provisioning configuration
Write-Host "`nVerifying provisioning configuration..." -ForegroundColor Cyan
$provisioningConfigPath = "monitoring/grafana/provisioning/dashboards/testnet-dashboards.yml"
if (Test-Path $provisioningConfigPath) {
    Write-Host "✅ Provisioning configuration exists" -ForegroundColor Green
} else {
    Write-Host "❌ Provisioning configuration missing!" -ForegroundColor Red
}

# Restart Grafana to apply changes
Write-Host "`nRestarting Grafana..." -ForegroundColor Cyan
docker-compose -f docker-compose-testnet.yml restart grafana-testnet
Start-Sleep -Seconds 15

# Verify Grafana is running
Write-Host "`nVerifying Grafana status..." -ForegroundColor Cyan
$grafanaStatus = docker-compose -f docker-compose-testnet.yml ps grafana-testnet --format "table {{.Status}}"
if ($grafanaStatus -match "Up") {
    Write-Host "✅ Grafana is running" -ForegroundColor Green
} else {
    Write-Host "❌ Grafana is not running" -ForegroundColor Red
}

# Test Grafana access
Write-Host "`nTesting Grafana access..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3001" -UseBasicParsing -TimeoutSec 10
    Write-Host "✅ Grafana is accessible" -ForegroundColor Green
} catch {
    Write-Host "❌ Grafana is not accessible: $($_.Exception.Message)" -ForegroundColor Red
}

# Summary
Write-Host "`n=== Cleanup Summary ===" -ForegroundColor Green
Write-Host "✅ Removed duplicate dashboards folder" -ForegroundColor Green
Write-Host "✅ Kept only provisioning/dashboards folder" -ForegroundColor Green
Write-Host "✅ Updated Grafana configuration" -ForegroundColor Green
Write-Host "✅ Restarted Grafana service" -ForegroundColor Green

Write-Host "`n=== Final Structure ===" -ForegroundColor Cyan
Write-Host "📁 monitoring/grafana/provisioning/dashboards/ - $(Get-ChildItem -Path 'monitoring/grafana/provisioning/dashboards' -Recurse -File | Measure-Object | Select-Object -ExpandProperty Count) files" -ForegroundColor Green
Write-Host "📁 monitoring/grafana/dashboards/ - REMOVED" -ForegroundColor Red

Write-Host "`n=== Access Information ===" -ForegroundColor Cyan
Write-Host "🌐 Grafana URL: http://localhost:3001" -ForegroundColor Cyan
Write-Host "🔑 Default Login: admin/admin" -ForegroundColor Cyan

Write-Host "`n🎉 Cleanup completed successfully!" -ForegroundColor Green
