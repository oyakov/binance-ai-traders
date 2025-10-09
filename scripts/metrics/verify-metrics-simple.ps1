# Simple verification script for metrics configuration

Write-Host "=== Metrics Configuration Verification ===" -ForegroundColor Green
Write-Host ""

# Check data collection service configuration
Write-Host "=== Data Collection Service ===" -ForegroundColor Yellow
if (Test-Path "binance-data-collection/src/main/resources/application-testnet.yml") {
    $content = Get-Content "binance-data-collection/src/main/resources/application-testnet.yml" -Raw
    if ($content -match "management:" -and $content -match "prometheus" -and $content -match "enabled: true") {
        Write-Host "  ✓ Collection service config looks good" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Collection service config missing required settings" -ForegroundColor Red
    }
} else {
    Write-Host "  ✗ Collection service config file not found" -ForegroundColor Red
}

# Check data storage service configuration
Write-Host ""
Write-Host "=== Data Storage Service ===" -ForegroundColor Yellow
if (Test-Path "binance-data-storage/src/main/resources/application-testnet.yml") {
    $content = Get-Content "binance-data-storage/src/main/resources/application-testnet.yml" -Raw
    if ($content -match "management:" -and $content -match "include:.*\*") {
        Write-Host "  ✓ Storage service config looks good" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Storage service config missing required settings" -ForegroundColor Red
    }
} else {
    Write-Host "  ✗ Storage service config file not found" -ForegroundColor Red
}

# Check metrics classes
Write-Host ""
Write-Host "=== Metrics Classes ===" -ForegroundColor Yellow
if (Test-Path "binance-data-collection/src/main/java/com/oyakov/binance_data_collection/metrics/DataCollectionMetrics.java") {
    Write-Host "  ✓ Collection metrics class found" -ForegroundColor Green
} else {
    Write-Host "  ✗ Collection metrics class not found" -ForegroundColor Red
}

if (Test-Path "binance-data-storage/src/main/java/com/oyakov/binance_data_storage/metrics/DataStorageMetrics.java") {
    Write-Host "  ✓ Storage metrics class found" -ForegroundColor Green
} else {
    Write-Host "  ✗ Storage metrics class not found" -ForegroundColor Red
}

# Check POM files
Write-Host ""
Write-Host "=== Dependencies ===" -ForegroundColor Yellow
if (Test-Path "binance-data-collection/pom.xml") {
    $content = Get-Content "binance-data-collection/pom.xml" -Raw
    if ($content -match "spring-boot-starter-actuator" -and $content -match "micrometer-registry-prometheus") {
        Write-Host "  ✓ Collection service dependencies look good" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Collection service missing required dependencies" -ForegroundColor Red
    }
} else {
    Write-Host "  ✗ Collection service POM not found" -ForegroundColor Red
}

if (Test-Path "binance-data-storage/pom.xml") {
    $content = Get-Content "binance-data-storage/pom.xml" -Raw
    if ($content -match "spring-boot-starter-actuator" -and $content -match "micrometer-registry-prometheus") {
        Write-Host "  ✓ Storage service dependencies look good" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Storage service missing required dependencies" -ForegroundColor Red
    }
} else {
    Write-Host "  ✗ Storage service POM not found" -ForegroundColor Red
}

# Check Docker configuration
Write-Host ""
Write-Host "=== Docker Configuration ===" -ForegroundColor Yellow
if (Test-Path "docker-compose-testnet.yml") {
    $content = Get-Content "docker-compose-testnet.yml" -Raw
    if ($content -match "binance-data-collection-testnet" -and $content -match "binance-data-storage-testnet" -and $content -match "8086:8080" -and $content -match "8087:8081") {
        Write-Host "  ✓ Docker configuration looks good" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Docker configuration missing required settings" -ForegroundColor Red
    }
} else {
    Write-Host "  ✗ Docker compose file not found" -ForegroundColor Red
}

# Summary
Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Green
Write-Host "Expected endpoints:" -ForegroundColor Yellow
Write-Host "  Collection Service: http://localhost:8086" -ForegroundColor Cyan
Write-Host "    - Health: /actuator/health" -ForegroundColor White
Write-Host "    - Metrics: /actuator/metrics" -ForegroundColor White
Write-Host "    - Prometheus: /actuator/prometheus" -ForegroundColor White
Write-Host "    - Info: /actuator/info" -ForegroundColor White
Write-Host "  Storage Service: http://localhost:8087" -ForegroundColor Cyan
Write-Host "    - Health: /actuator/health" -ForegroundColor White
Write-Host "    - Metrics: /actuator/metrics" -ForegroundColor White
Write-Host "    - Prometheus: /actuator/prometheus" -ForegroundColor White
Write-Host "    - Info: /actuator/info" -ForegroundColor White

Write-Host ""
Write-Host "To test the services:" -ForegroundColor Yellow
Write-Host "1. Start Docker Desktop" -ForegroundColor Cyan
Write-Host "2. Run: docker-compose -f docker-compose-testnet.yml up -d binance-data-collection-testnet binance-data-storage-testnet" -ForegroundColor Cyan
Write-Host "3. Test endpoints with: .\test-collection-storage-metrics.ps1 -TestMetrics" -ForegroundColor Cyan
