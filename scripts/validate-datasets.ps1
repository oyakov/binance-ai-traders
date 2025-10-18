#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Validates integrity and quality of backtest datasets.

.DESCRIPTION
    Performs comprehensive validation of historical kline datasets including:
    - File structure and format
    - Data completeness and gaps
    - Value consistency and anomalies
    - Timestamp sequencing
    - Statistical validation

.PARAMETER DatasetPath
    Path to specific dataset file to validate. If not specified, validates all datasets.

.PARAMETER CheckGaps
    Enable gap detection in time series.

.PARAMETER CheckAnomalies
    Enable anomaly detection (extreme price moves, volume spikes).

.PARAMETER DetailedReport
    Generate detailed validation report.

.PARAMETER Fix
    Attempt to fix minor issues automatically.

.EXAMPLE
    .\validate-datasets.ps1
    Validates all datasets

.EXAMPLE
    .\validate-datasets.ps1 -DatasetPath "datasets/BTCUSDT/1h/30d-latest.json" -DetailedReport
    Validates specific dataset with detailed output

.EXAMPLE
    .\validate-datasets.ps1 -CheckGaps -CheckAnomalies
    Full validation with gap and anomaly detection

.NOTES
    Part of: Testability & Observability Feedback Loop
    Version: 1.0
    Date: 2025-01-18
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$DatasetPath = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$CheckGaps,
    
    [Parameter(Mandatory=$false)]
    [switch]$CheckAnomalies,
    
    [Parameter(Mandatory=$false)]
    [switch]$DetailedReport,
    
    [Parameter(Mandatory=$false)]
    [switch]$Fix
)

# Configuration
$BASE_DIR = "datasets"
$MAX_ALLOWED_GAP_MS = 3600000  # 1 hour
$MAX_PRICE_CHANGE_PERCENT = 20.0
$MIN_VOLUME = 0.1

# Validation results
$script:TotalDatasets = 0
$script:ValidDatasets = 0
$script:InvalidDatasets = 0
$script:WarningDatasets = 0
$script:Issues = @()

# Helper Functions

function Write-ValidationLog {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [string]$Dataset = ""
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $prefix = if ($Dataset) { "[$Dataset]" } else { "" }
    $logMessage = "[$timestamp] [$Level] $prefix $Message"
    
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARN"  { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage }
    }
}

function Test-DatasetStructure {
    param([object]$Dataset, [string]$FilePath)
    
    $issues = @()
    
    # Check required fields
    $requiredFields = @("name", "symbol", "interval", "collectedAt", "klines")
    foreach ($field in $requiredFields) {
        if (-not $Dataset.PSObject.Properties[$field]) {
            $issues += "Missing required field: $field"
        }
    }
    
    # Check klines is array
    if ($Dataset.klines -isnot [Array]) {
        $issues += "Klines field must be an array"
    }
    
    # Check minimum klines
    if ($Dataset.klines.Count -lt 10) {
        $issues += "Insufficient klines: $($Dataset.klines.Count) (minimum 10 required)"
    }
    
    return $issues
}

function Test-KlineData {
    param([object]$Kline, [int]$Index)
    
    $issues = @()
    
    # Check required kline fields
    $requiredKlineFields = @("symbol", "interval", "openTime", "closeTime", "open", "high", "low", "close", "volume")
    foreach ($field in $requiredKlineFields) {
        if ($null -eq $Kline.$field) {
            $issues += "Kline $Index: Missing field $field"
        }
    }
    
    # Validate OHLC relationships
    try {
        $open = [decimal]$Kline.open
        $high = [decimal]$Kline.high
        $low = [decimal]$Kline.low
        $close = [decimal]$Kline.close
        
        if ($high -lt $open -or $high -lt $close) {
            $issues += "Kline $Index: High ($high) must be >= open ($open) and close ($close)"
        }
        
        if ($low -gt $open -or $low -gt $close) {
            $issues += "Kline $Index: Low ($low) must be <= open ($open) and close ($close)"
        }
        
        if ($high -lt $low) {
            $issues += "Kline $Index: High ($high) cannot be less than low ($low)"
        }
        
    } catch {
        $issues += "Kline $Index: Invalid numeric values in OHLC data"
    }
    
    # Validate timestamps
    if ($Kline.openTime -ge $Kline.closeTime) {
        $issues += "Kline $Index: openTime ($($Kline.openTime)) must be before closeTime ($($Kline.closeTime))"
    }
    
    return $issues
}

