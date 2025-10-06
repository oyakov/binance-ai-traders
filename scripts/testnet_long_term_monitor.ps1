# Testnet Long-Term Monitoring Script
# This script monitors the testnet system continuously and generates reports

param(
    [int]$CheckIntervalMinutes = 5,
    [string]$LogDirectory = ".\testnet_logs",
    [string]$ReportDirectory = ".\testnet_reports"
)

# Create directories if they don't exist
if (!(Test-Path $LogDirectory)) { New-Item -ItemType Directory -Path $LogDirectory -Force }
if (!(Test-Path $ReportDirectory)) { New-Item -ItemType Directory -Path $ReportDirectory -Force }

# Logging function
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    Write-Host $LogMessage
    Add-Content -Path "$LogDirectory\testnet_monitor.log" -Value $LogMessage
}

# Health check function
function Test-ServiceHealth {
    param([string]$ServiceName)
    
    try {
        $Status = docker inspect "$ServiceName" --format "{{.State.Health.Status}}" 2>$null
        return $Status -eq "healthy"
    }
    catch {
        return $false
    }
}

# API connectivity test
function Test-BinanceAPI {
    try {
        $Response = Invoke-WebRequest -Uri "https://testnet.binance.vision/api/v3/ping" -UseBasicParsing -TimeoutSec 10
        return $Response.StatusCode -eq 200
    }
    catch {
        return $false
    }
}

# Trading activity check
function Get-TradingActivity {
    try {
        $Response = Invoke-WebRequest -Uri "http://localhost:9091/api/v1/query?query=binance_trader_signals_total" -UseBasicParsing
        $Data = $Response.Content | ConvertFrom-Json
        if ($Data.status -eq "success" -and $Data.data.result.Count -gt 0) {
            return [int]$Data.data.result[0].value[1]
        }
        return 0
    }
    catch {
        return 0
    }
}

# System metrics collection
function Get-SystemMetrics {
    $Metrics = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Services = @{}
        TradingActivity = 0
        BinanceAPI = $false
        MemoryUsage = 0
        CPUUsage = 0
    }
    
    # Check service health
    $Services = @("postgres-testnet", "elasticsearch-testnet", "kafka-testnet", "binance-trader-macd-testnet", "prometheus-testnet", "grafana-testnet")
    foreach ($Service in $Services) {
        $Metrics.Services[$Service] = Test-ServiceHealth $Service
    }
    
    # Check Binance API
    $Metrics.BinanceAPI = Test-BinanceAPI
    
    # Get trading activity
    $Metrics.TradingActivity = Get-TradingActivity
    
    # Get system resource usage
    try {
        $DockerStats = docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" | Select-String "binance-trader-macd-testnet"
        if ($DockerStats) {
            $Stats = $DockerStats.Line -split "\s+"
            $Metrics.CPUUsage = $Stats[1] -replace "%", ""
            $Metrics.MemoryUsage = $Stats[2]
        }
    }
    catch {
        # Ignore errors
    }
    
    return $Metrics
}

# Generate daily report
function New-DailyReport {
    param([array]$MetricsHistory)
    
    $Date = Get-Date -Format "yyyy-MM-dd"
    $ReportFile = "$ReportDirectory\testnet_report_$Date.json"
    
    $Report = @{
        Date = $Date
        Summary = @{
            TotalChecks = $MetricsHistory.Count
            ServicesHealthy = 0
            TradingActivity = 0
            APIUptime = 0
            AverageCPU = 0
            AverageMemory = 0
        }
        Details = $MetricsHistory
    }
    
    # Calculate summary statistics
    $HealthyChecks = $MetricsHistory | Where-Object { $_.Services.Values -contains $true }
    $Report.Summary.ServicesHealthy = [math]::Round(($HealthyChecks.Count / $MetricsHistory.Count) * 100, 2)
    
    $TradingChecks = $MetricsHistory | Where-Object { $_.TradingActivity -gt 0 }
    $Report.Summary.TradingActivity = $TradingChecks.Count
    
    $APIChecks = $MetricsHistory | Where-Object { $_.BinanceAPI -eq $true }
    $Report.Summary.APIUptime = [math]::Round(($APIChecks.Count / $MetricsHistory.Count) * 100, 2)
    
    $Report.Summary.AverageCPU = [math]::Round(($MetricsHistory | Measure-Object -Property CPUUsage -Average).Average, 2)
    $Report.Summary.AverageMemory = ($MetricsHistory | Measure-Object -Property MemoryUsage -Average).Average
    
    # Save report
    $Report | ConvertTo-Json -Depth 10 | Out-File -FilePath $ReportFile -Encoding UTF8
    
    Write-Log "Daily report generated: $ReportFile"
    return $Report
}

# Alert function
function Send-Alert {
    param([string]$Message, [string]$Severity = "WARNING")
    
    $AlertFile = "$LogDirectory\alerts.log"
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $AlertMessage = "[$Timestamp] [$Severity] $Message"
    
    Add-Content -Path $AlertFile -Value $AlertMessage
    Write-Host $AlertMessage -ForegroundColor Red
}

# Main monitoring loop
Write-Log "Starting testnet long-term monitoring..."
Write-Log "Check interval: $CheckIntervalMinutes minutes"
Write-Log "Log directory: $LogDirectory"
Write-Log "Report directory: $ReportDirectory"

$MetricsHistory = @()
$LastReportDate = Get-Date -Format "yyyy-MM-dd"

while ($true) {
    try {
        $Metrics = Get-SystemMetrics
        $MetricsHistory += $Metrics
        
        # Log current status
        $HealthyServices = ($Metrics.Services.Values | Where-Object { $_ -eq $true }).Count
        $TotalServices = $Metrics.Services.Count
        
        Write-Log "Health Check - Services: $HealthyServices/$TotalServices healthy, Trading Activity: $($Metrics.TradingActivity), API: $($Metrics.BinanceAPI), CPU: $($Metrics.CPUUsage)%, Memory: $($Metrics.MemoryUsage)"
        
        # Check for alerts
        if ($HealthyServices -lt $TotalServices) {
            $UnhealthyServices = $Metrics.Services.GetEnumerator() | Where-Object { $_.Value -eq $false }
            foreach ($Service in $UnhealthyServices) {
                Send-Alert "Service $($Service.Key) is unhealthy" "CRITICAL"
            }
        }
        
        if (-not $Metrics.BinanceAPI) {
            Send-Alert "Binance API connectivity lost" "WARNING"
        }
        
        if ([int]$Metrics.CPUUsage -gt 80) {
            Send-Alert "High CPU usage: $($Metrics.CPUUsage)%" "WARNING"
        }
        
        # Generate daily report
        $CurrentDate = Get-Date -Format "yyyy-MM-dd"
        if ($CurrentDate -ne $LastReportDate) {
            $Report = New-DailyReport $MetricsHistory
            $LastReportDate = $CurrentDate
            $MetricsHistory = @() # Reset for new day
        }
        
        # Keep only last 24 hours of metrics in memory
        $CutoffTime = (Get-Date).AddHours(-24)
        $MetricsHistory = $MetricsHistory | Where-Object { [DateTime]::ParseExact($_.Timestamp, "yyyy-MM-dd HH:mm:ss", $null) -gt $CutoffTime }
        
    }
    catch {
        Write-Log "Error in monitoring loop: $($_.Exception.Message)" "ERROR"
        Send-Alert "Monitoring script error: $($_.Exception.Message)" "CRITICAL"
    }
    
    Start-Sleep -Seconds ($CheckIntervalMinutes * 60)
}
