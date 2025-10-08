Write-Host "=== Metrics Configuration Check ===" -ForegroundColor Green

# Check collection service config
Write-Host "Checking collection service config..." -ForegroundColor Yellow
if (Test-Path "binance-data-collection/src/main/resources/application-testnet.yml") {
    $content = Get-Content "binance-data-collection/src/main/resources/application-testnet.yml" -Raw
    if ($content -match "prometheus" -and $content -match "enabled: true") {
        Write-Host "  Collection service config: OK" -ForegroundColor Green
    } else {
        Write-Host "  Collection service config: MISSING PROMETHEUS" -ForegroundColor Red
    }
} else {
    Write-Host "  Collection service config: FILE NOT FOUND" -ForegroundColor Red
}

# Check storage service config
Write-Host "Checking storage service config..." -ForegroundColor Yellow
if (Test-Path "binance-data-storage/src/main/resources/application-testnet.yml") {
    $content = Get-Content "binance-data-storage/src/main/resources/application-testnet.yml" -Raw
    if ($content -match "management:" -and $content -match "include:") {
        Write-Host "  Storage service config: OK" -ForegroundColor Green
    } else {
        Write-Host "  Storage service config: MISSING MANAGEMENT" -ForegroundColor Red
    }
} else {
    Write-Host "  Storage service config: FILE NOT FOUND" -ForegroundColor Red
}

# Check metrics classes
Write-Host "Checking metrics classes..." -ForegroundColor Yellow
if (Test-Path "binance-data-collection/src/main/java/com/oyakov/binance_data_collection/metrics/DataCollectionMetrics.java") {
    Write-Host "  Collection metrics class: FOUND" -ForegroundColor Green
} else {
    Write-Host "  Collection metrics class: NOT FOUND" -ForegroundColor Red
}

if (Test-Path "binance-data-storage/src/main/java/com/oyakov/binance_data_storage/metrics/DataStorageMetrics.java") {
    Write-Host "  Storage metrics class: FOUND" -ForegroundColor Green
} else {
    Write-Host "  Storage metrics class: NOT FOUND" -ForegroundColor Red
}

# Check dependencies
Write-Host "Checking dependencies..." -ForegroundColor Yellow
if (Test-Path "binance-data-collection/pom.xml") {
    $content = Get-Content "binance-data-collection/pom.xml" -Raw
    if ($content -match "spring-boot-starter-actuator" -and $content -match "micrometer-registry-prometheus") {
        Write-Host "  Collection dependencies: OK" -ForegroundColor Green
    } else {
        Write-Host "  Collection dependencies: MISSING" -ForegroundColor Red
    }
} else {
    Write-Host "  Collection POM: NOT FOUND" -ForegroundColor Red
}

if (Test-Path "binance-data-storage/pom.xml") {
    $content = Get-Content "binance-data-storage/pom.xml" -Raw
    if ($content -match "spring-boot-starter-actuator" -and $content -match "micrometer-registry-prometheus") {
        Write-Host "  Storage dependencies: OK" -ForegroundColor Green
    } else {
        Write-Host "  Storage dependencies: MISSING" -ForegroundColor Red
    }
} else {
    Write-Host "  Storage POM: NOT FOUND" -ForegroundColor Red
}

Write-Host ""
Write-Host "Expected endpoints:" -ForegroundColor Yellow
Write-Host "Collection Service: http://localhost:8086" -ForegroundColor Cyan
Write-Host "  /actuator/health" -ForegroundColor White
Write-Host "  /actuator/metrics" -ForegroundColor White
Write-Host "  /actuator/prometheus" -ForegroundColor White
Write-Host "  /actuator/info" -ForegroundColor White
Write-Host "Storage Service: http://localhost:8087" -ForegroundColor Cyan
Write-Host "  /actuator/health" -ForegroundColor White
Write-Host "  /actuator/metrics" -ForegroundColor White
Write-Host "  /actuator/prometheus" -ForegroundColor White
Write-Host "  /actuator/info" -ForegroundColor White
