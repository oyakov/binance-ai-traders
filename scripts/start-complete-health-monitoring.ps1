# Complete Health Monitoring Solution
# This script starts all health monitoring services and integrates them with Prometheus

param([string]$Environment = "testnet")

Write-Host "Starting Complete Health Monitoring Solution" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# 1. Start the simple health metrics exporter
Write-Host "`n1. Starting Health Metrics Exporter..." -ForegroundColor Yellow
$healthExporterJob = Start-Job -ScriptBlock {
    & "C:\Projects\binance-ai-traders\scripts\simple-health-metrics.ps1" -Port 8090
}

# Wait for the service to start
Start-Sleep -Seconds 5

# Test the health metrics exporter
try {
    $testResponse = Invoke-WebRequest -Uri "http://localhost:8090/metrics" -TimeoutSec 5
    if ($testResponse.StatusCode -eq 200) {
        Write-Host "✅ Health Metrics Exporter is running" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Health Metrics Exporter returned status: $($testResponse.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Health Metrics Exporter test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 2. Update Prometheus configuration
Write-Host "`n2. Updating Prometheus Configuration..." -ForegroundColor Yellow

# Update the Prometheus config to use the working health exporter
$prometheusConfig = @"
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "/etc/prometheus/alert_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets: []

scrape_configs:
  - job_name: binance-macd-trader-testnet
    metrics_path: /actuator/prometheus
    scheme: http
    static_configs:
      - targets:
          - binance-trader-macd-testnet:8080
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
      - target_label: environment
        replacement: testnet

  - job_name: binance-data-collection-testnet
    metrics_path: /actuator/prometheus
    scheme: http
    static_configs:
      - targets:
          - binance-data-collection-testnet:8080
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
      - target_label: environment
        replacement: testnet

  - job_name: health-metrics-exporter
    static_configs:
      - targets:
          - host.docker.internal:8090
    metrics_path: /metrics
    scrape_interval: 30s
    scrape_timeout: 10s
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
      - target_label: environment
        replacement: testnet

  - job_name: prometheus
    static_configs:
      - targets:
          - localhost:9090
"@

$prometheusConfig | Out-File -FilePath "monitoring/prometheus/testnet-prometheus.yml" -Encoding UTF8
Write-Host "✅ Prometheus configuration updated" -ForegroundColor Green

# 3. Restart Prometheus
Write-Host "`n3. Restarting Prometheus..." -ForegroundColor Yellow
docker restart prometheus-testnet
Start-Sleep -Seconds 10
Write-Host "✅ Prometheus restarted" -ForegroundColor Green

# 4. Check Prometheus targets
Write-Host "`n4. Checking Prometheus Targets..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:9091/api/v1/targets" -TimeoutSec 5
    $data = $response.Content | ConvertFrom-Json
    $data.data.activeTargets | ForEach-Object {
        $statusColor = if ($_.health -eq "up") { "Green" } else { "Red" }
        Write-Host "Job: $($_.labels.job) | Instance: $($_.labels.instance) | Health: $($_.health)" -ForegroundColor $statusColor
    }
} catch {
    Write-Host "❌ Could not check Prometheus targets: $($_.Exception.Message)" -ForegroundColor Red
}

# 5. Display health metrics
Write-Host "`n5. Current Health Metrics:" -ForegroundColor Yellow
try {
    $metrics = (Invoke-WebRequest -Uri "http://localhost:8090/metrics" -TimeoutSec 5).Content
    $metrics -split "`n" | ForEach-Object {
        if ($_ -match "up.*1") {
            Write-Host "✅ $_" -ForegroundColor Green
        } elseif ($_ -match "up.*0") {
            Write-Host "❌ $_" -ForegroundColor Red
        } else {
            Write-Host "📊 $_" -ForegroundColor Cyan
        }
    }
} catch {
    Write-Host "❌ Could not retrieve health metrics: $($_.Exception.Message)" -ForegroundColor Red
}

# 6. Summary
Write-Host "`n📋 Health Monitoring Summary" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan

Write-Host "✅ Services Running:" -ForegroundColor Green
Write-Host "  - Health Metrics Exporter: http://localhost:8090" -ForegroundColor White
Write-Host "  - Prometheus: http://localhost:9091" -ForegroundColor White
Write-Host "  - Trading Service Metrics: http://localhost:8083/actuator/prometheus" -ForegroundColor White
Write-Host "  - Data Collection Metrics: http://localhost:8086/actuator/prometheus" -ForegroundColor White

Write-Host "`n🔧 Available Health Checks:" -ForegroundColor Yellow
Write-Host "  - Direct Health Check: .\scripts\working-health-check.ps1" -ForegroundColor White
Write-Host "  - HTTP Health API: .\scripts\http-health-check.ps1 -Port 8087" -ForegroundColor White
Write-Host "  - Simple Metrics: .\scripts\simple-health-metrics.ps1 -Port 8090" -ForegroundColor White

Write-Host "`n📊 Monitoring Endpoints:" -ForegroundColor Cyan
Write-Host "  - Prometheus Targets: http://localhost:9091/targets" -ForegroundColor White
Write-Host "  - Prometheus Graph: http://localhost:9091/graph" -ForegroundColor White
Write-Host "  - Health Metrics: http://localhost:8090/metrics" -ForegroundColor White
Write-Host "  - Health Status: http://localhost:8090/health" -ForegroundColor White

Write-Host "`n🎉 Complete Health Monitoring Solution is now active!" -ForegroundColor Green
Write-Host "All system components are being monitored with comprehensive health metrics." -ForegroundColor Green

# Keep the health exporter running
Write-Host "`nPress Ctrl+C to stop the health monitoring services..." -ForegroundColor Yellow
try {
    Wait-Job $healthExporterJob
} catch {
    Write-Host "Health monitoring stopped." -ForegroundColor Yellow
} finally {
    Stop-Job $healthExporterJob -PassThru | Remove-Job
}
