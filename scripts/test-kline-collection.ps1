# Test Kline Data Collection Script
# This script tests the kline data collection from Binance testnet

Write-Host "=== Testing Kline Data Collection ===" -ForegroundColor Green

# Test Binance testnet API connectivity
Write-Host "`n1. Testing Binance Testnet API Connectivity..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri "https://testnet.binance.vision/api/v3/klines?symbol=BTCUSDT&interval=1m&limit=1" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Binance testnet API is accessible" -ForegroundColor Green
        $klineData = $response.Content | ConvertFrom-Json
        Write-Host "Sample kline data: $($klineData[0])" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Binance testnet API returned status: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Failed to connect to Binance testnet API: $($_.Exception.Message)" -ForegroundColor Red
}

# Test database connectivity
Write-Host "`n2. Testing Database Connectivity..." -ForegroundColor Yellow

try {
    $dbResult = docker-compose -f docker-compose-testnet.yml exec -T postgres-testnet psql -U testnet_user -d binance_trader_testnet -c "SELECT version();"
    if ($dbResult -match "PostgreSQL") {
        Write-Host "✅ Database is accessible" -ForegroundColor Green
        Write-Host "Database version: $($dbResult[0])" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Database connection failed" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Failed to connect to database: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Elasticsearch connectivity
Write-Host "`n3. Testing Elasticsearch Connectivity..." -ForegroundColor Yellow

try {
    $esResponse = Invoke-WebRequest -Uri "http://localhost:9202/_cluster/health" -UseBasicParsing
    if ($esResponse.StatusCode -eq 200) {
        Write-Host "✅ Elasticsearch is accessible" -ForegroundColor Green
        $esData = $esResponse.Content | ConvertFrom-Json
        Write-Host "Elasticsearch status: $($esData.status)" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Elasticsearch returned status: $($esResponse.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Failed to connect to Elasticsearch: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Kafka connectivity
Write-Host "`n4. Testing Kafka Connectivity..." -ForegroundColor Yellow

try {
    $kafkaResult = docker-compose -f docker-compose-testnet.yml exec -T kafka-testnet kafka-broker-api-versions --bootstrap-server localhost:9095
    if ($kafkaResult -match "apiVersion") {
        Write-Host "✅ Kafka is accessible" -ForegroundColor Green
    } else {
        Write-Host "❌ Kafka connection failed" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Failed to connect to Kafka: $($_.Exception.Message)" -ForegroundColor Red
}

# Test if services are running
Write-Host "`n5. Checking Service Status..." -ForegroundColor Yellow

$services = @(
    @{Name="PostgreSQL"; Port=5433},
    @{Name="Elasticsearch"; Port=9202},
    @{Name="Kafka"; Port=9095},
    @{Name="Schema Registry"; Port=8082}
)

foreach ($service in $services) {
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect("localhost", $service.Port)
        $tcpClient.Close()
        Write-Host "✅ $($service.Name) is running on port $($service.Port)" -ForegroundColor Green
    } catch {
        Write-Host "❌ $($service.Name) is not accessible on port $($service.Port)" -ForegroundColor Red
    }
}

# Test kline data collection manually
Write-Host "`n6. Testing Manual Kline Data Collection..." -ForegroundColor Yellow

try {
    # Get recent kline data
    $klineResponse = Invoke-WebRequest -Uri "https://testnet.binance.vision/api/v3/klines?symbol=BTCUSDT&interval=1m&limit=5" -UseBasicParsing
    if ($klineResponse.StatusCode -eq 200) {
        $klineData = $klineResponse.Content | ConvertFrom-Json
        Write-Host "✅ Successfully collected $($klineData.Count) kline records" -ForegroundColor Green
        
        # Display sample data
        Write-Host "`nSample kline data:" -ForegroundColor Cyan
        foreach ($kline in $klineData) {
            Write-Host "  Open Time: $([DateTimeOffset]::FromUnixTimeMilliseconds($kline[0]).DateTime)" -ForegroundColor White
            Write-Host "  Open: $($kline[1])" -ForegroundColor White
            Write-Host "  High: $($kline[2])" -ForegroundColor White
            Write-Host "  Low: $($kline[3])" -ForegroundColor White
            Write-Host "  Close: $($kline[4])" -ForegroundColor White
            Write-Host "  Volume: $($kline[5])" -ForegroundColor White
            Write-Host "  Close Time: $([DateTimeOffset]::FromUnixTimeMilliseconds($kline[6]).DateTime)" -ForegroundColor White
            Write-Host "  ---" -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "❌ Failed to collect kline data: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Test Complete ===" -ForegroundColor Green