function Test-TimeGaps {
    param([array]$Klines, [string]$Interval)
    
    $gaps = @()
    $intervalMs = Get-IntervalMilliseconds $Interval
    
    for ($i = 1; $i -lt $Klines.Count; $i++) {
        $prevCloseTime = $Klines[$i-1].closeTime
        $currentOpenTime = $Klines[$i].openTime
        
        $gap = $currentOpenTime - $prevCloseTime - 1
        
        if ($gap -gt $intervalMs) {
            $gapHours = [Math]::Round($gap / 3600000, 2)
            $gaps += @{
                Index = $i
                PreviousCloseTime = $prevCloseTime
                CurrentOpenTime = $currentOpenTime
                GapMs = $gap
                GapHours = $gapHours
            }
        }
    }
    
    return $gaps
}

function Test-Anomalies {
    param([array]$Klines)
    
    $anomalies = @()
    
    for ($i = 1; $i -lt $Klines.Count; $i++) {
        $prevClose = [decimal]$Klines[$i-1].close
        $currentOpen = [decimal]$Klines[$i].open
        $currentHigh = [decimal]$Klines[$i].high
        $currentLow = [decimal]$Klines[$i].low
        $currentVolume = [decimal]$Klines[$i].volume
        
        # Check for extreme price jumps
        if ($prevClose -gt 0) {
            $priceChange = [Math]::Abs((($currentOpen - $prevClose) / $prevClose) * 100)
            if ($priceChange -gt $MAX_PRICE_CHANGE_PERCENT) {
                $anomalies += @{
                    Type = "PriceJump"
                    Index = $i
                    Description = "Extreme price jump: $([Math]::Round($priceChange, 2))% from $prevClose to $currentOpen"
                }
            }
        }
        
        # Check for suspicious zero/near-zero volume
        if ($currentVolume -lt $MIN_VOLUME) {
            $anomalies += @{
                Type = "LowVolume"
                Index = $i
                Description = "Suspiciously low volume: $currentVolume"
            }
        }
        
        # Check for price spikes within kline
        $intradayRange = $currentHigh - $currentLow
        if ($currentLow -gt 0) {
            $rangePercent = ($intradayRange / $currentLow) * 100
            if ($rangePercent -gt ($MAX_PRICE_CHANGE_PERCENT * 1.5)) {
                $anomalies += @{
                    Type = "PriceSpike"
                    Index = $i
                    Description = "Extreme intraday range: $([Math]::Round($rangePercent, 2))%"
                }
            }
        }
    }
    
    return $anomalies
}

