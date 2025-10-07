# Simple PostgreSQL and Kafka Health Check Script
param([string]$Environment = "testnet")

Write-Host "🔍 PostgreSQL and Kafka Health Check - $Environment Environment" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Check PostgreSQL
Write-Host "`n📊 PostgreSQL Health Check" -ForegroundColor Yellow
try {
    $containerStatus = docker inspect postgres-$Environment --format "{{.State.Status}}" 2>$null
    if ($containerStatus -ne "running") {
        Write-Host "❌ PostgreSQL container is not running (Status: $containerStatus)" -ForegroundColor Red
        $postgresHealthy = $false
    } else {
        Write-Host "✅ PostgreSQL container is running" -ForegroundColor Green
        
        $pgReady = docker exec postgres-$Environment pg_isready -h localhost -p 5432 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ PostgreSQL is accepting connections" -ForegroundColor Green
            $postgresHealthy = $true
        } else {
            Write-Host "❌ PostgreSQL is not accepting connections" -ForegroundColor Red
            $postgresHealthy = $false
        }
    }
} catch {
    Write-Host "❌ PostgreSQL health check failed: $($_.Exception.Message)" -ForegroundColor Red
    $postgresHealthy = $false
}

# Check Kafka
Write-Host "`n📊 Kafka Health Check" -ForegroundColor Yellow
try {
    $containerStatus = docker inspect kafka-$Environment --format "{{.State.Status}}" 2>$null
    if ($containerStatus -ne "running") {
        Write-Host "❌ Kafka container is not running (Status: $containerStatus)" -ForegroundColor Red
        $kafkaHealthy = $false
    } else {
        Write-Host "✅ Kafka container is running" -ForegroundColor Green
        
        # Check if Kafka is listening on port 9092
        $portCheck = docker exec kafka-$Environment netstat -tlnp 2>$null | Select-String ":9092"
        if ($portCheck) {
            Write-Host "✅ Kafka is listening on port 9092" -ForegroundColor Green
            $kafkaHealthy = $true
        } else {
            Write-Host "❌ Kafka is not listening on port 9092" -ForegroundColor Red
            $kafkaHealthy = $false
        }
    }
} catch {
    Write-Host "❌ Kafka health check failed: $($_.Exception.Message)" -ForegroundColor Red
    $kafkaHealthy = $false
}

# Summary
Write-Host "`n📊 Health Check Summary" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan

if ($postgresHealthy) {
    Write-Host "✅ PostgreSQL: HEALTHY" -ForegroundColor Green
} else {
    Write-Host "❌ PostgreSQL: UNHEALTHY" -ForegroundColor Red
}

if ($kafkaHealthy) {
    Write-Host "✅ Kafka: HEALTHY" -ForegroundColor Green
} else {
    Write-Host "❌ Kafka: UNHEALTHY" -ForegroundColor Red
}

$overallHealth = $postgresHealthy -and $kafkaHealthy
if ($overallHealth) {
    Write-Host "`n🎉 Overall Status: ALL SERVICES HEALTHY" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n⚠️  Overall Status: SOME SERVICES UNHEALTHY" -ForegroundColor Yellow
    exit 1
}
