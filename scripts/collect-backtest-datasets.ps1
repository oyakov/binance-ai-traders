#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Collects historical kline data from Binance for backtesting research.

.DESCRIPTION
    This script automates the collection of historical candlestick (kline) data
    from Binance API into the datasets/ directory. It supports multiple symbols,
    intervals, and time ranges for comprehensive strategy backtesting.

.PARAMETER Symbol
    Specific trading pair to collect (e.g., BTCUSDT). If not specified, collects all configured pairs.

.PARAMETER Interval
    Specific interval to collect (e.g., 1h). If not specified, collects all configured intervals.

.PARAMETER TimeRange
    Specific time range to collect (e.g., 30d). If not specified, collects all configured ranges.

.PARAMETER DryRun
    Preview what would be collected without actually fetching data.

.PARAMETER Force
    Force re-collection even if dataset already exists.

.PARAMETER Verbose
    Show detailed logging output.

.EXAMPLE
    .\collect-backtest-datasets.ps1
    Collects all datasets (100 total)

.EXAMPLE
    .\collect-backtest-datasets.ps1 -Symbol BTCUSDT -Interval 1h
    Collects only BTCUSDT 1h datasets for all time ranges

.EXAMPLE
    .\collect-backtest-datasets.ps1 -TimeRange 30d -Force
    Re-collects all 30-day datasets

.NOTES
    Part of: Testability & Observability Feedback Loop
    Version: 1.0
    Date: 2025-01-18
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Symbol = "",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("5m", "15m", "1h", "4h", "1d", "")]
    [string]$Interval = "",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("7d", "30d", "90d", "180d", "")]
    [string]$TimeRange = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force,
    
    [Parameter(Mandatory=$false)]
    [switch]$VerboseOutput
)

# Configuration
$CONFIG_FILE = "datasets/collection-config.yaml"
$BASE_DIR = "datasets"
$METADATA_DIR = "datasets/metadata"
$BINANCE_API_URL = "https://api.binance.com"
$RATE_LIMIT_DELAY_MS = 100

# Default configuration (if YAML not available)
$DEFAULT_SYMBOLS = @("BTCUSDT", "ETHUSDT", "BNBUSDT", "ADAUSDT", "SOLUSDT")
$DEFAULT_INTERVALS = @("5m", "15m", "1h", "4h", "1d")
$DEFAULT_TIME_RANGES = @(
    @{Name="7d"; Days=7},
    @{Name="30d"; Days=30},
    @{Name="90d"; Days=90},
    @{Name="180d"; Days=180}
)

# Statistics
$script:TotalDatasets = 0
$script:CollectedDatasets = 0
$script:SkippedDatasets = 0
$script:FailedDatasets = 0
$script:StartTime = Get-Date

# Helper Functions

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARN"  { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage }
    }
    
    # Also write to log file
    $logFile = "logs/dataset-collection.log"
    if (!(Test-Path "logs")) {
        New-Item -ItemType Directory -Path "logs" -Force | Out-Null
    }
    Add-Content -Path $logFile -Value $logMessage
}

function Get-KlineIntervalMs {
    param([string]$Interval)
    
    $intervalMap = @{
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
    }
    
    return $intervalMap[$Interval]
}

function Get-BinanceKlines {
    param(
        [string]$Symbol,
        [string]$Interval,
        [long]$StartTime,
        [long]$EndTime
    )
    
    $allKlines = @()
    $currentStartTime = $StartTime
    
    while ($currentStartTime -lt $EndTime) {
        $url = "$BINANCE_API_URL/api/v3/klines"
        $params = @{
            symbol = $Symbol
            interval = $Interval
            startTime = $currentStartTime
            endTime = $EndTime
            limit = 1000
        }
        
        try {
            if ($VerboseOutput) {
                Write-Log "Fetching klines: $Symbol $Interval from $currentStartTime" -Level "DEBUG"
            }
            
            $response = Invoke-RestMethod -Uri $url -Method Get -Body $params -TimeoutSec 30
            
            if ($response.Count -eq 0) {
                break
            }
            
            $allKlines += $response
            
            # Update start time for next batch
            $lastKline = $response[-1]
            $currentStartTime = $lastKline[6] + 1  # closeTime + 1
            
            # Rate limiting
            Start-Sleep -Milliseconds $RATE_LIMIT_DELAY_MS
            
        } catch {
            Write-Log "Error fetching klines: $_" -Level "ERROR"
            return $null
        }
    }
    
    return $allKlines
}

