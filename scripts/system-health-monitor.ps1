# Binance AI Traders - System Health Monitor
# Comprehensive monitoring script for all system components

param(
    [switch]$Continuous,
    [int]$IntervalSeconds = 30
)

function Write-Header {
    param([string]$Title)
    Write-Host "`n=== $Title ===" -ForegroundColor Green
    Write-Host "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Yellow
}

function Check-ServiceStatus {
    Write-Header "Service Status"
    
    $services = @(
        @{Name="Trading Service"; Port=8083; Container="binance-trader-macd-testnet"},
        @{Name="Data Collection"; Port=8086; Container="binance-data-collection-testnet"},
        @{Name="Data Storage"; Port=8087; Container="binance-data-storage-testnet"},
        @{Name="Health Metrics"; Port=8092; Container="health-metrics-server-testnet"},
        @{Name="Prometheus"; Port=9091; Container="prometheus-testnet"},
        @{Name="Grafana"; Port=3001; Container="grafana-testnet"}
    )
    
    foreach ($service in $services) {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:$($service.Port)/actuator/health" -UseBasicParsing -TimeoutSec 5
            if ($response.StatusCode -eq 200) {
                Write-Host "✅ $($service.Name): HEALTHY" -ForegroundColor Green
            }
        } catch {
            Write-Host "❌ $($service.Name): UNHEALTHY" -ForegroundColor Red
        }
    }
}

function Check-TradingActivity {
    Write-Header "Trading Activity"
    
    $logs = docker logs binance-trader-macd-testnet --tail 20
    
    # Check for data fetching
    $fetchCount = ($logs | Select-String -Pattern "Fetched.*klines").Count
    if ($fetchCount -gt 0) {
        Write-Host "✅ Historical data fetching: $fetchCount recent fetches" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Historical data fetching: No recent activity" -ForegroundColor Yellow
    }
    
    # Check for MACD issues
    $macdIssues = $logs | Select-String -Pattern "Insufficient data for MACD"
    if ($macdIssues) {
        Write-Host "⚠️  MACD calculation issues detected" -ForegroundColor Yellow
        $macdIssues | Select-Object -Last 3 | ForEach-Object { Write-Host "   $_" -ForegroundColor Yellow }
    } else {
        Write-Host "✅ No MACD calculation issues" -ForegroundColor Green
    }
    
    # Check for trading signals
    $signals = $logs | Select-String -Pattern "signal|order|trade"
    if ($signals) {
        Write-Host "📊 Trading signals detected:" -ForegroundColor Cyan
        $signals | Select-Object -Last 3 | ForEach-Object { Write-Host "   $_" -ForegroundColor White }
    }
}

function Check-DataFlow {
    Write-Header "Data Flow"
    
    # Check data storage activity
    $storageLogs = docker logs binance-data-storage-testnet --tail 10
    $klineSaves = $storageLogs | Select-String -Pattern "Kline data saved successfully"
    
    if ($klineSaves) {
        Write-Host "✅ Data storage: Processing kline data" -ForegroundColor Green
        $klineSaves | Select-Object -Last 2 | ForEach-Object { Write-Host "   $_" -ForegroundColor White }
    } else {
        Write-Host "⚠️  Data storage: No recent activity" -ForegroundColor Yellow
    }
    
    # Check data collection
    $collectionLogs = docker logs binance-data-collection-testnet --tail 10
    $kafkaDisconnects = $collectionLogs | Select-String -Pattern "disconnected"
    
    if ($kafkaDisconnects) {
        Write-Host "⚠️  Kafka disconnections detected" -ForegroundColor Yellow
        $kafkaDisconnects | Select-Object -Last 2 | ForEach-Object { Write-Host "   $_" -ForegroundColor Yellow }
    } else {
        Write-Host "✅ No Kafka connection issues" -ForegroundColor Green
    }
}

function Check-Infrastructure {
    Write-Header "Infrastructure"
    
    # Check Docker containers
    $containers = docker ps --format "table {{.Names}}\t{{.Status}}" | Select-String -Pattern "binance|kafka|postgres|elasticsearch|prometheus|grafana"
    Write-Host "Container Status:" -ForegroundColor Cyan
    $containers | ForEach-Object { Write-Host "   $_" -ForegroundColor White }
    
    # Check system resources
    $stats = docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" | Select-Object -Skip 1 | Select-Object -First 5
    Write-Host "`nResource Usage (Top 5):" -ForegroundColor Cyan
    $stats | ForEach-Object { Write-Host "   $_" -ForegroundColor White }
}

function Show-Recommendations {
    Write-Header "Recommendations"
    
    Write-Host "1. IMMEDIATE: Monitor trading service for MACD calculation success" -ForegroundColor Yellow
    Write-Host "2. SHORT-TERM: Watch for Kafka connection stability" -ForegroundColor Yellow
    Write-Host "3. LONG-TERM: Consider Elasticsearch cluster for production" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Useful commands:" -ForegroundColor Cyan
    Write-Host "   docker logs binance-trader-macd-testnet --follow" -ForegroundColor White
    Write-Host "   docker restart binance-data-collection-testnet" -ForegroundColor White
    Write-Host "   .\scripts\system-health-monitor.ps1 -Continuous" -ForegroundColor White
}

function Main {
    do {
        Clear-Host
        Write-Host "Binance AI Traders - System Health Monitor" -ForegroundColor Magenta
        Write-Host "===========================================" -ForegroundColor Magenta
        
        Check-ServiceStatus
        Check-TradingActivity
        Check-DataFlow
        Check-Infrastructure
        Show-Recommendations
        
        if ($Continuous) {
            Write-Host "`nPress Ctrl+C to stop continuous monitoring..." -ForegroundColor Gray
            Start-Sleep -Seconds $IntervalSeconds
        }
    } while ($Continuous)
}

Main
