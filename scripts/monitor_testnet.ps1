# Testnet Monitoring Script
# This script monitors all testnet services and analyzes logs periodically

param(
    [int]$IntervalSeconds = 30,
    [int]$MaxIterations = 0  # 0 = run indefinitely
)

$iteration = 0
$services = @(
    "binance-trader-macd-testnet",
    "postgres-testnet", 
    "elasticsearch-testnet",
    "kafka-testnet",
    "zookeeper-testnet",
    "schema-registry-testnet",
    "prometheus-testnet",
    "grafana-testnet"
)

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message" -ForegroundColor $Color
}

function Get-ServiceStatus {
    param([string]$ServiceName)
    
    try {
        $status = docker inspect $ServiceName --format='{{.State.Status}}' 2>$null
        $health = docker inspect $ServiceName --format='{{.State.Health.Status}}' 2>$null
        return @{
            Status = $status
            Health = $health
        }
    }
    catch {
        return @{
            Status = "Unknown"
            Health = "Unknown"
        }
    }
}

function Analyze-Logs {
    param([string]$ServiceName, [int]$Lines = 10)
    
    try {
        $logs = docker logs $ServiceName --tail $Lines 2>$null
        if ($logs) {
            $errorCount = ($logs | Select-String -Pattern "ERROR|FATAL|Exception|Failed" -CaseSensitive:$false).Count
            $warnCount = ($logs | Select-String -Pattern "WARN" -CaseSensitive:$false).Count
            $infoCount = ($logs | Select-String -Pattern "INFO" -CaseSensitive:$false).Count
            
            return @{
                ErrorCount = $errorCount
                WarnCount = $warnCount
                InfoCount = $infoCount
                RecentLogs = $logs
            }
        }
    }
    catch {
        return @{
            ErrorCount = 0
            WarnCount = 0
            InfoCount = 0
            RecentLogs = @()
        }
    }
}

function Show-ServiceSummary {
    Write-ColorOutput "=== TESTNET SERVICES STATUS ===" "Cyan"
    Write-ColorOutput "Monitoring interval: $IntervalSeconds seconds" "Yellow"
    Write-ColorOutput "Iteration: $iteration" "Yellow"
    Write-ColorOutput ""
    
    foreach ($service in $services) {
        $status = Get-ServiceStatus $service
        $logAnalysis = Analyze-Logs $service 5
        
        $statusColor = switch ($status.Status) {
            "running" { "Green" }
            "restarting" { "Yellow" }
            "exited" { "Red" }
            default { "Gray" }
        }
        
        $healthColor = switch ($status.Health) {
            "healthy" { "Green" }
            "unhealthy" { "Red" }
            "starting" { "Yellow" }
            default { "Gray" }
        }
        
        Write-ColorOutput "Service: $service" "White"
        Write-ColorOutput "  Status: $($status.Status)" $statusColor
        Write-ColorOutput "  Health: $($status.Health)" $healthColor
        Write-ColorOutput "  Recent Logs - Errors: $($logAnalysis.ErrorCount), Warnings: $($logAnalysis.WarnCount), Info: $($logAnalysis.InfoCount)" "White"
        
        if ($logAnalysis.ErrorCount -gt 0) {
            Write-ColorOutput "  ⚠️  ERRORS DETECTED in recent logs!" "Red"
            $logAnalysis.RecentLogs | Where-Object { $_ -match "ERROR|FATAL|Exception|Failed" } | ForEach-Object {
                Write-ColorOutput "    $($_.Trim())" "Red"
            }
        }
        
        if ($logAnalysis.WarnCount -gt 0) {
            Write-ColorOutput "  ⚠️  Warnings in recent logs:" "Yellow"
            $logAnalysis.RecentLogs | Where-Object { $_ -match "WARN" } | Select-Object -First 3 | ForEach-Object {
                Write-ColorOutput "    $($_.Trim())" "Yellow"
            }
        }
        
        Write-ColorOutput ""
    }
}

function Show-DetailedLogs {
    Write-ColorOutput "=== DETAILED LOG ANALYSIS ===" "Cyan"
    
    # Focus on the main trader service
    Write-ColorOutput "--- Binance Trader MACD Testnet Logs (Last 20 lines) ---" "Yellow"
    $traderLogs = docker logs binance-trader-macd-testnet --tail 20 2>$null
    if ($traderLogs) {
        $traderLogs | ForEach-Object {
            if ($_ -match "ERROR|FATAL|Exception") {
                Write-ColorOutput "  $($_.Trim())" "Red"
            } elseif ($_ -match "WARN") {
                Write-ColorOutput "  $($_.Trim())" "Yellow"
            } else {
                Write-ColorOutput "  $($_.Trim())" "White"
            }
        }
    }
    
    Write-ColorOutput ""
    
    # Check for any critical issues
    Write-ColorOutput "--- Critical Issues Check ---" "Yellow"
    $allLogs = @()
    foreach ($service in $services) {
        $logs = docker logs $service --tail 50 2>$null
        if ($logs) {
            $allLogs += $logs | Where-Object { $_ -match "ERROR|FATAL|Exception|Failed|Cannot|Unable" }
        }
    }
    
    if ($allLogs.Count -gt 0) {
        Write-ColorOutput "Found $($allLogs.Count) critical log entries:" "Red"
        $allLogs | Select-Object -First 10 | ForEach-Object {
            Write-ColorOutput "  $($_.Trim())" "Red"
        }
    } else {
        Write-ColorOutput "No critical issues detected in recent logs" "Green"
    }
}

# Main monitoring loop
Write-ColorOutput "Starting Testnet Monitoring..." "Green"
Write-ColorOutput "Press Ctrl+C to stop" "Yellow"
Write-ColorOutput ""

do {
    $iteration++
    
    Show-ServiceSummary
    
    if ($iteration % 3 -eq 0) {  # Every 3rd iteration, show detailed logs
        Show-DetailedLogs
    }
    
    Write-ColorOutput "=== END OF ITERATION $iteration ===" "Cyan"
    Write-ColorOutput "Next check in $IntervalSeconds seconds..." "Yellow"
    Write-ColorOutput "----------------------------------------" "Gray"
    
    if ($MaxIterations -gt 0 -and $iteration -ge $MaxIterations) {
        break
    }
    
    Start-Sleep -Seconds $IntervalSeconds
    
} while ($true)

Write-ColorOutput "Monitoring stopped." "Red"
