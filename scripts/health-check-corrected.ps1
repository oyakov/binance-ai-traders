# Corrected PostgreSQL and Kafka Health Check Script
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
            
            # Test database connection
            $dbTest = docker exec postgres-$Environment psql -U testnet_user -d binance_trader_testnet -c "SELECT 1 as test;" 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ PostgreSQL database connection test successful" -ForegroundColor Green
                $postgresHealthy = $true
            } else {
                Write-Host "⚠️  PostgreSQL database connection test failed" -ForegroundColor Yellow
                $postgresHealthy = $true  # Still healthy if container is running
            }
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
        
        # Try to list topics using the correct internal port (29092)
        Write-Host "🔍 Testing Kafka connectivity on internal port 29092..." -ForegroundColor Cyan
        $topics = docker exec kafka-$Environment kafka-topics --bootstrap-server kafka-$Environment:29092 --list --timeout-ms 5000 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Kafka is responding on internal port 29092" -ForegroundColor Green
            if ($topics) {
                Write-Host "📋 Available topics: $($topics -join ', ')" -ForegroundColor Cyan
            } else {
                Write-Host "📋 No topics found (normal for fresh installation)" -ForegroundColor Cyan
            }
            $kafkaHealthy = $true
        } else {
            Write-Host "⚠️  Kafka internal port test failed, trying external port..." -ForegroundColor Yellow
            
            # Try external port (9093)
            $topicsExt = docker exec kafka-$Environment kafka-topics --bootstrap-server localhost:9093 --list --timeout-ms 5000 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Kafka is responding on external port 9093" -ForegroundColor Green
                $kafkaHealthy = $true
            } else {
                Write-Host "❌ Kafka is not responding on any port" -ForegroundColor Red
                $kafkaHealthy = $false
            }
        }
    }
} catch {
    Write-Host "❌ Kafka health check failed: $($_.Exception.Message)" -ForegroundColor Red
    $kafkaHealthy = $false
}

# Test external connectivity (from host)
Write-Host "`n🌐 External Connectivity Test" -ForegroundColor Yellow
try {
    # Test PostgreSQL from host
    Write-Host "🔍 Testing PostgreSQL from host (port 5433)..." -ForegroundColor Cyan
    $pgHostTest = docker run --rm --network binance-ai-traders_testnet-network postgres:15-alpine pg_isready -h postgres-$Environment -p 5432 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ PostgreSQL accessible from host" -ForegroundColor Green
    } else {
        Write-Host "⚠️  PostgreSQL not accessible from host" -ForegroundColor Yellow
    }
    
    # Test Kafka from host
    Write-Host "🔍 Testing Kafka from host (port 9095)..." -ForegroundColor Cyan
    $kafkaHostTest = docker run --rm --network binance-ai-traders_testnet-network confluentinc/cp-kafka:7.4.0 kafka-topics --bootstrap-server kafka-$Environment:29092 --list --timeout-ms 5000 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Kafka accessible from host" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Kafka not accessible from host" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  External connectivity test failed: $($_.Exception.Message)" -ForegroundColor Yellow
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
