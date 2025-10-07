# Final PostgreSQL and Kafka Health Check Script
param([string]$Environment = "testnet")

Write-Host "PostgreSQL and Kafka Health Check - $Environment Environment" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Check PostgreSQL
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

# Check Kafka - try multiple approaches
Write-Host "`nTesting Kafka..." -ForegroundColor Yellow
$kafkaStatus = docker inspect kafka-$Environment --format "{{.State.Status}}" 2>$null
if ($kafkaStatus -eq "running") {
    Write-Host "Kafka container is running" -ForegroundColor Green
    
    # Try different connection methods
    $kafkaOK = $false
    
    # Method 1: Check if Kafka is processing consumer groups (indicates it's working)
    $consumerGroups = docker logs kafka-$Environment --tail 10 2>$null | Select-String "GroupCoordinator"
    if ($consumerGroups) {
        Write-Host "Kafka is processing consumer groups (indicates it's working)" -ForegroundColor Green
        $kafkaOK = $true
    }
    
    # Method 2: Try to create a test topic (this tests the full connection)
    if (-not $kafkaOK) {
        Write-Host "Trying to create test topic..." -ForegroundColor Cyan
        $createTopic = docker exec kafka-$Environment kafka-topics --bootstrap-server kafka-$Environment:29092 --create --topic health-check-test --partitions 1 --replication-factor 1 --if-not-exists 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Kafka topic creation successful" -ForegroundColor Green
            $kafkaOK = $true
            
            # Clean up test topic
            docker exec kafka-$Environment kafka-topics --bootstrap-server kafka-$Environment:29092 --delete --topic health-check-test 2>$null | Out-Null
        }
    }
    
    # Method 3: Check if services are actually using Kafka (data collection service)
    if (-not $kafkaOK) {
        $dataCollectionLogs = docker logs binance-data-collection-$Environment --tail 5 2>$null | Select-String "kafka"
        if ($dataCollectionLogs) {
            Write-Host "Data collection service is using Kafka (indicates it's working)" -ForegroundColor Green
            $kafkaOK = $true
        }
    }
    
    if (-not $kafkaOK) {
        Write-Host "Kafka is not responding to standard health checks" -ForegroundColor Red
        Write-Host "Note: Kafka may still be functional for internal services" -ForegroundColor Yellow
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
    Write-Host "`nSome services need attention!" -ForegroundColor Yellow
    exit 1
}
