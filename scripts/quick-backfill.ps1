# Quick Historical Data Backfill Script
# Backfills last 200 klines for active trading pairs

param(
    [string]$Symbol = "BTCUSDT",
    [string]$Interval = "4h",
    [int]$Limit = 200
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Historical Data Backfill" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Symbol: $Symbol" -ForegroundColor Yellow
Write-Host "Interval: $Interval" -ForegroundColor Yellow
Write-Host "Klines to fetch: $Limit" -ForegroundColor Yellow
Write-Host ""

# Get database credentials
$env:PGPASSWORD = "testnet_password"
$dbHost = "localhost"
$dbPort = "5432"
$dbName = "binance_trader_testnet"
$dbUser = "testnet_user"

# Fetch data from Binance API
Write-Host "[1/3] Fetching klines from Binance API..." -ForegroundColor Green
$apiUrl = "https://testnet.binance.vision/api/v3/klines?symbol=$Symbol&interval=$Interval&limit=$Limit"

try {
    $response = Invoke-RestMethod -Uri $apiUrl -Method Get
    Write-Host "  ✓ Fetched $($response.Count) klines" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Error fetching from Binance API: $_" -ForegroundColor Red
    exit 1
}

# Prepare SQL insert statements
Write-Host "[2/3] Preparing data for insertion..." -ForegroundColor Green
$insertedCount = 0
$skippedCount = 0

foreach ($kline in $response) {
    $openTime = $kline[0]
    $open = $kline[1]
    $high = $kline[2]
    $low = $kline[3]
    $close = $kline[4]
    $volume = $kline[5]
    $closeTime = $kline[6]
    $quoteVolume = $kline[7]
    $trades = $kline[8]
    $takerBuyBase = $kline[9]
    $takerBuyQuote = $kline[10]
    
    # Convert timestamps to PostgreSQL format
    $displayTime = (Get-Date "1970-01-01 00:00:00").AddMilliseconds($openTime).ToString("yyyy-MM-dd HH:mm:ss")
    $displayCloseTime = (Get-Date "1970-01-01 00:00:00").AddMilliseconds($closeTime).ToString("yyyy-MM-dd HH:mm:ss")
    
    # Insert into database (ignore duplicates)
    $sql = @"
INSERT INTO kline (symbol, interval, timestamp, display_time, open, high, low, close, volume, 
                   open_time, close_time, display_close_time, quote_asset_volume, 
                   number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore)
VALUES ('$Symbol', '$Interval', $openTime, '$displayTime', $open, $high, $low, $close, $volume,
        $openTime, $closeTime, '$displayCloseTime', $quoteVolume, $trades, $takerBuyBase, $takerBuyQuote, '')
ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
"@
    
    try {
        $result = docker exec -i postgres-testnet psql -U $dbUser -d $dbName -c $sql 2>&1
        if ($result -like "*INSERT 0 1*") {
            $insertedCount++
        } else {
            $skippedCount++
        }
    } catch {
        Write-Host "  Warning: Could not insert kline for $displayTime" -ForegroundColor Yellow
    }
}

Write-Host "  ✓ Prepared $($response.Count) klines" -ForegroundColor Green

# Summary
Write-Host ""
Write-Host "[3/3] Summary:" -ForegroundColor Green
Write-Host "  • New klines inserted: $insertedCount" -ForegroundColor Green
Write-Host "  • Duplicates skipped: $skippedCount" -ForegroundColor Yellow
Write-Host ""

# Verify data
Write-Host "Verifying data in database..." -ForegroundColor Cyan
$verifyQuery = "SELECT COUNT(*) as total, MIN(TO_TIMESTAMP(open_time/1000)) as earliest, MAX(TO_TIMESTAMP(open_time/1000)) as latest FROM kline WHERE symbol='$Symbol' AND interval='$Interval';"
docker exec postgres-testnet psql -U $dbUser -d $dbName -c $verifyQuery

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Backfill Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To backfill other pairs, run:" -ForegroundColor Yellow
Write-Host "  .\scripts\quick-backfill.ps1 -Symbol ETHUSDT -Interval 1h -Limit 200" -ForegroundColor Gray