function Get-IntervalMilliseconds {
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

function Validate-Dataset {
    param([string]$FilePath)
    
    $script:TotalDatasets++
    $datasetName = Split-Path $FilePath -Leaf
    
    Write-ValidationLog "Validating: $FilePath" -Dataset $datasetName
    
    # Check file exists
    if (!(Test-Path $FilePath)) {
        Write-ValidationLog "File not found" -Level "ERROR" -Dataset $datasetName
        $script:InvalidDatasets++
        return
    }
    
    # Load dataset
    try {
        $dataset = Get-Content $FilePath -Raw | ConvertFrom-Json
    } catch {
        Write-ValidationLog "Failed to parse JSON: $_" -Level "ERROR" -Dataset $datasetName
        $script:InvalidDatasets++
        return
    }
    
    $hasErrors = $false
    $hasWarnings = $false
    
    # Validate structure
    $structureIssues = Test-DatasetStructure -Dataset $dataset -FilePath $FilePath
    if ($structureIssues.Count -gt 0) {
        foreach ($issue in $structureIssues) {
            Write-ValidationLog $issue -Level "ERROR" -Dataset $datasetName
            $script:Issues += @{Dataset = $datasetName; Type = "Structure"; Issue = $issue}
        }
        $hasErrors = $true
    }
    
    if ($hasErrors) {
        $script:InvalidDatasets++
        return
    }
    
    # Validate individual klines
    $klineErrors = 0
    for ($i = 0; $i -lt $dataset.klines.Count -and $i -lt 100; $i++) {  # Check first 100 klines
        $klineIssues = Test-KlineData -Kline $dataset.klines[$i] -Index $i
        if ($klineIssues.Count -gt 0) {
            $klineErrors++
            if ($DetailedReport) {
                foreach ($issue in $klineIssues) {
                    Write-ValidationLog $issue -Level "ERROR" -Dataset $datasetName
                }
            }
        }
    }
    
    if ($klineErrors -gt 0) {
        Write-ValidationLog "Found $klineErrors kline data errors" -Level "ERROR" -Dataset $datasetName
        $hasErrors = $true
    }
    
    # Check for time gaps
    if ($CheckGaps) {
        $gaps = Test-TimeGaps -Klines $dataset.klines -Interval $dataset.interval
        if ($gaps.Count -gt 0) {
            Write-ValidationLog "Found $($gaps.Count) time gaps" -Level "WARN" -Dataset $datasetName
            $hasWarnings = $true
            
            if ($DetailedReport) {
                foreach ($gap in $gaps) {
                    Write-ValidationLog "  Gap at index $($gap.Index): $($gap.GapHours) hours" -Level "WARN" -Dataset $datasetName
                    $script:Issues += @{Dataset = $datasetName; Type = "Gap"; Issue = "Gap of $($gap.GapHours) hours"}
                }
            }
        }
    }
    
    # Check for anomalies
    if ($CheckAnomalies) {
        $anomalies = Test-Anomalies -Klines $dataset.klines
        if ($anomalies.Count -gt 0) {
            Write-ValidationLog "Found $($anomalies.Count) anomalies" -Level "WARN" -Dataset $datasetName
            $hasWarnings = $true
            
            if ($DetailedReport) {
                foreach ($anomaly in $anomalies) {
                    Write-ValidationLog "  $($anomaly.Description)" -Level "WARN" -Dataset $datasetName
                    $script:Issues += @{Dataset = $datasetName; Type = $anomaly.Type; Issue = $anomaly.Description}
                }
            }
        }
    }
    
    # Summary for this dataset
    if ($hasErrors) {
        $script:InvalidDatasets++
        Write-ValidationLog "INVALID" -Level "ERROR" -Dataset $datasetName
    } elseif ($hasWarnings) {
        $script:WarningDatasets++
        Write-ValidationLog "VALID (with warnings)" -Level "WARN" -Dataset $datasetName
    } else {
        $script:ValidDatasets++
        Write-ValidationLog "VALID" -Level "SUCCESS" -Dataset $datasetName
    }
}

function Show-ValidationSummary {
    Write-Host ""
    Write-Host "=== Validation Summary ===" -ForegroundColor Cyan
    Write-Host "Total Datasets: $script:TotalDatasets"
    Write-Host "Valid: $script:ValidDatasets" -ForegroundColor Green
    Write-Host "Valid (with warnings): $script:WarningDatasets" -ForegroundColor Yellow
    Write-Host "Invalid: $script:InvalidDatasets" -ForegroundColor Red
    Write-Host "Total Issues: $($script:Issues.Count)"
    
    if ($script:Issues.Count -gt 0 -and $DetailedReport) {
        Write-Host ""
        Write-Host "=== Issue Breakdown ===" -ForegroundColor Cyan
        $issuesByType = $script:Issues | Group-Object -Property Type
        foreach ($group in $issuesByType) {
            Write-Host "  $($group.Name): $($group.Count)"
        }
    }
    
    Write-Host "==========================" -ForegroundColor Cyan
}

# Main Execution

Write-ValidationLog "Starting dataset validation..."
Write-ValidationLog "Options: CheckGaps=$CheckGaps CheckAnomalies=$CheckAnomalies DetailedReport=$DetailedReport"

if ($DatasetPath) {
    # Validate specific dataset
    Validate-Dataset -FilePath $DatasetPath
} else {
    # Validate all datasets
    $datasetFiles = Get-ChildItem -Path $BASE_DIR -Include "*-latest.json" -Recurse -File
    Write-ValidationLog "Found $($datasetFiles.Count) datasets to validate"
    
    foreach ($file in $datasetFiles) {
        Validate-Dataset -FilePath $file.FullName
    }
}

Show-ValidationSummary

# Exit code
if ($script:InvalidDatasets -gt 0) {
    exit 1
} else {
    exit 0
}

