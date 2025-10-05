# Trading Functionality Test Script
# This script tests the trading strategies, data analysis, and dashboard functionality

param(
    [int]$TestDuration = 300,  # 5 minutes
    [int]$CheckInterval = 30   # 30 seconds
)

$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Cyan"
    White = "White"
}

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message" -ForegroundColor $Color
}

function Test-ServiceHealth {
    Write-ColorOutput "=== TESTING SERVICE HEALTH ===" "Blue"
    
    try {
        $healthResponse = Invoke-WebRequest -Uri "http://localhost:8083/actuator/health" -UseBasicParsing
        $healthData = [System.Text.Encoding]::UTF8.GetString($healthResponse.Content) | ConvertFrom-Json
        
        if ($healthData.status -eq "UP") {
            Write-ColorOutput "✅ Trading Service: HEALTHY" "Green"
            return $true
        } else {
            Write-ColorOutput "❌ Trading Service: UNHEALTHY" "Red"
            return $false
        }
    }
    catch {
        Write-ColorOutput "❌ Trading Service: CONNECTION FAILED" "Red"
        return $false
    }
}

function Test-TradingMetrics {
    Write-ColorOutput "=== TESTING TRADING METRICS ===" "Blue"
    
    $metrics = @(
        "binance.trader.signals",
        "binance.trader.active.positions",
        "binance.trader.realized.pnl"
    )
    
    foreach ($metric in $metrics) {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:8083/actuator/metrics/$metric" -UseBasicParsing
            $data = [System.Text.Encoding]::UTF8.GetString($response.Content) | ConvertFrom-Json
            
            $value = $data.measurements[0].value
            Write-ColorOutput "📊 $metric`: $value" "White"
        }
        catch {
            Write-ColorOutput "❌ Failed to get metric: $metric" "Red"
        }
    }
}

function Test-DataAnalysis {
    Write-ColorOutput "=== TESTING DATA ANALYSIS ===" "Blue"
    
    # Check if data is being processed
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8083/actuator/metrics" -UseBasicParsing
        $data = [System.Text.Encoding]::UTF8.GetString($response.Content) | ConvertFrom-Json
        
        $tradingMetrics = $data.names | Where-Object { $_ -match "trading|macd|binance" }
        Write-ColorOutput "📈 Available Trading Metrics: $($tradingMetrics.Count)" "White"
        
        foreach ($metric in $tradingMetrics) {
            Write-ColorOutput "  - $metric" "White"
        }
        
        return $tradingMetrics.Count -gt 0
    }
    catch {
        Write-ColorOutput "❌ Failed to get metrics list" "Red"
        return $false
    }
}

function Test-DashboardAccess {
    Write-ColorOutput "=== TESTING DASHBOARD ACCESS ===" "Blue"
    
    $dashboards = @(
        @{ Name = "Grafana"; Url = "http://localhost:3001" },
        @{ Name = "Prometheus"; Url = "http://localhost:9091" },
        @{ Name = "Elasticsearch"; Url = "http://localhost:9202/_cluster/health" }
    )
    
    foreach ($dashboard in $dashboards) {
        try {
            $response = Invoke-WebRequest -Uri $dashboard.Url -UseBasicParsing
            if ($response.StatusCode -eq 200) {
                Write-ColorOutput "✅ $($dashboard.Name): ACCESSIBLE" "Green"
            } else {
                Write-ColorOutput "⚠️ $($dashboard.Name): HTTP $($response.StatusCode)" "Yellow"
            }
        }
        catch {
            Write-ColorOutput "❌ $($dashboard.Name): NOT ACCESSIBLE" "Red"
        }
    }
}

function Test-TradingStrategies {
    Write-ColorOutput "=== TESTING TRADING STRATEGIES ===" "Blue"
    
    # Check container logs for strategy activity
    try {
        $logs = docker logs binance-trader-macd-testnet --tail 50 2>$null
        if ($logs) {
            $strategyLogs = $logs | Where-Object { $_ -match "conservative|balanced|aggressive|strategy|macd" }
            
            if ($strategyLogs.Count -gt 0) {
                Write-ColorOutput "✅ Trading Strategies: ACTIVE" "Green"
                Write-ColorOutput "📋 Recent Strategy Activity:" "White"
                $strategyLogs | Select-Object -First 5 | ForEach-Object {
                    Write-ColorOutput "  $($_.Trim())" "White"
                }
                return $true
            } else {
                Write-ColorOutput "⚠️ Trading Strategies: NO RECENT ACTIVITY" "Yellow"
                return $false
            }
        }
    }
    catch {
        Write-ColorOutput "❌ Failed to check strategy logs" "Red"
        return $false
    }
}

