# Final PostgreSQL and Kafka Health Check Solution
param([string]$Environment = "testnet")

Write-Host "PostgreSQL and Kafka Health Check - $Environment Environment" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Function to check PostgreSQL health
function Test-PostgreSQLHealth {
    Write-Host "`nTesting PostgreSQL..." -ForegroundColor Yellow
    
    try {
        # Check container status
        $containerStatus = docker inspect postgres-$Environment --format "{{.State.Status}}" 2>$null
        if ($containerStatus -ne "running") {
            Write-Host "❌ PostgreSQL container is not running (Status: $containerStatus)" -ForegroundColor Red
            return @{ status = "DOWN"; message = "Container not running"; details = @{ container_status = $containerStatus } }
        }
        
        Write-Host "✅ PostgreSQL container is running" -ForegroundColor Green
        
        # Check if PostgreSQL is accepting connections
        $pgReady = docker exec postgres-$Environment pg_isready -h localhost -p 5432 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ PostgreSQL is accepting connections" -ForegroundColor Green
            
            # Test database connection with actual credentials
            $dbTest = docker exec postgres-$Environment psql -U testnet_user -d binance_trader_testnet -c "SELECT 1 as test;" 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ PostgreSQL database connection test successful" -ForegroundColor Green
                return @{ status = "UP"; message = "PostgreSQL is healthy"; details = @{ container_status = $containerStatus; pg_isready = "PASSED"; database_connection = "PASSED" } }
            } else {
                Write-Host "⚠️  PostgreSQL database connection test failed" -ForegroundColor Yellow
                return @{ status = "DEGRADED"; message = "PostgreSQL is running but database connection failed"; details = @{ container_status = $containerStatus; pg_isready = "PASSED"; database_connection = "FAILED" } }
            }
        } else {
            Write-Host "❌ PostgreSQL is not accepting connections" -ForegroundColor Red
            return @{ status = "DOWN"; message = "PostgreSQL is not accepting connections"; details = @{ container_status = $containerStatus; pg_isready = "FAILED" } }
        }
    } catch {
        Write-Host "❌ PostgreSQL health check failed: $($_.Exception.Message)" -ForegroundColor Red
        return @{ status = "DOWN"; message = "PostgreSQL health check failed: $($_.Exception.Message)"; details = @{ error = $_.Exception.Message } }
    }
}

# Function to check Kafka health
function Test-KafkaHealth {
    Write-Host "`nTesting Kafka..." -ForegroundColor Yellow
    
    try {
        # Check container status
        $containerStatus = docker inspect kafka-$Environment --format "{{.State.Status}}" 2>$null
        if ($containerStatus -ne "running") {
            Write-Host "❌ Kafka container is not running (Status: $containerStatus)" -ForegroundColor Red
            return @{ status = "DOWN"; message = "Container not running"; details = @{ container_status = $containerStatus } }
        }
        
        Write-Host "✅ Kafka container is running" -ForegroundColor Green
        
        # Check if Kafka is processing consumer groups (indicates it's working)
        $consumerGroups = docker logs kafka-$Environment --tail 20 2>$null | Select-String "GroupCoordinator"
        if ($consumerGroups) {
            Write-Host "✅ Kafka is processing consumer groups (indicates it's working)" -ForegroundColor Green
            return @{ status = "UP"; message = "Kafka is processing consumer groups"; details = @{ container_status = $containerStatus; consumer_groups = "ACTIVE" } }
        }
        
        # Check if data collection service is using Kafka
        $dataCollectionLogs = docker logs binance-data-collection-$Environment --tail 10 2>$null | Select-String "kafka"
        if ($dataCollectionLogs) {
            Write-Host "✅ Data collection service is using Kafka" -ForegroundColor Green
            return @{ status = "UP"; message = "Kafka is being used by data collection service"; details = @{ container_status = $containerStatus; data_collection_usage = "ACTIVE" } }
        }
        
        # Try to create a test topic
        Write-Host "🔍 Trying to create test topic..." -ForegroundColor Cyan
        $createTopic = docker exec kafka-$Environment kafka-topics --bootstrap-server kafka-$Environment:29092 --create --topic health-check-test --partitions 1 --replication-factor 1 --if-not-exists 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Kafka topic creation successful" -ForegroundColor Green
            # Clean up test topic
            docker exec kafka-$Environment kafka-topics --bootstrap-server kafka-$Environment:29092 --delete --topic health-check-test 2>$null | Out-Null
            return @{ status = "UP"; message = "Kafka topic creation successful"; details = @{ container_status = $containerStatus; topic_creation = "PASSED" } }
        } else {
            Write-Host "⚠️  Kafka topic creation failed" -ForegroundColor Yellow
            return @{ status = "DEGRADED"; message = "Kafka is running but topic creation failed"; details = @{ container_status = $containerStatus; topic_creation = "FAILED" } }
        }
    } catch {
        Write-Host "❌ Kafka health check failed: $($_.Exception.Message)" -ForegroundColor Red
        return @{ status = "DOWN"; message = "Kafka health check failed: $($_.Exception.Message)"; details = @{ error = $_.Exception.Message } }
    }
}

# Main execution
Write-Host "`n🚀 Starting health checks..." -ForegroundColor Green

$postgresHealth = Test-PostgreSQLHealth
$kafkaHealth = Test-KafkaHealth

# Summary
Write-Host "`n📊 Health Check Summary" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan

Write-Host "PostgreSQL: $($postgresHealth.status) - $($postgresHealth.message)" -ForegroundColor $(if($postgresHealth.status -eq "UP") {"Green"} elseif($postgresHealth.status -eq "DEGRADED") {"Yellow"} else {"Red"})
Write-Host "Kafka: $($kafkaHealth.status) - $($kafkaHealth.message)" -ForegroundColor $(if($kafkaHealth.status -eq "UP") {"Green"} elseif($kafkaHealth.status -eq "DEGRADED") {"Yellow"} else {"Red"})

# Overall status
$overallStatus = if ($postgresHealth.status -eq "UP" -and $kafkaHealth.status -eq "UP") { "UP" } else { "DEGRADED" }

Write-Host "`nOverall Status: $overallStatus" -ForegroundColor $(if($overallStatus -eq "UP") {"Green"} else {"Yellow"})

# Return JSON for programmatic use
$result = @{
    status = $overallStatus
    timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
    services = @{
        postgresql = $postgresHealth
        kafka = $kafkaHealth
    }
}

Write-Host "`nJSON Result:" -ForegroundColor Cyan
$result | ConvertTo-Json -Depth 10

# Exit with appropriate code
if ($overallStatus -eq "UP") {
    Write-Host "`n🎉 All services are healthy!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n⚠️  Some services need attention!" -ForegroundColor Yellow
    exit 1
}
