# Historical Kline Data Backfill Script for Binance AI Traders
# Purpose: Fetch and backfill historical kline data into PostgreSQL database
# Author: Automated System Maintenance
# Date: October 11, 2025

param(
    [Parameter(Mandatory=$false)]
    [string]$Symbol = "BTCUSDT",
    
    [Parameter(Mandatory=$false)]
    [string]$Interval = "1d",
    
    [Parameter(Mandatory=$false)]
    [int]$DaysBack = 60,
    
    [Parameter(Mandatory=$false)]
    [string]$DatabaseHost = "localhost",
    
    [Parameter(Mandatory=$false)]
    [int]$DatabasePort = 5433,
    
    [Parameter(Mandatory=$false)]
    [string]$DatabaseName = "binance_trader_testnet",
    
    [Parameter(Mandatory=$false)]
    [string]$DatabaseUser = "testnet_user",
    
    [Parameter(Mandatory=$false)]
    [string]$DatabasePassword = "testnet_password",
    
    [Parameter(Mandatory=$false)]
    [string]$BinanceApiUrl = "https://testnet.binance.vision",
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$AllSymbols = $false
)

$ErrorActionPreference = "Stop"

# Configuration
$AllTradingSymbols = @(
    "BTCUSDT", "ETHUSDT", "BNBUSDT", "ADAUSDT", "DOGEUSDT",
    "XRPUSDT", "DOTUSDT", "LTCUSDT", "LINKUSDT", "UNIUSDT"
)

$AllIntervals = @("1m", "3m", "5m", "15m", "30m", "1h", "2h", "4h", "6h", "8h", "12h", "1d", "3d", "1w", "1M")

# Interval milliseconds mapping
$IntervalMs = @{
    "1m" = 60000
    "3m" = 180000
    "5m" = 300000
    "15m" = 900000
    "30m" = 1800000
    "1h" = 3600000
    "2h" = 7200000
    "4h" = 14400000
    "6h" = 21600000
    "8h" = 28800000
    "12h" = 43200000
    "1d" = 86400000
    "3d" = 259200000
    "1w" = 604800000
    "1M" = 2592000000
}

function Write-Header {
    Write-Host ""
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "   Historical Kline Backfill   " -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host ""
}

function Get-KlinesFromBinance {
    param(
        [string]$Symbol,
        [string]$Interval,
        [long]$StartTime,
        [long]$EndTime
    )
    
    $url = "$BinanceApiUrl/api/v3/klines?symbol=$Symbol&interval=$Interval&startTime=$StartTime&endTime=$EndTime&limit=1000"
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get -TimeoutSec 30
        return $response
    }
    catch {
        Write-Host "    ERROR fetching data from Binance API: $_" -ForegroundColor Red
        return $null
    }
}

function Insert-KlineToDatabase {
    param(
        [string]$Symbol,
        [string]$Interval,
        [array]$KlineData
    )
    
    if ($DryRun) {
        Write-Host "    [DRY RUN] Would insert kline: $Symbol $Interval @ $(Get-Date -UnixTimeMilliseconds $KlineData[0] -Format 'yyyy-MM-dd HH:mm:ss')"
        return $true
    }
    
    # Prepare SQL INSERT statement
    $openTime = $KlineData[0]
    $open = $KlineData[1]
    $high = $KlineData[2]
    $low = $KlineData[3]
    $close = $KlineData[4]
    $volume = $KlineData[5]
    $closeTime = $KlineData[6]
    $quoteVolume = $KlineData[7]
    $trades = $KlineData[8]
    $takerBuyBase = $KlineData[9]
    $takerBuyQuote = $KlineData[10]
    
    $timestamp = $openTime
    $displayTime = (Get-Date -UnixTimeMilliseconds $openTime -Format "yyyy-MM-dd HH:mm:ss")
    $displayCloseTime = (Get-Date -UnixTimeMilliseconds $closeTime -Format "yyyy-MM-dd HH:mm:ss")
    
    $sql = @"
INSERT INTO kline (
    symbol, interval, timestamp, display_time, 
    open, high, low, close, volume,
    open_time, close_time, display_close_time,
    quote_asset_volume, number_of_trades,
    taker_buy_base_asset_volume, taker_buy_quote_asset_volume
) VALUES (
    '$Symbol', '$Interval', $timestamp, '$displayTime',
    $open, $high, $low, $close, $volume,
    $openTime, $closeTime, '$displayCloseTime',
    $quoteVolume, $trades,
    $takerBuyBase, $takerBuyQuote
)
ON CONFLICT (symbol, interval, open_time) DO NOTHING;
"@
    
    try {
        $env:PGPASSWORD = $DatabasePassword
        $result = $sql | docker exec -i postgres-testnet psql -U $DatabaseUser -d $DatabaseName -c "$sql" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            return $true
        }
        else {
            Write-Host "    WARNING: Database insert failed: $result" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "    ERROR inserting to database: $_" -ForegroundColor Red
        return $false
    }
}

