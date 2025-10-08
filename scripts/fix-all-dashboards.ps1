# Fix All Dashboard JSON Files Script
# This script fixes JSON structure, removes nested wrappers, ensures proper titles, and fixes encoding

Write-Host "=== Fixing All Dashboard JSON Files ===" -ForegroundColor Green
Write-Host "Timestamp: $(Get-Date)" -ForegroundColor Yellow
Write-Host ""

# Function to fix a single dashboard file
function Fix-DashboardFile {
    param([string]$FilePath)
    
    if (!(Test-Path $FilePath)) {
        Write-Host "⚠️  File not found: $FilePath" -ForegroundColor Yellow
        return $false
    }
    
    try {
        # Read file with UTF-8 encoding
        $content = Get-Content $FilePath -Raw -Encoding UTF8
        
        # Skip if file is empty
        if ([string]::IsNullOrWhiteSpace($content)) {
            Write-Host "⚠️  Empty file: $(Split-Path $FilePath -Leaf)" -ForegroundColor Yellow
            return $false
        }
        
        # Parse JSON
        $json = $content | ConvertFrom-Json
        
        $fixed = $false
        $dashboard = $null
        
        # Check if it has a nested "dashboard" structure
        if ($json.dashboard) {
            Write-Host "Fixing nested structure: $(Split-Path $FilePath -Leaf)" -ForegroundColor Cyan
            $dashboard = $json.dashboard
            $fixed = $true
        } else {
            $dashboard = $json
        }
        
        # Ensure required fields exist
        if (!$dashboard.title) {
            $dashboard.title = "Untitled Dashboard - $(Get-Date -Format 'yyyy-MM-dd')"
            $fixed = $true
        }
        
        if (!$dashboard.id) {
            $dashboard.id = $null
            $fixed = $true
        }
        
        if (!$dashboard.version) {
            $dashboard.version = 1
            $fixed = $true
        }
        
        if (!$dashboard.schemaVersion) {
            $dashboard.schemaVersion = 36
            $fixed = $true
        }
        
        if (!$dashboard.time) {
            $dashboard.time = @{
                from = "now-1h"
                to = "now"
            }
            $fixed = $true
        }
        
        if (!$dashboard.refresh) {
            $dashboard.refresh = "30s"
            $fixed = $true
        }
        
        if (!$dashboard.tags) {
            $dashboard.tags = @("general")
            $fixed = $true
        }
        
        if (!$dashboard.panels) {
            $dashboard.panels = @()
            $fixed = $true
        }
        
        # Ensure panels have required fields
        if ($dashboard.panels) {
            foreach ($panel in $dashboard.panels) {
                if (!$panel.id) {
                    $panel.id = 1
                    $fixed = $true
                }
                if (!$panel.gridPos) {
                    $panel.gridPos = @{
                        h = 8
                        w = 12
                        x = 0
                        y = 0
                    }
                    $fixed = $true
                }
            }
        }
        
        # Save the fixed dashboard with UTF-8 encoding
        if ($fixed) {
            $dashboard | ConvertTo-Json -Depth 10 | Out-File -FilePath $FilePath -Encoding UTF8 -NoNewline
            Write-Host "✅ Fixed: $(Split-Path $FilePath -Leaf)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "ℹ️  No changes needed: $(Split-Path $FilePath -Leaf)" -ForegroundColor Cyan
            return $true
        }
    }
    catch {
        Write-Host "❌ Error fixing $FilePath : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Get all dashboard files
Write-Host "Finding dashboard files..." -ForegroundColor Cyan
$dashboardFiles = Get-ChildItem -Path "monitoring/grafana/provisioning/dashboards" -Recurse -Filter "*.json"

$totalFiles = $dashboardFiles.Count
$fixedFiles = 0
$errorFiles = 0

Write-Host "Found $totalFiles dashboard files" -ForegroundColor Cyan
Write-Host ""

# Process each file
foreach ($file in $dashboardFiles) {
    if (Fix-DashboardFile $file.FullName) {
        $fixedFiles++
    } else {
        $errorFiles++
    }
}

Write-Host "`n=== Fix Summary ===" -ForegroundColor Green
Write-Host "Total files processed: $totalFiles" -ForegroundColor White
Write-Host "Successfully fixed: $fixedFiles" -ForegroundColor Green
Write-Host "Errors: $errorFiles" -ForegroundColor Red

# Restart Grafana to apply changes
Write-Host "`nRestarting Grafana..." -ForegroundColor Cyan
docker-compose -f docker-compose-testnet.yml restart grafana-testnet
Start-Sleep -Seconds 15

# Check Grafana status
Write-Host "`nChecking Grafana status..." -ForegroundColor Cyan
$grafanaStatus = docker-compose -f docker-compose-testnet.yml ps grafana-testnet --format "table {{.Status}}"
if ($grafanaStatus -match "Up") {
    Write-Host "✅ Grafana is running" -ForegroundColor Green
} else {
    Write-Host "❌ Grafana is not running" -ForegroundColor Red
}

Write-Host "`n=== Access Information ===" -ForegroundColor Cyan
Write-Host "🌐 Grafana URL: http://localhost:3001" -ForegroundColor Cyan
Write-Host "🔑 Default Login: admin/admin" -ForegroundColor Cyan

Write-Host "`n🎉 Dashboard fixing completed!" -ForegroundColor Green
