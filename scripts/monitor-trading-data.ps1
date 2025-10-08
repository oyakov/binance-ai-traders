# Trading Service Data Flow Monitor
# This script monitors the trading service data flow and identifies issues

Write-Host "=== Binance AI Traders - Trading Service Data Monitor ===" -ForegroundColor Green
Write-Host "Timestamp: $(Get-Date)" -ForegroundColor Yellow
Write-Host ""

# Function to check trading service logs
function Check-TradingLogs {
    Write-Host "--- Trading Service Recent Activity ---" -ForegroundColor Cyan
    
    # Get recent logs
    $logs = docker logs binance-trader-macd-testnet --tail 20
    
    # Check for data fetching
    $fetchLogs = $logs | Select-String -Pattern "Fetched.*klines"
    if ($fetchLogs) {
        Write-Host "✅ Historical data fetching: ACTIVE" -ForegroundColor Green
        $fetchLogs | ForEach-Object { Write-Host "   $_" -ForegroundColor White }
    } else {
        Write-Host "❌ Historical data fetching: INACTIVE" -ForegroundColor Red
    }
    
    # Check for MACD calculation issues
    $macdIssues = $logs | Select-String -Pattern "Insufficient data for MACD|No more data available"
    if ($macdIssues) {
        Write-Host "⚠️  MACD calculation issues detected:" -ForegroundColor Yellow
        $macdIssues | ForEach-Object { Write-Host "   $_" -ForegroundColor Yellow }
    } else {
        Write-Host "✅ No MACD calculation issues" -ForegroundColor Green
    }
    
    # Check for trading signals
    $signals = $logs | Select-String -Pattern "signal|order|trade"
    if ($signals) {
        Write-Host "📊 Trading activity:" -ForegroundColor Cyan
        $signals | ForEach-Object { Write-Host "   $_" -ForegroundColor White }
    }
}

# Function to check data storage
function Check-DataStorage {
    Write-Host "`n--- Data Storage Activity ---" -ForegroundColor Cyan
    
    $storageLogs = docker logs binance-data-storage-testnet --tail 10
    $klineSaves = $storageLogs | Select-String -Pattern "Kline data saved successfully"
    
    if ($klineSaves) {
        Write-Host "✅ Data storage: ACTIVE" -ForegroundColor Green
        $klineSaves | Select-Object -Last 3 | ForEach-Object { Write-Host "   $_" -ForegroundColor White }
    } else {
        Write-Host "❌ Data storage: INACTIVE" -ForegroundColor Red
    }
}

# Function to check service health
function Check-ServiceHealth {
    Write-Host "`n--- Service Health Status ---" -ForegroundColor Cyan
    
    try {
        $tradingHealth = Invoke-WebRequest -Uri "http://localhost:8083/actuator/health" -UseBasicParsing
        if ($tradingHealth.StatusCode -eq 200) {
            Write-Host "✅ Trading Service: HEALTHY" -ForegroundColor Green
        }
    } catch {
        Write-Host "❌ Trading Service: UNHEALTHY" -ForegroundColor Red
    }
    
    try {
        $storageHealth = Invoke-WebRequest -Uri "http://localhost:8087/actuator/health" -UseBasicParsing
        if ($storageHealth.StatusCode -eq 200) {
            Write-Host "✅ Data Storage: HEALTHY" -ForegroundColor Green
        }
    } catch {
        Write-Host "❌ Data Storage: UNHEALTHY" -ForegroundColor Red
    }
}

# Function to check Kafka connectivity
function Check-KafkaConnectivity {
    Write-Host "`n--- Kafka Connectivity ---" -ForegroundColor Cyan
    
    $kafkaLogs = docker logs kafka-testnet --tail 5
    $kafkaActive = $kafkaLogs | Select-String -Pattern "started|ready"
    
    if ($kafkaActive) {
        Write-Host "✅ Kafka: ACTIVE" -ForegroundColor Green
    } else {
        Write-Host "❌ Kafka: ISSUES DETECTED" -ForegroundColor Red
    }
    
    # Check data collection Kafka issues
    $collectionLogs = docker logs binance-data-collection-testnet --tail 10
    $kafkaDisconnects = $collectionLogs | Select-String -Pattern "disconnected"
    
    if ($kafkaDisconnects) {
        Write-Host "⚠️  Data Collection Kafka disconnections:" -ForegroundColor Yellow
        $kafkaDisconnects | ForEach-Object { Write-Host "   $_" -ForegroundColor Yellow }
    } else {
        Write-Host "✅ No Kafka disconnection issues" -ForegroundColor Green
    }
}

# Function to provide recommendations
function Show-Recommendations {
    Write-Host "`n--- Recommendations ---" -ForegroundColor Magenta
    
    Write-Host "1. IMMEDIATE: Check if trading service needs restart to sync data" -ForegroundColor Yellow
    Write-Host "2. SHORT-TERM: Monitor Kafka connection stability" -ForegroundColor Yellow
    Write-Host "3. LONG-TERM: Consider Elasticsearch cluster setup" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Commands to try:" -ForegroundColor Cyan
    Write-Host "   docker restart binance-trader-macd-testnet" -ForegroundColor White
    Write-Host "   docker logs binance-trader-macd-testnet --follow" -ForegroundColor White
}

# Main execution
Check-TradingLogs
Check-DataStorage
Check-ServiceHealth
Check-KafkaConnectivity
Show-Recommendations

Write-Host "`n=== Monitor Complete ===" -ForegroundColor Green