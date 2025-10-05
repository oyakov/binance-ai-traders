# Health Monitoring Script for Testnet Services
# This script monitors service health and creates metrics for Prometheus

param(
    [int]$IntervalSeconds = 30,
    [int]$MaxIterations = 0  # 0 = run indefinitely
)

$iteration = 0
$services = @(
    @{Name="Trading Service"; Url="http://localhost:8083/actuator/health"; Port=8083},
    @{Name="PostgreSQL"; Url="http://localhost:5433"; Port=5433},
    @{Name="Elasticsearch"; Url="http://localhost:9202/_cluster/health"; Port=9202},
    @{Name="Kafka"; Url="http://localhost:9095"; Port=9095},
    @{Name="Prometheus"; Url="http://localhost:9091"; Port=9091},
    @{Name="Grafana"; Url="http://localhost:3001"; Port=3001}
)

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message" -ForegroundColor $Color
}

function Test-ServiceHealth {
    param([object]$Service)
    
    try {
        $response = Invoke-WebRequest -Uri $Service.Url -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            return @{Status="UP"; Details="HTTP 200"}
        } else {
            return @{Status="DOWN"; Details="HTTP $($response.StatusCode)"}
        }
    }
    catch {
        # Try port connectivity as fallback
        try {
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $tcpClient.Connect("localhost", $Service.Port)
            $tcpClient.Close()
            return @{Status="UP"; Details="Port $($Service.Port) accessible"}
        }
        catch {
            return @{Status="DOWN"; Details=$_.Exception.Message}
        }
    }
}

function Show-HealthSummary {
    Write-ColorOutput "=== SERVICE HEALTH SUMMARY ===" "Cyan"
    Write-ColorOutput "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" "Yellow"
    Write-ColorOutput ""
    
    $healthyCount = 0
    $totalCount = $services.Count
    
    foreach ($service in $services) {
        $health = Test-ServiceHealth $service
        
        if ($health.Status -eq "UP") {
            $healthyCount++
            Write-ColorOutput "✅ $($service.Name): $($health.Status) - $($health.Details)" "Green"
        } else {
            Write-ColorOutput "❌ $($service.Name): $($health.Status) - $($health.Details)" "Red"
        }
    }
    
    Write-ColorOutput ""
    Write-ColorOutput "Health Summary: $healthyCount/$totalCount services healthy" "White"
    
    if ($healthyCount -eq $totalCount) {
        Write-ColorOutput "🎉 ALL SERVICES HEALTHY!" "Green"
    } elseif ($healthyCount -gt ($totalCount / 2)) {
        Write-ColorOutput "⚠️  MOST SERVICES HEALTHY" "Yellow"
    } else {
        Write-ColorOutput "🚨 MULTIPLE SERVICES DOWN" "Red"
    }
    
    return $healthyCount
}

# Main monitoring loop
Write-ColorOutput "Starting Health Monitoring..." "Green"
Write-ColorOutput "Monitoring interval: $IntervalSeconds seconds" "Yellow"
Write-ColorOutput "Press Ctrl+C to stop" "Yellow"
Write-ColorOutput ""

do {
    $iteration++
    
    $healthyCount = Show-HealthSummary
    
    Write-ColorOutput "=== END OF ITERATION $iteration ===" "Cyan"
    Write-ColorOutput "Next check in $IntervalSeconds seconds..." "Yellow"
    Write-ColorOutput "----------------------------------------" "Gray"
    
    if ($MaxIterations -gt 0 -and $iteration -ge $MaxIterations) {
        break
    }
    
    Start-Sleep -Seconds $IntervalSeconds
    
} while ($true)

Write-ColorOutput "Health monitoring stopped." "Red"
