# Simple PostgreSQL and Kafka Test Script
param([string]$Environment = "testnet")

Write-Host "Testing PostgreSQL and Kafka - $Environment Environment" -ForegroundColor Cyan

# Test PostgreSQL
Write-Host "`nTesting PostgreSQL..." -ForegroundColor Yellow
$pgStatus = docker inspect postgres-$Environment --format "{{.State.Status}}" 2>$null
if ($pgStatus -eq "running") {
    Write-Host "PostgreSQL container is running" -ForegroundColor Green
    $pgReady = docker exec postgres-$Environment pg_isready -h localhost -p 5432 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "PostgreSQL is accepting connections" -ForegroundColor Green
        $postgresOK = $true
    } else {
        Write-Host "PostgreSQL is not accepting connections" -ForegroundColor Red
        $postgresOK = $false
    }
} else {
    Write-Host "PostgreSQL container is not running" -ForegroundColor Red
    $postgresOK = $false
}

# Test Kafka
Write-Host "`nTesting Kafka..." -ForegroundColor Yellow
$kafkaStatus = docker inspect kafka-$Environment --format "{{.State.Status}}" 2>$null
if ($kafkaStatus -eq "running") {
    Write-Host "Kafka container is running" -ForegroundColor Green
    $topics = docker exec kafka-$Environment kafka-topics --bootstrap-server kafka-$Environment:29092 --list --timeout-ms 5000 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Kafka is responding on port 29092" -ForegroundColor Green
        $kafkaOK = $true
    } else {
        Write-Host "Kafka is not responding on port 29092" -ForegroundColor Red
        $kafkaOK = $false
    }
} else {
    Write-Host "Kafka container is not running" -ForegroundColor Red
    $kafkaOK = $false
}

# Summary
Write-Host "`nSummary:" -ForegroundColor Cyan
Write-Host "PostgreSQL: $(if($postgresOK) {'OK'} else {'FAIL'})" -ForegroundColor $(if($postgresOK) {'Green'} else {'Red'})
Write-Host "Kafka: $(if($kafkaOK) {'OK'} else {'FAIL'})" -ForegroundColor $(if($kafkaOK) {'Green'} else {'Red'})

if ($postgresOK -and $kafkaOK) {
    Write-Host "`nAll services are healthy!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`nSome services are unhealthy!" -ForegroundColor Yellow
    exit 1
}
