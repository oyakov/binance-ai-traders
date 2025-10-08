# Test Metrics Simple
Write-Host "=== Testing Metrics ===" -ForegroundColor Green
Write-Host ""

# Test Collection Service
Write-Host "Testing Collection Service..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8086/actuator/health" -UseBasicParsing -TimeoutSec 5
    Write-Host "Collection Health: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "Collection Health: ERROR - $($_.Exception.Message)" -ForegroundColor Red
}

# Test Storage Service
Write-Host "Testing Storage Service..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8087/actuator/health" -UseBasicParsing -TimeoutSec 5
    Write-Host "Storage Health: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "Storage Health: ERROR - $($_.Exception.Message)" -ForegroundColor Red
}

# Test Prometheus
Write-Host "Testing Prometheus..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:9091/api/v1/targets" -UseBasicParsing -TimeoutSec 5
    Write-Host "Prometheus: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "Prometheus: ERROR - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Quick Access Links ===" -ForegroundColor Green
Write-Host "Grafana: http://localhost:3001 (admin/testnet_admin)" -ForegroundColor Cyan
Write-Host "Prometheus: http://localhost:9091" -ForegroundColor Cyan
Write-Host "Collection Metrics: http://localhost:8086/actuator/prometheus" -ForegroundColor Cyan
Write-Host "Storage Metrics: http://localhost:8087/actuator/prometheus" -ForegroundColor Cyan
