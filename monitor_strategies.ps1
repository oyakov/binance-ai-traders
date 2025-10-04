# Strategy Monitoring Script
# Monitors all active trading strategies and their performance

param(
    [int]$IntervalSeconds = 30,
    [switch]$Continuous = $false
)

Write-Host "=== TRADING STRATEGY MONITOR ===" -ForegroundColor Green

# Function to get strategy metrics
function Get-StrategyMetrics {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8083/actuator/prometheus" -UseBasicParsing -TimeoutSec 10
        $metrics = $response.Content -split "`n" | Where-Object { $_ -match "binance_trader" -and $_ -notmatch "^#" }
        return $metrics
    }
    catch {
        Write-Host "❌ Failed to fetch metrics: $($_.Exception.Message)" -ForegroundColor Red
        return @()
    }
}

# Function to display strategy status
function Show-StrategyStatus {
    param([array]$Metrics)
    
    Write-Host "`n=== STRATEGY STATUS REPORT ===" -ForegroundColor Cyan
    Write-Host "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    
    # Extract key metrics
    $activePositions = ($Metrics | Where-Object { $_ -match "binance_trader_active_positions" }) -split " " | Select-Object -Last 1
    $totalSignals = ($Metrics | Where-Object { $_ -match "binance_trader_signals_total.*direction=.*total" }) -split " " | Select-Object -Last 1
    $buySignals = ($Metrics | Where-Object { $_ -match "binance_trader_signals_total.*direction=.*buy" }) -split " " | Select-Object -Last 1
    $sellSignals = ($Metrics | Where-Object { $_ -match "binance_trader_signals_total.*direction=.*sell" }) -split " " | Select-Object -Last 1
    $realizedPnl = ($Metrics | Where-Object { $_ -match "binance_trader_realized_pnl_quote_asset" }) -split " " | Select-Object -Last 1
    
    # Display metrics
    Write-Host "`n📊 TRADING METRICS:" -ForegroundColor Yellow
    Write-Host "  Active Positions: $activePositions" -ForegroundColor $(if ([decimal]$activePositions -gt 0) { "Green" } else { "White" })
    Write-Host "  Total Signals: $totalSignals" -ForegroundColor White
    Write-Host "  Buy Signals: $buySignals" -ForegroundColor Green
    Write-Host "  Sell Signals: $sellSignals" -ForegroundColor Red
    Write-Host "  Realized P&L: $realizedPnl USDT" -ForegroundColor $(if ([decimal]$realizedPnl -gt 0) { "Green" } elseif ([decimal]$realizedPnl -lt 0) { "Red" } else { "White" })
    
    # Strategy health check
    Write-Host "`n🔍 STRATEGY HEALTH:" -ForegroundColor Yellow
    try {
        $healthResponse = Invoke-WebRequest -Uri "http://localhost:8083/actuator/health" -UseBasicParsing -TimeoutSec 5
        if ($healthResponse.StatusCode -eq 200) {
            Write-Host "  Trading Application: ✅ HEALTHY" -ForegroundColor Green
        } else {
            Write-Host "  Trading Application: ⚠️ UNHEALTHY" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "  Trading Application: ❌ DOWN" -ForegroundColor Red
    }
    
    # Check Prometheus connectivity
    try {
        $prometheusResponse = Invoke-WebRequest -Uri "http://localhost:9091/api/v1/query?query=up" -UseBasicParsing -TimeoutSec 5
        if ($prometheusResponse.StatusCode -eq 200) {
            Write-Host "  Prometheus: ✅ CONNECTED" -ForegroundColor Green
        } else {
            Write-Host "  Prometheus: ⚠️ ISSUES" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "  Prometheus: ❌ DOWN" -ForegroundColor Red
    }
    
    # Check Grafana connectivity
    try {
        $grafanaResponse = Invoke-WebRequest -Uri "http://localhost:3001" -UseBasicParsing -TimeoutSec 5
        if ($grafanaResponse.StatusCode -eq 200) {
            Write-Host "  Grafana: ✅ CONNECTED" -ForegroundColor Green
        } else {
            Write-Host "  Grafana: ⚠️ ISSUES" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "  Grafana: ❌ DOWN" -ForegroundColor Red
    }
}

# Function to show recent trading activity
function Show-RecentActivity {
    Write-Host "`n📈 RECENT ACTIVITY:" -ForegroundColor Yellow
    
    # Check recent logs for trading activity
    try {
        $logs = docker logs binance-trader-macd-testnet --tail 20 2>&1
        $tradingLogs = $logs | Where-Object { $_ -match "signal|position|order|trade" }
        
        if ($tradingLogs.Count -gt 0) {
            Write-Host "  Recent trading activity found:" -ForegroundColor Green
            $tradingLogs | Select-Object -Last 5 | ForEach-Object {
                Write-Host "    $_" -ForegroundColor Gray
            }
        } else {
            Write-Host "  No recent trading activity" -ForegroundColor White
        }
    }
    catch {
        Write-Host "  Could not retrieve recent activity" -ForegroundColor Red
    }
}

# Function to show strategy recommendations
function Show-StrategyRecommendations {
    Write-Host "`n💡 STRATEGY RECOMMENDATIONS:" -ForegroundColor Yellow
    
    $metrics = Get-StrategyMetrics
    $activePositions = ($metrics | Where-Object { $_ -match "binance_trader_active_positions" }) -split " " | Select-Object -Last 1
    $totalSignals = ($metrics | Where-Object { $_ -match "binance_trader_signals_total.*direction=.*total" }) -split " " | Select-Object -Last 1
    
    if ([decimal]$activePositions -eq 0) {
        Write-Host "  • No active positions - consider reviewing market conditions" -ForegroundColor Cyan
    }
    
    if ([decimal]$totalSignals -eq 0) {
        Write-Host "  • No signals generated - market may be in consolidation" -ForegroundColor Cyan
    } else {
        Write-Host "  • $totalSignals signals generated - strategy is active" -ForegroundColor Green
    }
    
    Write-Host "  • Monitor multiple timeframes for better signal confirmation" -ForegroundColor Cyan
    Write-Host "  • Consider risk management adjustments based on volatility" -ForegroundColor Cyan
}

# Main monitoring loop
function Start-Monitoring {
    param([int]$Interval)
    
    do {
        Clear-Host
        Write-Host "=== TRADING STRATEGY MONITOR ===" -ForegroundColor Green
        Write-Host "Monitoring interval: $Interval seconds" -ForegroundColor Gray
        Write-Host "Press Ctrl+C to stop" -ForegroundColor Gray
        
        $metrics = Get-StrategyMetrics
        Show-StrategyStatus -Metrics $metrics
        Show-RecentActivity
        Show-StrategyRecommendations
        
        Write-Host "`n=== MONITORING LINKS ===" -ForegroundColor Cyan
        Write-Host "  Grafana Dashboards: http://localhost:3001" -ForegroundColor White
        Write-Host "  Prometheus: http://localhost:9091" -ForegroundColor White
        Write-Host "  Trading App Health: http://localhost:8083/actuator/health" -ForegroundColor White
        
        if ($Continuous) {
            Write-Host "`nNext update in $Interval seconds..." -ForegroundColor Gray
            Start-Sleep -Seconds $Interval
        }
    } while ($Continuous)
}

# Start monitoring
if ($Continuous) {
    Start-Monitoring -Interval $IntervalSeconds
} else {
    $metrics = Get-StrategyMetrics
    Show-StrategyStatus -Metrics $metrics
    Show-RecentActivity
    Show-StrategyRecommendations
}

Write-Host "`n=== MONITORING COMPLETE ===" -ForegroundColor Green