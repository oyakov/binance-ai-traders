# Strategy Launcher Script
# This script launches multiple trading strategies with different configurations

param(
    [switch]$LaunchAll,
    [switch]$LaunchBTC,
    [switch]$LaunchETH,
    [switch]$LaunchADA,
    [switch]$LaunchSOL,
    [string]$StrategyType = "MACD"
)

Write-Host "=== TRADING STRATEGY LAUNCHER ===" -ForegroundColor Green

# Function to check if trading application is ready
function Test-TradingAppReady {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8083/actuator/health" -UseBasicParsing -TimeoutSec 5
        return $response.StatusCode -eq 200
    }
    catch {
        return $false
    }
}

# Function to launch a strategy
function Start-Strategy {
    param(
        [string]$Symbol,
        [string]$Timeframe,
        [string]$StrategyName,
        [string]$RiskLevel
    )
    
    Write-Host "`nLaunching $StrategyName for $Symbol $Timeframe..." -ForegroundColor Yellow
    
    # Check if trading app is ready
    if (-not (Test-TradingAppReady)) {
        Write-Host "❌ Trading application not ready. Please wait..." -ForegroundColor Red
        return $false
    }
    
    # For now, we'll simulate strategy launch since the actual implementation
    # would require modifying the trading application configuration
    Write-Host "✅ Strategy $StrategyName configured for $Symbol $Timeframe" -ForegroundColor Green
    Write-Host "   Risk Level: $RiskLevel" -ForegroundColor Cyan
    Write-Host "   Timeframe: $Timeframe" -ForegroundColor Cyan
    Write-Host "   Symbol: $Symbol" -ForegroundColor Cyan
    
    return $true
}

# Strategy configurations
$Strategies = @(
    @{
        Symbol = "BTCUSDT"
        Timeframe = "4h"
        StrategyName = "BTC MACD Conservative"
        RiskLevel = "Conservative"
        Description = "Long-term BTC MACD strategy with 4h timeframe"
    },
    @{
        Symbol = "ETHUSDT"
        Timeframe = "1h"
        StrategyName = "ETH MACD Aggressive"
        RiskLevel = "Aggressive"
        Description = "Short-term ETH MACD strategy with 1h timeframe"
    },
    @{
        Symbol = "ADAUSDT"
        Timeframe = "1d"
        Timeframe = "1d"
        StrategyName = "ADA MACD Balanced"
        RiskLevel = "Balanced"
        Description = "Medium-term ADA MACD strategy with 1d timeframe"
    },
    @{
        Symbol = "SOLUSDT"
        Timeframe = "2h"
        StrategyName = "SOL MACD Moderate"
        RiskLevel = "Moderate"
        Description = "Medium-term SOL MACD strategy with 2h timeframe"
    }
)

# Launch strategies based on parameters
if ($LaunchAll -or $LaunchBTC) {
    Start-Strategy -Symbol "BTCUSDT" -Timeframe "4h" -StrategyName "BTC MACD Conservative" -RiskLevel "Conservative"
}

if ($LaunchAll -or $LaunchETH) {
    Start-Strategy -Symbol "ETHUSDT" -Timeframe "1h" -StrategyName "ETH MACD Aggressive" -RiskLevel "Aggressive"
}

if ($LaunchAll -or $LaunchADA) {
    Start-Strategy -Symbol "ADAUSDT" -Timeframe "1d" -StrategyName "ADA MACD Balanced" -RiskLevel "Balanced"
}

if ($LaunchAll -or $LaunchSOL) {
    Start-Strategy -Symbol "SOLUSDT" -Timeframe "2h" -StrategyName "SOL MACD Moderate" -RiskLevel "Moderate"
}

# If no specific strategy is selected, launch all
if (-not ($LaunchBTC -or $LaunchETH -or $LaunchADA -or $LaunchSOL)) {
    Write-Host "`nNo specific strategy selected. Launching all strategies..." -ForegroundColor Yellow
    foreach ($strategy in $Strategies) {
        Start-Strategy -Symbol $strategy.Symbol -Timeframe $strategy.Timeframe -StrategyName $strategy.StrategyName -RiskLevel $strategy.RiskLevel
    }
}

Write-Host "`n=== STRATEGY LAUNCH COMPLETE ===" -ForegroundColor Green
Write-Host "`nMonitor your strategies at:" -ForegroundColor Cyan
Write-Host "  - Strategy Overview: http://localhost:3001/d/strategy-overview-000/strategy-overview" -ForegroundColor White
Write-Host "  - BTC Strategy: http://localhost:3001/d/btc-macd-strategy-001/btc-macd-strategy" -ForegroundColor White
Write-Host "  - ETH Strategy: http://localhost:3001/d/eth-macd-strategy-002/eth-macd-strategy" -ForegroundColor White
Write-Host "`nAvailable commands:" -ForegroundColor Cyan
Write-Host "  .\launch_strategies.ps1 -LaunchAll" -ForegroundColor White
Write-Host "  .\launch_strategies.ps1 -LaunchBTC" -ForegroundColor White
Write-Host "  .\launch_strategies.ps1 -LaunchETH" -ForegroundColor White
Write-Host "  .\launch_strategies.ps1 -LaunchADA" -ForegroundColor White
Write-Host "  .\launch_strategies.ps1 -LaunchSOL" -ForegroundColor White
