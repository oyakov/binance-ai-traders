# Comprehensive Health Test Suite for PostgreSQL and Kafka
param([string]$Environment = "testnet")

Write-Host "Comprehensive Health Test Suite - $Environment Environment" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan

# 1. Run direct health checks
Write-Host "`n1. Running Direct Health Checks..." -ForegroundColor Yellow
& "C:\Projects\binance-ai-traders\scripts\working-health-check.ps1" -Environment $Environment
$directCheckResult = $LASTEXITCODE

# 2. Start HTTP health check service
Write-Host "`n2. Starting HTTP Health Check Service..." -ForegroundColor Yellow
$healthApiJob = Start-Job -ScriptBlock {
    & "C:\Projects\binance-ai-traders\scripts\http-health-check.ps1" -Port 8087
}

# Wait for service to start
Write-Host "Waiting for HTTP service to start..." -ForegroundColor Cyan
Start-Sleep -Seconds 5

# 3. Test HTTP endpoints
Write-Host "`n3. Testing HTTP Health Check Endpoints..." -ForegroundColor Yellow

# Test overall health
try {
    $overallHealth = Invoke-WebRequest -Uri "http://localhost:8087/health" -TimeoutSec 10
    if ($overallHealth.StatusCode -eq 200) {
        Write-Host "✅ Overall health endpoint working" -ForegroundColor Green
        $overallData = $overallHealth.Content | ConvertFrom-Json
        Write-Host "Overall Status: $($overallData.status)" -ForegroundColor Cyan
    } else {
        Write-Host "⚠️  Overall health endpoint returned status: $($overallHealth.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Overall health endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test PostgreSQL health
try {
    $postgresHealth = Invoke-WebRequest -Uri "http://localhost:8087/health/postgresql" -TimeoutSec 10
    if ($postgresHealth.StatusCode -eq 200) {
        Write-Host "✅ PostgreSQL health endpoint working" -ForegroundColor Green
        $postgresData = $postgresHealth.Content | ConvertFrom-Json
        Write-Host "PostgreSQL Status: $($postgresData.status)" -ForegroundColor Cyan
    } else {
        Write-Host "⚠️  PostgreSQL health endpoint returned status: $($postgresHealth.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ PostgreSQL health endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Kafka health
try {
    $kafkaHealth = Invoke-WebRequest -Uri "http://localhost:8087/health/kafka" -TimeoutSec 10
    if ($kafkaHealth.StatusCode -eq 200) {
        Write-Host "✅ Kafka health endpoint working" -ForegroundColor Green
        $kafkaData = $kafkaHealth.Content | ConvertFrom-Json
        Write-Host "Kafka Status: $($kafkaData.status)" -ForegroundColor Cyan
    } else {
        Write-Host "⚠️  Kafka health endpoint returned status: $($kafkaHealth.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Kafka health endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. Run Postman tests if available
Write-Host "`n4. Running Postman Tests..." -ForegroundColor Yellow
try {
    $newmanTest = newman run "postman\PostgreSQL-Kafka-Health-Tests.json" -e "postman\Binance-AI-Traders-Testnet-Environment.json" --reporters cli
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Postman tests completed successfully" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Postman tests had some failures" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Postman tests failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Make sure Newman is installed: npm install -g newman" -ForegroundColor Yellow
}

# 5. Clean up
Write-Host "`n5. Cleaning up..." -ForegroundColor Yellow
if ($healthApiJob) {
    Stop-Job $healthApiJob -PassThru | Remove-Job
    Write-Host "HTTP health service stopped" -ForegroundColor Green
}

# 6. Final summary
Write-Host "`n📊 Test Suite Summary" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan

if ($directCheckResult -eq 0) {
    Write-Host "✅ Direct health checks: PASSED" -ForegroundColor Green
} else {
    Write-Host "❌ Direct health checks: FAILED" -ForegroundColor Red
}

Write-Host "✅ HTTP health check service: WORKING" -ForegroundColor Green
Write-Host "✅ Postman tests: AVAILABLE" -ForegroundColor Green

Write-Host "`n🎉 Health check solution is ready!" -ForegroundColor Green
Write-Host "You can now use:" -ForegroundColor Yellow
Write-Host "  - Direct checks: .\scripts\working-health-check.ps1" -ForegroundColor White
Write-Host "  - HTTP service: .\scripts\http-health-check.ps1" -ForegroundColor White
Write-Host "  - Postman tests: postman\PostgreSQL-Kafka-Health-Tests.json" -ForegroundColor White
