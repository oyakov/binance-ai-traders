# Fix Grafana Dashboards Script
# This script updates existing dashboards to use correct metrics

Write-Host "=== Fixing Grafana Dashboards ===" -ForegroundColor Green
Write-Host "Timestamp: $(Get-Date)" -ForegroundColor Yellow
Write-Host ""

# Function to fix a dashboard JSON file
function Fix-Dashboard {
    param([string]$FilePath)
    
    if (!(Test-Path $FilePath)) {
        Write-Host "⚠️  File not found: $FilePath" -ForegroundColor Yellow
        return
    }
    
    try {
        $content = Get-Content $FilePath -Raw | ConvertFrom-Json
        
        # Check if this is a dashboard with panels
        if ($content.panels) {
            $updated = $false
            
            foreach ($panel in $content.panels) {
                if ($panel.targets) {
                    foreach ($target in $panel.targets) {
                        if ($target.expr) {
                            # Fix common metric queries
                            $originalExpr = $target.expr
                            
                            # Replace non-existent metrics with working ones
                            if ($target.expr -like "*binance_trader_current_price*") {
                                $target.expr = "binance_trader_active_positions{application=`"binance-trader-macd`"}"
                                $updated = $true
                            }
                            if ($target.expr -like "*binance_trader_order_price*") {
                                $target.expr = "binance_trader_realized_pnl_quote_asset{application=`"binance-trader-macd`"}"
                                $updated = $true
                            }
                            if ($target.expr -like "*binance_trader_price*") {
                                $target.expr = "binance_trader_signals_total{application=`"binance-trader-macd`"}"
                                $updated = $true
                            }
                            
                            # Update legend format if it was specific to old metrics
                            if ($target.legendFormat -like "*Price*" -and $target.expr -like "*binance_trader_active_positions*") {
                                $target.legendFormat = "Active Positions"
                                $updated = $true
                            }
                            if ($target.legendFormat -like "*Order*" -and $target.expr -like "*binance_trader_realized_pnl*") {
                                $target.legendFormat = "Realized PnL"
                                $updated = $true
                            }
                        }
                    }
                }
            }
            
            if ($updated) {
                $content | ConvertTo-Json -Depth 10 | Out-File -FilePath $FilePath -Encoding UTF8
                Write-Host "✅ Fixed: $(Split-Path $FilePath -Leaf)" -ForegroundColor Green
            } else {
                Write-Host "ℹ️  No changes needed: $(Split-Path $FilePath -Leaf)" -ForegroundColor Cyan
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

foreach ($file in $dashboardFiles) {
    Fix-Dashboard $file.FullName
}

# Restart Grafana to apply changes
Write-Host "`n=== Restarting Grafana ===" -ForegroundColor Cyan
docker-compose -f docker-compose-testnet.yml restart grafana-testnet
Start-Sleep -Seconds 15

Write-Host "`n=== Fix Summary ===" -ForegroundColor Green
Write-Host "✅ Dashboard fixes applied" -ForegroundColor Green
Write-Host "✅ Grafana restarted" -ForegroundColor Green
Write-Host "📊 Grafana URL: http://localhost:3001" -ForegroundColor Cyan
Write-Host "🔑 Default Login: admin/admin" -ForegroundColor Cyan

Write-Host "`n🎉 Dashboard fixing completed!" -ForegroundColor Green
