# Final Health Monitoring Solution
param([string]$Environment = "testnet")

Write-Host "Final Health Monitoring Solution" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan

# Start the health metrics exporter
Write-Host "`nStarting Health Metrics Exporter..." -ForegroundColor Yellow
$healthExporterJob = Start-Job -ScriptBlock {
    & "C:\Projects\binance-ai-traders\scripts\simple-health-metrics.ps1" -Port 8090
}

Start-Sleep -Seconds 5

# Test the health metrics exporter
try {
    $testResponse = Invoke-WebRequest -Uri "http://localhost:8090/metrics" -TimeoutSec 5
    if ($testResponse.StatusCode -eq 200) {
        Write-Host "✅ Health Metrics Exporter is running" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Health Metrics Exporter test failed" -ForegroundColor Red
}

# Restart Prometheus
Write-Host "`nRestarting Prometheus..." -ForegroundColor Yellow
docker restart prometheus-testnet
Start-Sleep -Seconds 10

# Check Prometheus targets
Write-Host "`nChecking Prometheus Targets..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:9091/api/v1/targets" -TimeoutSec 5
    $data = $response.Content | ConvertFrom-Json
    $data.data.activeTargets | ForEach-Object {
        $statusColor = if ($_.health -eq "up") { "Green" } else { "Red" }
        Write-Host "Job: $($_.labels.job) | Health: $($_.health)" -ForegroundColor $statusColor
    }
} catch {
    Write-Host "❌ Could not check Prometheus targets" -ForegroundColor Red
}

# Display health metrics
Write-Host "`nCurrent Health Metrics:" -ForegroundColor Yellow
try {
    $metrics = (Invoke-WebRequest -Uri "http://localhost:8090/metrics" -TimeoutSec 5).Content
    $metrics -split "`n" | ForEach-Object {
        if ($_ -match "up.*1") {
            Write-Host "✅ $_" -ForegroundColor Green
        } elseif ($_ -match "up.*0") {
            Write-Host "❌ $_" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "❌ Could not retrieve health metrics" -ForegroundColor Red
}

Write-Host "`n📋 Health Monitoring Summary" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan

Write-Host "✅ Services Running:" -ForegroundColor Green
Write-Host "  - Health Metrics Exporter: http://localhost:8090" -ForegroundColor White
Write-Host "  - Prometheus: http://localhost:9091" -ForegroundColor White
Write-Host "  - Trading Service: http://localhost:8083/actuator/prometheus" -ForegroundColor White
Write-Host "  - Data Collection: http://localhost:8086/actuator/prometheus" -ForegroundColor White

Write-Host "`n🔧 Health Check Scripts:" -ForegroundColor Yellow
Write-Host "  - Direct Check: .\scripts\working-health-check.ps1" -ForegroundColor White
Write-Host "  - HTTP API: .\scripts\http-health-check.ps1 -Port 8087" -ForegroundColor White
Write-Host "  - Simple Metrics: .\scripts\simple-health-metrics.ps1 -Port 8090" -ForegroundColor White

Write-Host "`n📊 Monitoring Endpoints:" -ForegroundColor Cyan
Write-Host "  - Prometheus Targets: http://localhost:9091/targets" -ForegroundColor White
Write-Host "  - Prometheus Graph: http://localhost:9091/graph" -ForegroundColor White
Write-Host "  - Health Metrics: http://localhost:8090/metrics" -ForegroundColor White

Write-Host "`n🎉 Complete Health Monitoring Solution is now active!" -ForegroundColor Green

# Keep running
Write-Host "`nPress Ctrl+C to stop..." -ForegroundColor Yellow
try {
    Wait-Job $healthExporterJob
} catch {
    Write-Host "Health monitoring stopped." -ForegroundColor Yellow
} finally {
    Stop-Job $healthExporterJob -PassThru | Remove-Job
}
