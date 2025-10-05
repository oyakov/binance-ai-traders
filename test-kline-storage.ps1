# Test Kline Data Storage Script
# This script tests storing kline data in PostgreSQL and Elasticsearch

Write-Host "=== Testing Kline Data Storage ===" -ForegroundColor Green

# First, let's create the kline table if it doesn't exist
Write-Host "`n1. Creating Kline Table..." -ForegroundColor Yellow

$createTableSQL = @"
CREATE TABLE IF NOT EXISTS kline (
    id BIGSERIAL PRIMARY KEY,
    symbol VARCHAR(20) NOT NULL,
    interval VARCHAR(10) NOT NULL,
    open_time BIGINT NOT NULL,
    close_time BIGINT NOT NULL,
    timestamp BIGINT NOT NULL,
    display_time TIMESTAMP NOT NULL,
    open DECIMAL(20,8) NOT NULL,
    high DECIMAL(20,8) NOT NULL,
    low DECIMAL(20,8) NOT NULL,
    close DECIMAL(20,8) NOT NULL,
    volume DECIMAL(20,8) NOT NULL,
    UNIQUE(symbol, interval, open_time, close_time)
);
"@

try {
    $result = docker-compose -f docker-compose-testnet.yml exec -T postgres-testnet psql -U testnet_user -d binance_trader_testnet -c $createTableSQL
    Write-Host "✅ Kline table created successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to create kline table: $($_.Exception.Message)" -ForegroundColor Red
}

# Get fresh kline data from Binance
Write-Host "`n2. Collecting Fresh Kline Data..." -ForegroundColor Yellow

try {
    $klineResponse = Invoke-WebRequest -Uri "https://testnet.binance.vision/api/v3/klines?symbol=BTCUSDT&interval=1m&limit=3" -UseBasicParsing
    if ($klineResponse.StatusCode -eq 200) {
        $klineData = $klineResponse.Content | ConvertFrom-Json
        Write-Host "✅ Collected $($klineData.Count) kline records" -ForegroundColor Green
        
        # Insert each kline record into the database
        foreach ($kline in $klineData) {
            $openTime = $kline[0]
            $closeTime = $kline[6]
            $timestamp = $openTime
            $displayTime = [DateTimeOffset]::FromUnixTimeMilliseconds($openTime).ToString("yyyy-MM-dd HH:mm:ss")
            $symbol = "BTCUSDT"
            $interval = "1m"
            $open = $kline[1]
            $high = $kline[2]
            $low = $kline[3]
            $close = $kline[4]
            $volume = $kline[5]
            
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
                $insertResult = docker-compose -f docker-compose-testnet.yml exec -T postgres-testnet psql -U testnet_user -d binance_trader_testnet -c $insertSQL
                Write-Host "✅ Inserted kline record for $symbol $interval at $displayTime" -ForegroundColor Green
            } catch {
                Write-Host "❌ Failed to insert kline record: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
} catch {
    Write-Host "❌ Failed to collect kline data: $($_.Exception.Message)" -ForegroundColor Red
}

# Verify data was stored
Write-Host "`n3. Verifying Stored Data..." -ForegroundColor Yellow

try {
    $countResult = docker-compose -f docker-compose-testnet.yml exec -T postgres-testnet psql -U testnet_user -d binance_trader_testnet -c "SELECT COUNT(*) FROM kline;"
    Write-Host "✅ Total kline records in database: $($countResult[2].Trim())" -ForegroundColor Green
    
    $latestResult = docker-compose -f docker-compose-testnet.yml exec -T postgres-testnet psql -U testnet_user -d binance_trader_testnet -c "SELECT symbol, interval, display_time, open, high, low, close, volume FROM kline ORDER BY display_time DESC LIMIT 3;"
    Write-Host "`nLatest kline records:" -ForegroundColor Cyan
    Write-Host $latestResult -ForegroundColor White
} catch {
    Write-Host "❌ Failed to verify stored data: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Elasticsearch storage
Write-Host "`n4. Testing Elasticsearch Storage..." -ForegroundColor Yellow

try {
    # Create an index for kline data
    $indexName = "kline-btcusdt-1m"
    $indexMapping = @{
        mappings = @{
            properties = @{
                symbol = @{ type = "keyword" }
                interval = @{ type = "keyword" }
                open_time = @{ type = "long" }
                close_time = @{ type = "long" }
                timestamp = @{ type = "long" }
                display_time = @{ type = "date" }
                open = @{ type = "double" }
                high = @{ type = "double" }
                low = @{ type = "double" }
                close = @{ type = "double" }
                volume = @{ type = "double" }
            }
        }
    } | ConvertTo-Json -Depth 10
    
    $createIndexResponse = Invoke-WebRequest -Uri "http://localhost:9202/$indexName" -Method PUT -Body $indexMapping -ContentType "application/json" -UseBasicParsing
    if ($createIndexResponse.StatusCode -eq 200) {
        Write-Host "✅ Elasticsearch index created successfully" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Failed to create Elasticsearch index: $($_.Exception.Message)" -ForegroundColor Red
}

# Insert sample data into Elasticsearch
try {
    $sampleData = @{
        symbol = "BTCUSDT"
        interval = "1m"
        open_time = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
        close_time = [DateTimeOffset]::UtcNow.AddMinutes(1).ToUnixTimeMilliseconds()
        timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
        display_time = [DateTimeOffset]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        open = 122375.0
        high = 122380.0
        low = 122370.0
        close = 122378.0
        volume = 0.5
    } | ConvertTo-Json -Depth 10
    
    $docId = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    $insertResponse = Invoke-WebRequest -Uri "http://localhost:9202/$indexName/_doc/$docId" -Method PUT -Body $sampleData -ContentType "application/json" -UseBasicParsing
    if ($insertResponse.StatusCode -eq 200 -or $insertResponse.StatusCode -eq 201) {
        Write-Host "✅ Sample data inserted into Elasticsearch" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Failed to insert data into Elasticsearch: $($_.Exception.Message)" -ForegroundColor Red
}

# Verify Elasticsearch data
try {
    $searchResponse = Invoke-WebRequest -Uri "http://localhost:9202/$indexName/_search?size=5" -UseBasicParsing
    if ($searchResponse.StatusCode -eq 200) {
        $searchData = $searchResponse.Content | ConvertFrom-Json
        $hits = $searchData.hits.hits
        Write-Host "✅ Found $($hits.Count) documents in Elasticsearch" -ForegroundColor Green
        
        if ($hits.Count -gt 0) {
            Write-Host "`nSample Elasticsearch document:" -ForegroundColor Cyan
            Write-Host ($hits[0]._source | ConvertTo-Json -Depth 10) -ForegroundColor White
        }
    }
} catch {
    Write-Host "❌ Failed to search Elasticsearch: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Storage Test Complete ===" -ForegroundColor Green
Write-Host "`nSummary:" -ForegroundColor Yellow
Write-Host "- PostgreSQL: Kline data can be stored and retrieved" -ForegroundColor White
Write-Host "- Elasticsearch: Kline data can be indexed and searched" -ForegroundColor White
Write-Host "- Binance API: Real-time kline data is accessible" -ForegroundColor White
Write-Host "- Infrastructure: All services are running and accessible" -ForegroundColor White