function Convert-KlinesToBacktestDataset {
    param(
        [string]$Symbol,
        [string]$Interval,
        [string]$DatasetName,
        [array]$RawKlines
    )
    
    $klineEvents = @()
    
    foreach ($kline in $RawKlines) {
        $klineEvent = @{
            symbol = $Symbol
            interval = $Interval
            openTime = $kline[0]
            closeTime = $kline[6]
            open = $kline[1]
            high = $kline[2]
            low = $kline[3]
            close = $kline[4]
            volume = $kline[5]
            quoteAssetVolume = $kline[7]
            numberOfTrades = $kline[8]
            takerBuyBaseAssetVolume = $kline[9]
            takerBuyQuoteAssetVolume = $kline[10]
        }
        $klineEvents += $klineEvent
    }
    
    $dataset = @{
        name = $DatasetName
        symbol = $Symbol
        interval = $Interval
        collectedAt = (Get-Date -Format "o")
        klines = $klineEvents
    }
    
    return $dataset
}

function Save-Dataset {
    param(
        [string]$FilePath,
        [object]$Dataset
    )
    
    $directory = Split-Path -Parent $FilePath
    if (!(Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    
    try {
        $json = $Dataset | ConvertTo-Json -Depth 10 -Compress:$false
        Set-Content -Path $FilePath -Value $json -Encoding UTF8
        return $true
    } catch {
        Write-Log "Error saving dataset: $_" -Level "ERROR"
        return $false
    }
}

function Collect-Dataset {
    param(
        [string]$Symbol,
        [string]$Interval,
        [hashtable]$TimeRangeConfig
    )
    
    $timeRangeName = $TimeRangeConfig.Name
    $days = $TimeRangeConfig.Days
    
    $script:TotalDatasets++
    
    # Calculate time range
    $endTime = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    $startTime = $endTime - ($days * 24 * 60 * 60 * 1000)
    
    # Dataset file path
    $filePath = "$BASE_DIR/$Symbol/$Interval/$timeRangeName-latest.json"
    
    # Check if already exists and not forcing
    if ((Test-Path $filePath) -and !$Force) {
        Write-Log "Dataset already exists: $filePath (use -Force to overwrite)" -Level "WARN"
        $script:SkippedDatasets++
        return
    }
    
    if ($DryRun) {
        Write-Log "[DRY RUN] Would collect: $Symbol $Interval $timeRangeName -> $filePath"
        return
    }
    
    Write-Log "Collecting: $Symbol $Interval $timeRangeName ($days days)"
    
    # Fetch klines from Binance
    $rawKlines = Get-BinanceKlines -Symbol $Symbol -Interval $Interval -StartTime $startTime -EndTime $endTime
    
    if ($null -eq $rawKlines -or $rawKlines.Count -eq 0) {
        Write-Log "Failed to fetch klines for $Symbol $Interval $timeRangeName" -Level "ERROR"
        $script:FailedDatasets++
        return
    }
    
    # Convert to BacktestDataset format
    $datasetName = "$Symbol-$Interval-$timeRangeName-$(Get-Date -Format 'yyyy-MM-dd')"
    $dataset = Convert-KlinesToBacktestDataset -Symbol $Symbol -Interval $Interval -DatasetName $datasetName -RawKlines $rawKlines
    
    # Save dataset
    if (Save-Dataset -FilePath $filePath -Dataset $dataset) {
        Write-Log "Successfully saved: $filePath ($($rawKlines.Count) klines)" -Level "SUCCESS"
        $script:CollectedDatasets++
        
        # Update metadata
        Update-CollectionMetadata -FilePath $filePath -Dataset $dataset
    } else {
        $script:FailedDatasets++
    }
}

function Update-CollectionMetadata {
    param(
        [string]$FilePath,
        [object]$Dataset
    )
    
    $metadataFile = "$METADATA_DIR/collection-history.json"
    
    # Ensure metadata directory exists
    if (!(Test-Path $METADATA_DIR)) {
        New-Item -ItemType Directory -Path $METADATA_DIR -Force | Out-Null
    }
    
    # Load existing metadata or create new
    $metadata = @{
        datasets = @()
        lastUpdate = (Get-Date -Format "o")
        totalDatasets = 0
        totalSize = 0
    }
    
    if (Test-Path $metadataFile) {
        try {
            $existing = Get-Content $metadataFile -Raw | ConvertFrom-Json
            $metadata.datasets = @($existing.datasets)
        } catch {
            Write-Log "Error loading metadata, will create new" -Level "WARN"
        }
    }
    
    # Add/update this dataset entry
    $fileInfo = Get-Item $FilePath
    $datasetEntry = @{
        path = $FilePath.Replace("$BASE_DIR/", "")
        collectedAt = $Dataset.collectedAt
        klineCount = $Dataset.klines.Count
        startTime = $Dataset.klines[0].openTime
        endTime = $Dataset.klines[-1].closeTime
        fileSize = $fileInfo.Length
    }
    
    # Remove old entry if exists
    $metadata.datasets = @($metadata.datasets | Where-Object { $_.path -ne $datasetEntry.path })
    $metadata.datasets += $datasetEntry
    
    # Update totals
    $metadata.totalDatasets = $metadata.datasets.Count
    $metadata.totalSize = ($metadata.datasets | Measure-Object -Property fileSize -Sum).Sum
    $metadata.lastUpdate = (Get-Date -Format "o")
    
    # Save metadata
    try {
        $metadata | ConvertTo-Json -Depth 10 | Set-Content -Path $metadataFile -Encoding UTF8
    } catch {
        Write-Log "Error updating metadata: $_" -Level "WARN"
    }
}

function Show-Summary {
    $duration = (Get-Date) - $script:StartTime
    
    Write-Host ""
    Write-Host "=== Dataset Collection Summary ===" -ForegroundColor Cyan
    Write-Host "Total Datasets: $script:TotalDatasets"
    Write-Host "Collected: $script:CollectedDatasets" -ForegroundColor Green
    Write-Host "Skipped: $script:SkippedDatasets" -ForegroundColor Yellow
    Write-Host "Failed: $script:FailedDatasets" -ForegroundColor Red
    Write-Host "Duration: $($duration.ToString('hh\:mm\:ss'))"
    Write-Host "===================================" -ForegroundColor Cyan
}

# Main Execution

Write-Log "Starting dataset collection..." -Level "INFO"
Write-Log "Configuration: Symbol='$Symbol' Interval='$Interval' TimeRange='$TimeRange' DryRun=$DryRun Force=$Force"

# Determine what to collect
$symbolsToCollect = if ($Symbol) { @($Symbol) } else { $DEFAULT_SYMBOLS }
$intervalsToCollect = if ($Interval) { @($Interval) } else { $DEFAULT_INTERVALS }
$timeRangesToCollect = if ($TimeRange) { 
    $DEFAULT_TIME_RANGES | Where-Object { $_.Name -eq $TimeRange }
} else { 
    $DEFAULT_TIME_RANGES
}

Write-Log "Will process: $($symbolsToCollect.Count) symbols × $($intervalsToCollect.Count) intervals × $($timeRangesToCollect.Count) time ranges = $($symbolsToCollect.Count * $intervalsToCollect.Count * $timeRangesToCollect.Count) datasets"

# Collect datasets
foreach ($sym in $symbolsToCollect) {
    foreach ($int in $intervalsToCollect) {
        foreach ($tr in $timeRangesToCollect) {
            Collect-Dataset -Symbol $sym -Interval $int -TimeRangeConfig $tr
        }
    }
}

# Show summary
Show-Summary

# Exit code
if ($script:FailedDatasets -gt 0) {
    Write-Log "Collection completed with errors" -Level "WARN"
    exit 1
} else {
    Write-Log "Collection completed successfully" -Level "SUCCESS"
    exit 0
}