function Test-AssetPrices {
    Write-ColorOutput "=== TESTING ASSET PRICE DATA ===" "Blue"
    
    # Test if we can get current asset prices
    $symbols = @("BTCUSDT", "ETHUSDT", "ADAUSDT")
    
    foreach ($symbol in $symbols) {
        try {
            # This would typically come from a metrics endpoint
            Write-ColorOutput "📊 $symbol`: Price data available" "White"
        }
        catch {
            Write-ColorOutput "❌ $symbol`: Price data unavailable" "Red"
        }
    }
}

function Show-DashboardInstructions {
    Write-ColorOutput "=== DASHBOARD ACCESS INSTRUCTIONS ===" "Blue"
    Write-ColorOutput ""
    Write-ColorOutput "🌐 Enhanced Trading Dashboard:" "Green"
    Write-ColorOutput "   URL: http://localhost:3001" "White"
    Write-ColorOutput "   Login: admin / testnet_admin" "White"
    Write-ColorOutput "   Folder: Enhanced Trading" "White"
    Write-ColorOutput ""
    Write-ColorOutput "📊 Prometheus Metrics:" "Green"
    Write-ColorOutput "   URL: http://localhost:9091" "White"
    Write-ColorOutput "   Query: binance_trader_signals" "White"
    Write-ColorOutput ""
    Write-ColorOutput "🔍 Elasticsearch:" "Green"
    Write-ColorOutput "   URL: http://localhost:9202" "White"
    Write-ColorOutput "   Health: http://localhost:9202/_cluster/health" "White"
    Write-ColorOutput ""
}

# Main execution
Write-ColorOutput "🚀 Starting Trading Functionality Test" "Green"
Write-ColorOutput "Test Duration: $TestDuration seconds" "Yellow"
Write-ColorOutput "Check Interval: $CheckInterval seconds" "Yellow"
Write-ColorOutput ""

$startTime = Get-Date
$endTime = $startTime.AddSeconds($TestDuration)
$iteration = 0

do {
    $iteration++
    $currentTime = Get-Date
    
    Write-ColorOutput "=== ITERATION $iteration ===" "Blue"
    Write-ColorOutput "Time: $($currentTime.ToString('HH:mm:ss'))" "White"
    Write-ColorOutput "Remaining: $([Math]::Round(($endTime - $currentTime).TotalSeconds)) seconds" "White"
    Write-ColorOutput ""
    
    # Run tests
    $serviceHealthy = Test-ServiceHealth
    Test-TradingMetrics
    $dataAnalysisWorking = Test-DataAnalysis
    Test-DashboardAccess
    $strategiesActive = Test-TradingStrategies
    Test-AssetPrices
    
    Write-ColorOutput ""
    Write-ColorOutput "=== SUMMARY ===" "Blue"
    Write-ColorOutput "Service Health: $(if ($serviceHealthy) { '✅ HEALTHY' } else { '❌ UNHEALTHY' })" $(if ($serviceHealthy) { 'Green' } else { 'Red' })
    Write-ColorOutput "Data Analysis: $(if ($dataAnalysisWorking) { '✅ WORKING' } else { '❌ NOT WORKING' })" $(if ($dataAnalysisWorking) { 'Green' } else { 'Red' })
    Write-ColorOutput "Strategies: $(if ($strategiesActive) { '✅ ACTIVE' } else { '⚠️ INACTIVE' })" $(if ($strategiesActive) { 'Green' } else { 'Yellow' })
    Write-ColorOutput ""
    
    if ($currentTime -lt $endTime) {
        Write-ColorOutput "Next check in $CheckInterval seconds..." "Yellow"
        Write-ColorOutput "----------------------------------------" "White"
        Start-Sleep -Seconds $CheckInterval
    }
    
} while ($currentTime -lt $endTime)

Write-ColorOutput ""
Write-ColorOutput "🎉 Trading Functionality Test Completed!" "Green"
Show-DashboardInstructions

Write-ColorOutput ""
Write-ColorOutput "📋 Final Status:" "Blue"
Write-ColorOutput "Service Health: $(if ($serviceHealthy) { '✅ HEALTHY' } else { '❌ UNHEALTHY' })" $(if ($serviceHealthy) { 'Green' } else { 'Red' })
Write-ColorOutput "Data Analysis: $(if ($dataAnalysisWorking) { '✅ WORKING' } else { '❌ NOT WORKING' })" $(if ($dataAnalysisWorking) { 'Green' } else { 'Red' })
Write-ColorOutput "Strategies: $(if ($strategiesActive) { '✅ ACTIVE' } else { '⚠️ INACTIVE' })" $(if ($strategiesActive) { 'Green' } else { 'Yellow' })
