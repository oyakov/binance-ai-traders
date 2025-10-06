# Kline Data Collection Monitor
# This script continuously monitors kline data collection and storage

param(
    [int]$IntervalSeconds = 60,
    [int]$MaxIterations = 0  # 0 = run indefinitely
)

Write-Host "=== Kline Data Collection Monitor ===" -ForegroundColor Green
Write-Host "Monitoring interval: $IntervalSeconds seconds" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host ""

$iteration = 0
$totalCollected = 0

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message" -ForegroundColor $Color
}

function Test-ServiceHealth {
    param([string]$ServiceName, [string]$Url, [int]$Port)
    
    try {
        if ($Url) {
            $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 5
            return $response.StatusCode -eq 200
        } else {
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $tcpClient.Connect("localhost", $Port)
            $tcpClient.Close()
            return $true
        }
    } catch {
        return $false
    }
}

function Collect-KlineData {
    try {
        $klineResponse = Invoke-WebRequest -Uri "https://testnet.binance.vision/api/v3/klines?symbol=BTCUSDT&interval=1m&limit=1" -UseBasicParsing
        if ($klineResponse.StatusCode -eq 200) {
            $klineData = $klineResponse.Content | ConvertFrom-Json
            return $klineData[0]
        }
        return $null
    } catch {
        return $null
    }
}

function Store-KlineData {
    param([array]$KlineData)
    
    if (-not $KlineData) { return $false }
    
    $openTime = $KlineData[0]
    $closeTime = $KlineData[6]
    $timestamp = $openTime
    $displayTime = [DateTimeOffset]::FromUnixTimeMilliseconds($openTime).ToString("yyyy-MM-dd HH:mm:ss")
    $symbol = "BTCUSDT"
    $interval = "1m"
    $open = $KlineData[1]
    $high = $KlineData[2]
    $low = $KlineData[3]
    $close = $KlineData[4]
    $volume = $KlineData[5]
    
    $insertSQL = @"
INSERT INTO kline (symbol, interval, open_time, close_time, timestamp, display_time, open, high, low, close, volume)
VALUES ('$symbol', '$interval', $openTime, $closeTime, $timestamp, '$displayTime', $open, $high, $low, $close, $volume)
ON CONFLICT (symbol, interval, open_time, close_time) 
DO UPDATE SET 
    timestamp = EXCLUDED.timestamp,
    display_time = EXCLUDED.display_time,
    open = EXCLUDED.open,
    high = EXCLUDED.high,
    low = EXCLUDED.low,
    close = EXCLUDED.close,
    volume = EXCLUDED.volume;
"@
    
    try {
        $result = docker-compose -f docker-compose-testnet.yml exec -T postgres-testnet psql -U testnet_user -d binance_trader_testnet -c $insertSQL
        return $true
    } catch {
        return $false
    }
}

function Get-DatabaseStats {
    try {
        $countResult = docker-compose -f docker-compose-testnet.yml exec -T postgres-testnet psql -U testnet_user -d binance_trader_testnet -c "SELECT COUNT(*) FROM kline;"
        $count = ($countResult[2].Trim())
        return [int]$count
    } catch {
        return 0
    }
}

function Show-StatusSummary {
    Write-ColorOutput "=== STATUS SUMMARY ===" "Cyan"
    
    # Check service health
    $services = @(
        @{Name="PostgreSQL"; Url=""; Port=5433},
        @{Name="Elasticsearch"; Url="http://localhost:9202/_cluster/health"; Port=9202},
        @{Name="Kafka"; Url=""; Port=9095},
        @{Name="Schema Registry"; Url="http://localhost:8082/subjects"; Port=8082}
    )
    
    $healthyServices = 0
    foreach ($service in $services) {
        $isHealthy = Test-ServiceHealth $service.Name $service.Url $service.Port
        if ($isHealthy) {
            $healthyServices++
            Write-ColorOutput "✅ $($service.Name): Healthy" "Green"
        } else {
            Write-ColorOutput "❌ $($service.Name): Unhealthy" "Red"
        }
    }
    
    # Check Binance API
    $binanceHealthy = Test-ServiceHealth "Binance API" "https://testnet.binance.vision/api/v3/ping" 0
    if ($binanceHealthy) {
        Write-ColorOutput "✅ Binance API: Healthy" "Green"
    } else {
        Write-ColorOutput "❌ Binance API: Unhealthy" "Red"
    }
    
    # Get database stats
    $dbCount = Get-DatabaseStats
    Write-ColorOutput "📊 Total kline records in database: $dbCount" "Cyan"
    
    return $healthyServices
}

function Collect-And-Store-Data {
    Write-ColorOutput "--- Collecting Kline Data ---" "Yellow"
    
    # Collect fresh data
    $klineData = Collect-KlineData
    if ($klineData) {
        $openTime = [DateTimeOffset]::FromUnixTimeMilliseconds($klineData[0]).ToString("yyyy-MM-dd HH:mm:ss")
        $close = $klineData[4]
        $volume = $klineData[5]
        
        Write-ColorOutput "📈 Collected: BTCUSDT 1m at $openTime - Close: $close, Volume: $volume" "White"
        
        # Store data
        $stored = Store-KlineData $klineData
        if ($stored) {
            Write-ColorOutput "✅ Data stored successfully" "Green"
            return $true
        } else {
            Write-ColorOutput "❌ Failed to store data" "Red"
            return $false
        }
    } else {
        Write-ColorOutput "❌ Failed to collect data" "Red"
        return $false
    }
}

# Main monitoring loop
do {
    $iteration++
    Write-ColorOutput "=== ITERATION $iteration ===" "Cyan"
    
    # Show status
    $healthyServices = Show-StatusSummary
    
    # Collect and store data
    $dataCollected = Collect-And-Store-Data
    if ($dataCollected) {
        $totalCollected++
    }
    
    # Show summary
    Write-ColorOutput "--- Summary ---" "Yellow"
    Write-ColorOutput "Healthy services: $healthyServices/5" "White"
    Write-ColorOutput "Data collection success rate: $($totalCollected)/$iteration" "White"
    Write-ColorOutput "Total records collected: $totalCollected" "White"
    
    Write-ColorOutput "=== END OF ITERATION $iteration ===" "Cyan"
    Write-ColorOutput "Next collection in $IntervalSeconds seconds..." "Yellow"
    Write-ColorOutput "----------------------------------------" "Gray"
    
    if ($MaxIterations -gt 0 -and $iteration -ge $MaxIterations) {
        break
    }
    
    Start-Sleep -Seconds $IntervalSeconds
    
} while ($true)

Write-ColorOutput "Monitoring stopped." "Red"
Write-ColorOutput "Final stats: $totalCollected records collected in $iteration iterations" "Cyan"
