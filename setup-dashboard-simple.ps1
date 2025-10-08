# Setup Comprehensive Metrics Dashboard
Write-Host "=== Setting up Comprehensive Metrics Dashboard ===" -ForegroundColor Green
Write-Host ""

# Check if Grafana is running
Write-Host "Checking Grafana status..." -ForegroundColor Yellow
try {
    $grafanaStatus = Invoke-WebRequest -Uri "http://localhost:3001/api/health" -UseBasicParsing -TimeoutSec 5
    if ($grafanaStatus.StatusCode -eq 200) {
        Write-Host "Grafana is running" -ForegroundColor Green
    } else {
        Write-Host "Grafana is not responding properly" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Grafana is not running. Please start it first." -ForegroundColor Red
    Write-Host "Run: docker-compose -f docker-compose-testnet.yml up -d grafana-testnet" -ForegroundColor Yellow
    exit 1
}

# Check if Prometheus is running
Write-Host "Checking Prometheus status..." -ForegroundColor Yellow
try {
    $prometheusStatus = Invoke-WebRequest -Uri "http://localhost:9091/api/v1/targets" -UseBasicParsing -TimeoutSec 5
    if ($prometheusStatus.StatusCode -eq 200) {
        Write-Host "Prometheus is running" -ForegroundColor Green
    } else {
        Write-Host "Prometheus is not responding properly" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Prometheus is not running. Please start it first." -ForegroundColor Red
    Write-Host "Run: docker-compose -f docker-compose-testnet.yml up -d prometheus-testnet" -ForegroundColor Yellow
    exit 1
}

# Create authentication header for Grafana
$auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("admin:testnet_admin"))
$headers = @{
    "Authorization" = "Basic $auth"
    "Content-Type" = "application/json"
}

# Read the dashboard JSON
Write-Host "Reading dashboard configuration..." -ForegroundColor Yellow
$dashboardJson = Get-Content -Path "comprehensive-metrics-dashboard.json" -Raw

# Import the dashboard
Write-Host "Importing dashboard into Grafana..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3001/api/dashboards/db" -Method Post -Headers $headers -Body $dashboardJson
    Write-Host "Dashboard imported successfully!" -ForegroundColor Green
    Write-Host "Dashboard UID: $($response.uid)" -ForegroundColor Cyan
} catch {
    Write-Host "Failed to import dashboard: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== Dashboard Setup Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Access your dashboard at:" -ForegroundColor Cyan
Write-Host "http://localhost:3001/d/binance-comprehensive-metrics/binance-ai-traders-comprehensive-metrics-dashboard" -ForegroundColor White
Write-Host ""
Write-Host "Or go to Grafana and look for:" -ForegroundColor Cyan
Write-Host "  - Dashboard: Binance AI Traders - Comprehensive Metrics Dashboard" -ForegroundColor White
Write-Host "  - UID: binance-comprehensive-metrics" -ForegroundColor White
Write-Host ""
Write-Host "=== Available Metrics ===" -ForegroundColor Green
Write-Host "The dashboard includes:" -ForegroundColor Yellow
Write-Host "  - Data Processing Counters (events received/saved)" -ForegroundColor White
Write-Host "  - Database Connection Status (PostgreSQL, Elasticsearch)" -ForegroundColor White
Write-Host "  - Data Processing Rate (events per second)" -ForegroundColor White
Write-Host "  - Processing Performance (latency percentiles)" -ForegroundColor White
Write-Host "  - Database Operations (saves to each database)" -ForegroundColor White
Write-Host "  - Error Counters (failed events, Kafka errors)" -ForegroundColor White
Write-Host "  - JVM Memory Usage (both services)" -ForegroundColor White
Write-Host "  - CPU Usage (both services)" -ForegroundColor White
Write-Host ""
Write-Host "=== Next Steps ===" -ForegroundColor Green
Write-Host "1. Open the dashboard in your browser" -ForegroundColor Yellow
Write-Host "2. If you see 'No data', the services might not be actively processing data" -ForegroundColor Yellow
Write-Host "3. To generate test data, run: .\generate-test-metrics.ps1" -ForegroundColor Yellow
Write-Host "4. Check Prometheus directly at: http://localhost:9091" -ForegroundColor Yellow
