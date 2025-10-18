# Analyze Correlation IDs in Logs
# Parse JSON logs and analyze correlation ID usage

param(
    [string]$LogDir = "./logs",
    [int]$LastMinutes = 30,
    [switch]$ShowOrphans
)

Write-Host "===========================================`n"
Write-Host "Correlation ID Log Analysis`n"
Write-Host "===========================================`n"

# Find JSON log files
$logFiles = Get-ChildItem -Path $LogDir -Filter "*.json" -Recurse -ErrorAction SilentlyContinue

if ($logFiles.Count -eq 0) {
    Write-Host "❌ No JSON log files found in $LogDir" -ForegroundColor Red
    Write-Host "Tip: Ensure services are running with JSON logging enabled"
    exit 1
}

Write-Host "Found $($logFiles.Count) log file(s)`n"

$correlationIdMap = @{}
$orphanedLogs = @()
$totalLogEntries = 0
$cutoffTime = (Get-Date).AddMinutes(-$LastMinutes)

foreach ($logFile in $logFiles) {
    Write-Host "Analyzing: $($logFile.Name)"
    
    try {
        $lines = Get-Content $logFile.FullName -ErrorAction Stop
        
        foreach ($line in $lines) {
            $totalLogEntries++
            
            try {
                $logEntry = $line | ConvertFrom-Json
                
                # Check if log entry is within time window
                if ($logEntry.timestamp) {
                    $logTime = [DateTime]::Parse($logEntry.timestamp)
                    if ($logTime -lt $cutoffTime) {
                        continue
                    }
                }
                
                # Extract correlation ID
                $correlationId = $null
                if ($logEntry.correlationId) {
                    $correlationId = $logEntry.correlationId
                } elseif ($logEntry.correlation_id) {
                    $correlationId = $logEntry.correlation_id
                } elseif ($logEntry.mdc -and $logEntry.mdc.correlationId) {
                    $correlationId = $logEntry.mdc.correlationId
                }
                
                if ($correlationId -and $correlationId -ne "NO-CORR-ID") {
                    if (-not $correlationIdMap.ContainsKey($correlationId)) {
                        $correlationIdMap[$correlationId] = @{
                            Count = 0
                            Services = @{}
                            FirstSeen = $logEntry.timestamp
                            LastSeen = $logEntry.timestamp
                        }
                    }
                    
                    $correlationIdMap[$correlationId].Count++
                    $correlationIdMap[$correlationId].LastSeen = $logEntry.timestamp
                    
                    # Track service
                    $service = if ($logEntry.service) { $logEntry.service } else { "unknown" }
                    if (-not $correlationIdMap[$correlationId].Services.ContainsKey($service)) {
                        $correlationIdMap[$correlationId].Services[$service] = 0
                    }
                    $correlationIdMap[$correlationId].Services[$service]++
                    
                } else {
                    # Log without correlation ID
                    $orphanedLogs += [PSCustomObject]@{
                        Timestamp = $logEntry.timestamp
                        Level = $logEntry.level
                        Message = if ($logEntry.message.Length -gt 100) { $logEntry.message.Substring(0, 100) + "..." } else { $logEntry.message }
                        Service = if ($logEntry.service) { $logEntry.service } else { "unknown" }
                    }
                }
                
            } catch {
                # Skip invalid JSON lines
            }
        }
        
    } catch {
        Write-Host "  ⚠️  Warning: Could not read file: $_" -ForegroundColor Yellow
    }
}

# Display results
Write-Host "`n===========================================`n"
Write-Host "Analysis Results (Last $LastMinutes minutes)`n"
Write-Host "===========================================`n"

Write-Host "Total Log Entries Analyzed: $totalLogEntries"
Write-Host "Unique Correlation IDs: $($correlationIdMap.Count)"
Write-Host "Orphaned Logs (no correlation ID): $($orphanedLogs.Count)`n"

if ($correlationIdMap.Count -gt 0) {
    Write-Host "`n--- Top Correlation ID Chains ---`n"
    
    $top10 = $correlationIdMap.GetEnumerator() | 
        Sort-Object { $_.Value.Count } -Descending | 
        Select-Object -First 10
    
    foreach ($entry in $top10) {
        $corrId = $entry.Key
        $data = $entry.Value
        
        Write-Host "Correlation ID: $corrId" -ForegroundColor Cyan
        Write-Host "  Log Count: $($data.Count)"
        Write-Host "  First Seen: $($data.FirstSeen)"
        Write-Host "  Last Seen: $($data.LastSeen)"
        Write-Host "  Services:"
        foreach ($svc in $data.Services.GetEnumerator()) {
            Write-Host "    - $($svc.Key): $($svc.Value) logs"
        }
        Write-Host ""
    }
}

if ($ShowOrphans -and $orphanedLogs.Count -gt 0) {
    Write-Host "`n--- Orphaned Logs (Sample) ---`n"
    
    $orphanedLogs | Select-Object -First 20 | Format-Table -AutoSize
    
    if ($orphanedLogs.Count -gt 20) {
        Write-Host "`n... and $($orphanedLogs.Count - 20) more orphaned logs"
    }
}

# Calculate percentage
$percentWithCorrelation = if ($totalLogEntries -gt 0) { 
    [math]::Round(($totalLogEntries - $orphanedLogs.Count) / $totalLogEntries * 100, 2) 
} else { 
    0 
}

Write-Host "`n===========================================`n"
Write-Host "Summary`n"
Write-Host "===========================================`n"
Write-Host "Coverage: $percentWithCorrelation% of logs have correlation IDs"

if ($percentWithCorrelation -ge 95) {
    Write-Host "✅ Excellent correlation ID coverage!" -ForegroundColor Green
} elseif ($percentWithCorrelation -ge 80) {
    Write-Host "⚠️  Good coverage, but some logs lack correlation IDs" -ForegroundColor Yellow
} else {
    Write-Host "❌ Poor correlation ID coverage - review implementation" -ForegroundColor Red
}