function Backfill-Symbol-Interval {
    param(
        [string]$Symbol,
        [string]$Interval,
        [int]$DaysBack
    )
    
    Write-Host ""
    Write-Host "Processing: $Symbol $Interval" -ForegroundColor Green
    Write-Host "  Days back: $DaysBack" -ForegroundColor Gray
    
    # Calculate time range
    $endTime = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    $startTime = $endTime - ($DaysBack * 86400000)
    
    $intervalMsValue = $IntervalMs[$Interval]
    if (-not $intervalMsValue) {
        Write-Host "  ERROR: Unknown interval $Interval" -ForegroundColor Red
        return
    }
    
    Write-Host "  Time range: $(Get-Date -UnixTimeMilliseconds $startTime -Format 'yyyy-MM-dd HH:mm') to $(Get-Date -UnixTimeMilliseconds $endTime -Format 'yyyy-MM-dd HH:mm')" -ForegroundColor Gray
    
    $currentStart = $startTime
    $totalInserted = 0
    $totalSkipped = 0
    $batchCount = 0
    
    while ($currentStart -lt $endTime) {
        $batchCount++
        $currentEnd = [Math]::Min($currentStart + (1000 * $intervalMsValue), $endTime)
        
        Write-Host "  Batch $batchCount : Fetching klines..." -NoNewline
        
        $klines = Get-KlinesFromBinance -Symbol $Symbol -Interval $Interval -StartTime $currentStart -EndTime $currentEnd
        
        if ($null -eq $klines -or $klines.Count -eq 0) {
            Write-Host " No data" -ForegroundColor Yellow
            break
        }
        
        Write-Host " Got $($klines.Count) klines" -ForegroundColor Cyan
        
        foreach ($kline in $klines) {
            $success = Insert-KlineToDatabase -Symbol $Symbol -Interval $Interval -KlineData $kline
            if ($success) {
                $totalInserted++
            }
            else {
                $totalSkipped++
            }
        }
        
        # Move to next batch
        $lastKlineTime = [long]$klines[-1][0]
        $currentStart = $lastKlineTime + $intervalMsValue
        
        # Rate limiting
        Start-Sleep -Milliseconds 100
    }
    
    Write-Host "  ✓ Complete: Inserted $totalInserted, Skipped $totalSkipped (already exist)" -ForegroundColor Green
}

# Main execution
Write-Header

if ($DryRun) {
    Write-Host "DRY RUN MODE - No data will be inserted" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "Configuration:" -ForegroundColor Cyan
Write-Host "  Database: ${DatabaseHost}:${DatabasePort}/${DatabaseName}" -ForegroundColor Gray
Write-Host "  API URL: $BinanceApiUrl" -ForegroundColor Gray
Write-Host ""

if ($AllSymbols) {
    Write-Host "Backfilling ALL symbols and intervals..." -ForegroundColor Yellow
    Write-Host "This will take a LONG time!" -ForegroundColor Yellow
    Write-Host ""
    
    foreach ($sym in $AllTradingSymbols) {
        foreach ($int in $AllIntervals) {
            Backfill-Symbol-Interval -Symbol $sym -Interval $int -DaysBack $DaysBack
        }
    }
}
else {
    Backfill-Symbol-Interval -Symbol $Symbol -Interval $Interval -DaysBack $DaysBack
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "   Backfill Complete!           " -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Verify data
Write-Host "Verifying inserted data..." -ForegroundColor Cyan
$verifySymbol = if ($AllSymbols) { $AllTradingSymbols[0] } else { $Symbol }
$verifyInterval = if ($AllSymbols) { "1d" } else { $Interval }

$countQuery = "SELECT symbol, interval, COUNT(*) as count FROM kline WHERE symbol='$verifySymbol' AND interval='$verifyInterval' GROUP BY symbol, interval;"
Invoke-Expression "docker exec postgres-testnet psql -U $DatabaseUser -d $DatabaseName -c `"$countQuery`""

Write-Host ""
Write-Host "Done!" -ForegroundColor Green

