# Run PostgreSQL and Kafka Health Tests
param([string]$Environment = "testnet")

Write-Host "PostgreSQL and Kafka Health Test Suite" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Start the health API service in the background
Write-Host "`nStarting Health API Service..." -ForegroundColor Yellow
$healthApiJob = Start-Job -ScriptBlock {
    param($Port)
    & "C:\Projects\binance-ai-traders\scripts\simple-health-api.ps1" -Port $Port
} -ArgumentList 8087

# Wait for the service to start
Write-Host "Waiting for Health API to start..." -ForegroundColor Cyan
Start-Sleep -Seconds 5

# Test the health API
Write-Host "`nTesting Health API..." -ForegroundColor Yellow
try {
    $testResponse = Invoke-WebRequest -Uri "http://localhost:8087/health" -TimeoutSec 10
    if ($testResponse.StatusCode -eq 200) {
        Write-Host "Health API is running" -ForegroundColor Green
    } else {
        Write-Host "Health API returned status: $($testResponse.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Health API test failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Continuing with direct health checks..." -ForegroundColor Yellow
}

# Run the direct health check
Write-Host "`nRunning Direct Health Checks..." -ForegroundColor Yellow
& "C:\Projects\binance-ai-traders\scripts\health-check-final.ps1" -Environment $Environment

# Run Postman tests if Newman is available
Write-Host "`nRunning Postman Tests..." -ForegroundColor Yellow
try {
    $newmanTest = newman run "postman\PostgreSQL-Kafka-Health-Tests.json" -e "postman\Binance-AI-Traders-Testnet-Environment.json" --reporters cli
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Postman tests completed successfully" -ForegroundColor Green
    } else {
        Write-Host "Postman tests had some failures" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Postman tests failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Make sure Newman is installed: npm install -g newman" -ForegroundColor Yellow
}

# Clean up
Write-Host "`nCleaning up..." -ForegroundColor Yellow
if ($healthApiJob) {
    Stop-Job $healthApiJob -PassThru | Remove-Job
    Write-Host "Health API service stopped" -ForegroundColor Green
}

Write-Host "`nTest suite completed!" -ForegroundColor Cyan
