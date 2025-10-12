Param(
  [Parameter(Mandatory=$false)][string]$Symbols = "BTCUSDT,ETHUSDT",
  [Parameter(Mandatory=$false)][string]$Intervals = "1m,5m,1h",
  [Parameter(Mandatory=$false)][int]$Days = 7,
  [Parameter(Mandatory=$false)][string]$Format = "csv",
  [Parameter(Mandatory=$false)][string]$OutputDir = "datasets/klines"
)

$ErrorActionPreference = "Stop"

Write-Host "`n=== Generating Sample Kline Dataset ===" -ForegroundColor Cyan
Write-Host "Symbols: $Symbols" -ForegroundColor Yellow
Write-Host "Intervals: $Intervals" -ForegroundColor Yellow
Write-Host "Days: $Days" -ForegroundColor Yellow

$symList = $Symbols.Split(",", [System.StringSplitOptions]::RemoveEmptyEntries)
$intList = $Intervals.Split(",", [System.StringSplitOptions]::RemoveEmptyEntries)

foreach ($s in $symList) {
  foreach ($i in $intList) {
    Write-Host "`n→ Backfilling $s @ $i for last $Days days..." -ForegroundColor Green
    python scripts/backfill/backfill_klines.py --symbol $s --interval $i --days $Days --format $Format --output-dir $OutputDir
  }
}

Write-Host "`n✓ Sample dataset generated under $OutputDir" -ForegroundColor Green


