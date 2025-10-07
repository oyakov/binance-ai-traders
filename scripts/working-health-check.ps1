# Working PostgreSQL and Kafka Health Check
param([string]$Environment = "testnet")

Write-Host "PostgreSQL and Kafka Health Check - $Environment Environment" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Check PostgreSQL
Write-Host "`nTesting PostgreSQL..." -ForegroundColor Yellow
$postgresOK = $false
$postgresMessage = ""

try {
    $containerStatus = docker inspect postgres-$Environment --format "{{.State.Status}}" 2>$null
    if ($containerStatus -eq "running") {
        Write-Host "PostgreSQL container is running" -ForegroundColor Green
        $pgReady = docker exec postgres-$Environment pg_isready -h localhost -p 5432 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "PostgreSQL is accepting connections" -ForegroundColor Green
            $postgresOK = $true
            $postgresMessage = "PostgreSQL is healthy"
        } else {
            Write-Host "PostgreSQL is not accepting connections" -ForegroundColor Red
            $postgresMessage = "PostgreSQL is not accepting connections"
        }
    } else {
        Write-Host "PostgreSQL container is not running" -ForegroundColor Red
        $postgresMessage = "PostgreSQL container is not running"
    }
} catch {
    Write-Host "PostgreSQL health check failed: $($_.Exception.Message)" -ForegroundColor Red
    $postgresMessage = "PostgreSQL health check failed: $($_.Exception.Message)"
}

# Check Kafka
Write-Host "`nTesting Kafka..." -ForegroundColor Yellow
$kafkaOK = $false
$kafkaMessage = ""

try {
    $containerStatus = docker inspect kafka-$Environment --format "{{.State.Status}}" 2>$null
    if ($containerStatus -eq "running") {
        Write-Host "Kafka container is running" -ForegroundColor Green
        
        # Check if Kafka is processing consumer groups
        $consumerGroups = docker logs kafka-$Environment --tail 20 2>$null | Select-String "GroupCoordinator"
        if ($consumerGroups) {
            Write-Host "Kafka is processing consumer groups" -ForegroundColor Green
            $kafkaOK = $true
            $kafkaMessage = "Kafka is processing consumer groups"
        } else {
            # Check if data collection service is using Kafka
            $dataCollectionLogs = docker logs binance-data-collection-$Environment --tail 10 2>$null | Select-String "kafka"
            if ($dataCollectionLogs) {
                Write-Host "Data collection service is using Kafka" -ForegroundColor Green
                $kafkaOK = $true
                $kafkaMessage = "Kafka is being used by data collection service"
            } else {
                Write-Host "Kafka is running but no activity detected" -ForegroundColor Yellow
                $kafkaMessage = "Kafka is running but no activity detected"
            }
        }
    } else {
        Write-Host "Kafka container is not running" -ForegroundColor Red
        $kafkaMessage = "Kafka container is not running"
    }
} catch {
    Write-Host "Kafka health check failed: $($_.Exception.Message)" -ForegroundColor Red
    $kafkaMessage = "Kafka health check failed: $($_.Exception.Message)"
}

# Summary
Write-Host "`nSummary:" -ForegroundColor Cyan
Write-Host "PostgreSQL: $(if($postgresOK) {'OK'} else {'FAIL'}) - $postgresMessage" -ForegroundColor $(if($postgresOK) {'Green'} else {'Red'})
Write-Host "Kafka: $(if($kafkaOK) {'OK'} else {'FAIL'}) - $kafkaMessage" -ForegroundColor $(if($kafkaOK) {'Green'} else {'Red'})

$overallOK = $postgresOK -and $kafkaOK
if ($overallOK) {
    Write-Host "`nAll services are healthy!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`nSome services need attention!" -ForegroundColor Yellow
    exit 1
}
