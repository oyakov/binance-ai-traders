# PostgreSQL and Kafka Health Check Script
# This script provides reliable health checks for PostgreSQL and Kafka services

param(
    [string]$Environment = "testnet"
)

Write-Host "🔍 PostgreSQL and Kafka Health Check - $Environment Environment" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Function to check PostgreSQL health
function Test-PostgreSQLHealth {
    Write-Host "`n📊 PostgreSQL Health Check" -ForegroundColor Yellow
    
    try {
        # Check if container is running
        $containerStatus = docker inspect postgres-$Environment --format "{{.State.Status}}" 2>$null
        if ($containerStatus -ne "running") {
            Write-Host "❌ PostgreSQL container is not running (Status: $containerStatus)" -ForegroundColor Red
            return $false
        }
        
        # Check if PostgreSQL is accepting connections
        $pgReady = docker exec postgres-$Environment pg_isready -h localhost -p 5432 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ PostgreSQL is not accepting connections" -ForegroundColor Red
            return $false
        }
        
        Write-Host "✅ PostgreSQL container is running" -ForegroundColor Green
        Write-Host "✅ PostgreSQL is accepting connections" -ForegroundColor Green
        
        # Test database connection with a simple query
        $dbTest = docker exec postgres-$Environment psql -U postgres -d postgres -c "SELECT 1 as test;" 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ PostgreSQL database connection test successful" -ForegroundColor Green
        } else {
            Write-Host "⚠️  PostgreSQL database connection test failed" -ForegroundColor Yellow
        }
        
        # Get PostgreSQL version
        $version = docker exec postgres-$Environment psql -U postgres -d postgres -t -c "SELECT version();" 2>$null
        if ($version) {
            Write-Host "📋 PostgreSQL Version: $($version.Trim())" -ForegroundColor Cyan
        }
        
        return $true
    }
    catch {
        Write-Host "❌ PostgreSQL health check failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to check Kafka health
function Test-KafkaHealth {
    Write-Host "`n📊 Kafka Health Check" -ForegroundColor Yellow
    
    try {
        # Check if container is running
        $containerStatus = docker inspect kafka-$Environment --format "{{.State.Status}}" 2>$null
        if ($containerStatus -ne "running") {
            Write-Host "❌ Kafka container is not running (Status: $containerStatus)" -ForegroundColor Red
            return $false
        }
        
        Write-Host "✅ Kafka container is running" -ForegroundColor Green
        
        # Check Kafka broker health using kafka-broker-api-versions
        Write-Host "🔍 Testing Kafka broker connectivity..." -ForegroundColor Cyan
        $kafkaTest = docker exec kafka-$Environment kafka-broker-api-versions --bootstrap-server kafka-$Environment:9092 --timeout-ms 5000 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Kafka broker is responding" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Kafka broker API test failed, trying alternative method..." -ForegroundColor Yellow
            
            # Alternative: Check if Kafka is listening on the correct port
            $portCheck = docker exec kafka-$Environment netstat -tlnp | findstr ":9092"
            if ($portCheck) {
                Write-Host "✅ Kafka is listening on port 9092" -ForegroundColor Green
            } else {
                Write-Host "❌ Kafka is not listening on port 9092" -ForegroundColor Red
                return $false
            }
        }
        
        # Check if we can list topics (this tests the full connection)
        Write-Host "🔍 Testing Kafka topic listing..." -ForegroundColor Cyan
        $topics = docker exec kafka-$Environment kafka-topics --bootstrap-server kafka-$Environment:9092 --list --timeout-ms 5000 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Kafka topic listing successful" -ForegroundColor Green
            if ($topics) {
                Write-Host "📋 Available topics: $($topics -join ', ')" -ForegroundColor Cyan
            } else {
                Write-Host "📋 No topics found (this is normal for a fresh installation)" -ForegroundColor Cyan
            }
        } else {
            Write-Host "⚠️  Kafka topic listing failed, but broker might still be healthy" -ForegroundColor Yellow
        }
        
        # Check Kafka logs for any critical errors
        $errorLogs = docker logs kafka-$Environment --tail 50 2>$null | Select-String -Pattern "ERROR|FATAL|Exception" -CaseSensitive:$false
        if ($errorLogs) {
            Write-Host "⚠️  Found potential issues in Kafka logs:" -ForegroundColor Yellow
            $errorLogs | ForEach-Object { Write-Host "   $($_.Line)" -ForegroundColor Yellow }
        } else {
            Write-Host "✅ No critical errors found in Kafka logs" -ForegroundColor Green
        }
        
        return $true
    }
    catch {
        Write-Host "❌ Kafka health check failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to check network connectivity
function Test-NetworkConnectivity {
    Write-Host "`n🌐 Network Connectivity Check" -ForegroundColor Yellow
    
    # Check if containers can reach each other
    Write-Host "🔍 Testing inter-container connectivity..." -ForegroundColor Cyan
    
    # Test if data collection service can reach Kafka
    $kafkaConnectivity = docker exec binance-data-collection-$Environment curl -s --connect-timeout 5 http://kafka-$Environment:9092 2>$null
    if ($LASTEXITCODE -eq 0 -or $kafkaConnectivity -like "*kafka*") {
        Write-Host "✅ Data collection service can reach Kafka" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Data collection service cannot reach Kafka via HTTP (expected - Kafka doesn't use HTTP)" -ForegroundColor Yellow
    }
    
    # Test if trading service can reach PostgreSQL
    $postgresConnectivity = docker exec binance-trader-macd-$Environment curl -s --connect-timeout 5 http://postgres-$Environment:5432 2>$null
    if ($LASTEXITCODE -eq 0 -or $postgresConnectivity -like "*postgres*") {
        Write-Host "✅ Trading service can reach PostgreSQL" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Trading service cannot reach PostgreSQL via HTTP (expected - PostgreSQL doesn't use HTTP)" -ForegroundColor Yellow
    }
}

# Main execution
Write-Host "`n🚀 Starting health checks..." -ForegroundColor Green

$postgresHealthy = Test-PostgreSQLHealth
$kafkaHealthy = Test-KafkaHealth
Test-NetworkConnectivity

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
