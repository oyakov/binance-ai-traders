$ErrorActionPreference = 'Stop'

$base = 'https://testnet.binance.vision'
$symbols = @('BTCUSDT','ETHUSDT','BNBUSDT','ADAUSDT','DOGEUSDT','XRPUSDT','DOTUSDT','LTCUSDT','LINKUSDT','UNIUSDT')
$intervals = @('12h','1d','3d','1w')

function New-InsertStatement {
    param(
        [string]$symbol,
        [string]$interval,
        [long]$openTime,
        [double]$open,
        [double]$high,
        [double]$low,
        [double]$close,
        [double]$volume,
        [long]$closeTime,
        [double]$quoteAssetVolume,
        [int]$numTrades,
        [double]$takerBuyBase,
        [double]$takerBuyQuote,
        [string]$ignore
    )
    $sym = $symbol.ToUpper()
    $intv = $interval
    $ts = $closeTime
    $dispOpen = "to_timestamp($($openTime)/1000)"
    $dispClose = "to_timestamp($($closeTime)/1000)"
    $ignoreVal = if ($ignore) { "'$ignore'" } else { 'NULL' }
    $quoteVolVal = if ($quoteAssetVolume -ne $null) { $quoteAssetVolume.ToString([System.Globalization.CultureInfo]::InvariantCulture) } else { 'NULL' }
    $tbb = if ($takerBuyBase -ne $null) { $takerBuyBase.ToString([System.Globalization.CultureInfo]::InvariantCulture) } else { 'NULL' }
    $tbq = if ($takerBuyQuote -ne $null) { $takerBuyQuote.ToString([System.Globalization.CultureInfo]::InvariantCulture) } else { 'NULL' }
    $openStr = $open.ToString([System.Globalization.CultureInfo]::InvariantCulture)
    $highStr = $high.ToString([System.Globalization.CultureInfo]::InvariantCulture)
    $lowStr = $low.ToString([System.Globalization.CultureInfo]::InvariantCulture)
    $closeStr = $close.ToString([System.Globalization.CultureInfo]::InvariantCulture)
    $volStr = $volume.ToString([System.Globalization.CultureInfo]::InvariantCulture)
    $sql = @"
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  '$sym', '$intv', $ts, $dispOpen, $openStr, $highStr, $lowStr, $closeStr, $volStr,
  $openTime, $closeTime, $dispClose,
  $quoteVolVal, $numTrades, $tbb, $tbq, $ignoreVal
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
"@
    return $sql
}

$batch = New-Object System.Collections.Generic.List[string]

foreach ($sym in $symbols) {
  foreach ($intv in $intervals) {
    Write-Host "Fetching $sym $intv ..."
    $url = "$base/api/v3/klines?symbol=$sym&interval=$intv&limit=1000"
    try {
      $rows = Invoke-RestMethod -Method Get -Uri $url
    } catch {
      Write-Warning ("Failed fetch {0} {1}: {2}" -f $sym, $intv, $_.Exception.Message)
      continue
    }
    if (-not $rows) { continue }
    foreach ($r in $rows) {
      $sql = New-InsertStatement -symbol $sym -interval $intv -openTime ([int64]$r[0]) -open ([double]$r[1]) -high ([double]$r[2]) -low ([double]$r[3]) -close ([double]$r[4]) -volume ([double]$r[5]) -closeTime ([int64]$r[6]) -quoteAssetVolume ([double]$r[7]) -numTrades ([int]$r[8]) -takerBuyBase ([double]$r[9]) -takerBuyQuote ([double]$r[10]) -ignore ([string]$r[11])
      $batch.Add($sql) | Out-Null
      if ($batch.Count -ge 2000) {
        $joined = $batch -join "`n"
        if (-not (Test-Path -LiteralPath 'scripts/sql/_rest_backfill.sql')) { New-Item -ItemType File -Path 'scripts/sql/_rest_backfill.sql' -Force | Out-Null }
        Add-Content -LiteralPath 'scripts/sql/_rest_backfill.sql' -Value $joined
        $batch.Clear()
      }
    }
    if ($batch.Count -gt 0) {
      $joined = $batch -join "`n"
      if (-not (Test-Path -LiteralPath 'scripts/sql/_rest_backfill.sql')) { New-Item -ItemType File -Path 'scripts/sql/_rest_backfill.sql' -Force | Out-Null }
      Add-Content -LiteralPath 'scripts/sql/_rest_backfill.sql' -Value $joined
      $batch.Clear()
    }
  }
}

if (Test-Path -LiteralPath 'scripts/sql/_rest_backfill.sql') {
  Write-Host "Executing SQL batch..."
  docker cp scripts/sql/_rest_backfill.sql postgres-testnet:/tmp/_rest_backfill.sql | Out-Null
  docker exec -e PGPASSWORD=testnet_password -i postgres-testnet psql -U testnet_user -d binance_trader_testnet -v ON_ERROR_STOP=1 -f /tmp/_rest_backfill.sql | Out-Null
  Write-Host "Backfill REST complete."
} else {
  Write-Host "No REST data collected."
}


