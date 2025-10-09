# Open Monitoring Tools Script
# This script opens the monitoring tools in your default browser

Write-Host "=== Binance AI Traders - Monitoring Tools ===" -ForegroundColor Green
Write-Host ""

# Check if services are running
Write-Host "Checking service status..." -ForegroundColor Yellow

$collectionStatus = try { (Invoke-WebRequest -Uri "http://localhost:8086/actuator/health" -UseBasicParsing -TimeoutSec 5).StatusCode } catch { "DOWN" }
$storageStatus = try { (Invoke-WebRequest -Uri "http://localhost:8087/actuator/health" -UseBasicParsing -TimeoutSec 5).StatusCode } catch { "DOWN" }
$prometheusStatus = try { (Invoke-WebRequest -Uri "http://localhost:9091/api/v1/targets" -UseBasicParsing -TimeoutSec 5).StatusCode } catch { "DOWN" }
$grafanaStatus = try { (Invoke-WebRequest -Uri "http://localhost:3001/api/health" -UseBasicParsing -TimeoutSec 5).StatusCode } catch { "DOWN" }

Write-Host "Service Status:" -ForegroundColor Cyan
Write-Host "  Collection Service: " -NoNewline
if ($collectionStatus -eq 200) { Write-Host "✓ RUNNING" -ForegroundColor Green } else { Write-Host "✗ DOWN" -ForegroundColor Red }

Write-Host "  Storage Service: " -NoNewline
if ($storageStatus -eq 200) { Write-Host "✓ RUNNING" -ForegroundColor Green } else { Write-Host "✗ DOWN" -ForegroundColor Red }

Write-Host "  Prometheus: " -NoNewline
if ($prometheusStatus -eq 200) { Write-Host "✓ RUNNING" -ForegroundColor Green } else { Write-Host "✗ DOWN" -ForegroundColor Red }

Write-Host "  Grafana: " -NoNewline
if ($grafanaStatus -eq 200) { Write-Host "✓ RUNNING" -ForegroundColor Green } else { Write-Host "✗ DOWN" -ForegroundColor Red }

Write-Host ""

# Available monitoring tools
Write-Host "=== Available Monitoring Tools ===" -ForegroundColor Green
Write-Host ""

Write-Host "1. PROMETHEUS (Raw Metrics & Queries)" -ForegroundColor Yellow
Write-Host "   URL: http://localhost:9091" -ForegroundColor White
Write-Host "   Purpose: Query metrics, view raw data, set up alerts" -ForegroundColor Gray
Write-Host "   Example queries:" -ForegroundColor Gray
Write-Host "     - binance_data_collection_kline_events_received_total" -ForegroundColor DarkGray
Write-Host "     - binance_data_storage_postgres_connection_status" -ForegroundColor DarkGray
Write-Host "     - rate(http_server_requests_seconds_count[5m])" -ForegroundColor DarkGray
Write-Host ""

Write-Host "2. GRAFANA (Beautiful Dashboards)" -ForegroundColor Yellow
Write-Host "   URL: http://localhost:3001" -ForegroundColor White
Write-Host "   Username: admin" -ForegroundColor White
Write-Host "   Password: testnet_admin" -ForegroundColor White
Write-Host "   Purpose: Visual dashboards, charts, and monitoring" -ForegroundColor Gray
Write-Host ""

Write-Host "3. DIRECT METRICS ENDPOINTS" -ForegroundColor Yellow
Write-Host "   Collection Service: http://localhost:8086/actuator/prometheus" -ForegroundColor White
Write-Host "   Storage Service: http://localhost:8087/actuator/prometheus" -ForegroundColor White
Write-Host ""

# Ask user what they want to open
Write-Host "What would you like to open?" -ForegroundColor Cyan
Write-Host "1. Prometheus" -ForegroundColor White
Write-Host "2. Grafana" -ForegroundColor White
Write-Host "3. Both" -ForegroundColor White
Write-Host "4. Collection Service Metrics" -ForegroundColor White
Write-Host "5. Storage Service Metrics" -ForegroundColor White
Write-Host "6. Exit" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter your choice (1-6)"

switch ($choice) {
    "1" {
        Write-Host "Opening Prometheus..." -ForegroundColor Green
        Start-Process "http://localhost:9091"
    }
    "2" {
        Write-Host "Opening Grafana..." -ForegroundColor Green
        Start-Process "http://localhost:3001"
    }
    "3" {
        Write-Host "Opening both Prometheus and Grafana..." -ForegroundColor Green
        Start-Process "http://localhost:9091"
        Start-Process "http://localhost:3001"
    }
    "4" {
        Write-Host "Opening Collection Service Metrics..." -ForegroundColor Green
        Start-Process "http://localhost:8086/actuator/prometheus"
    }
    "5" {
        Write-Host "Opening Storage Service Metrics..." -ForegroundColor Green
        Start-Process "http://localhost:8087/actuator/prometheus"
    }
    "6" {
        Write-Host "Goodbye!" -ForegroundColor Green
        exit
    }
    default {
        Write-Host "Invalid choice. Please run the script again." -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Quick Reference ===" -ForegroundColor Green
Write-Host "Prometheus: http://localhost:9091" -ForegroundColor White
Write-Host "Grafana: http://localhost:3001 (admin/testnet_admin)" -ForegroundColor White
Write-Host "Collection Metrics: http://localhost:8086/actuator/prometheus" -ForegroundColor White
Write-Host "Storage Metrics: http://localhost:8087/actuator/prometheus" -ForegroundColor White
