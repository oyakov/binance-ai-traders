# Fix Dashboard JSON Structure Script
# This script fixes the JSON structure of dashboard files to be compatible with Grafana

Write-Host "=== Fixing Dashboard JSON Structure ===" -ForegroundColor Green
Write-Host "Timestamp: $(Get-Date)" -ForegroundColor Yellow
Write-Host ""

# Function to fix a dashboard JSON file
function Fix-DashboardJson {
    param([string]$FilePath)
    
    if (!(Test-Path $FilePath)) {
        Write-Host "⚠️  File not found: $FilePath" -ForegroundColor Yellow
        return
    }
    
    try {
        $content = Get-Content $FilePath -Raw -Encoding UTF8
        
        # Parse JSON
        $json = $content | ConvertFrom-Json
        
        # Check if it has a nested "dashboard" structure
        if ($json.dashboard) {
            Write-Host "Fixing nested structure: $(Split-Path $FilePath -Leaf)" -ForegroundColor Cyan
            
            # Extract the dashboard content and add required fields
            $fixedDashboard = $json.dashboard
            $fixedDashboard | Add-Member -NotePropertyName "id" -NotePropertyValue $null -Force
            $fixedDashboard | Add-Member -NotePropertyName "version" -NotePropertyValue 1 -Force
            $fixedDashboard | Add-Member -NotePropertyName "schemaVersion" -NotePropertyValue 36 -Force
            
            # Ensure title exists
            if (!$fixedDashboard.title) {
                $fixedDashboard.title = "Untitled Dashboard"
            }
            
            # Save the fixed dashboard
            $fixedDashboard | ConvertTo-Json -Depth 10 | Out-File -FilePath $FilePath -Encoding UTF8
            Write-Host "✅ Fixed: $(Split-Path $FilePath -Leaf)" -ForegroundColor Green
        } else {
            # Check if it's already in the correct format
            if ($json.title) {
                Write-Host "ℹ️  Already correct format: $(Split-Path $FilePath -Leaf)" -ForegroundColor Cyan
            } else {
                Write-Host "⚠️  Unknown format: $(Split-Path $FilePath -Leaf)" -ForegroundColor Yellow
            }
        }
    }
    catch {
        Write-Host "❌ Error fixing $FilePath : $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Fix all dashboard files
Write-Host "Fixing dashboard files..." -ForegroundColor Cyan
$dashboardFiles = Get-ChildItem -Path "monitoring/grafana/provisioning/dashboards" -Recurse -Filter "*.json"

$fixedCount = 0
$totalCount = $dashboardFiles.Count

foreach ($file in $dashboardFiles) {
    Fix-DashboardJson $file.FullName
    $fixedCount++
}

Write-Host "`nFixed $fixedCount out of $totalCount dashboard files" -ForegroundColor Green

# Restart Grafana to apply changes
Write-Host "`nRestarting Grafana..." -ForegroundColor Cyan
docker-compose -f docker-compose-testnet.yml restart grafana-testnet
Start-Sleep -Seconds 15

Write-Host "`n=== Fix Summary ===" -ForegroundColor Green
Write-Host "✅ Fixed dashboard JSON structure" -ForegroundColor Green
Write-Host "✅ Restarted Grafana" -ForegroundColor Green
Write-Host "📊 Grafana URL: http://localhost:3001" -ForegroundColor Cyan
Write-Host "🔑 Default Login: admin/admin" -ForegroundColor Cyan

Write-Host "`n🎉 Dashboard JSON fixing completed!" -ForegroundColor Green
