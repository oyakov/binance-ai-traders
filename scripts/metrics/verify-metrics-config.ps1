# Verification script for metrics configuration
# This script checks the configuration files and code for proper metrics setup

Write-Host "=== Metrics Configuration Verification ===" -ForegroundColor Green
Write-Host ""

# Function to check file content
function Test-FileContent {
    param(
        [string]$FilePath,
        [string]$Description,
        [string[]]$RequiredPatterns,
        [string[]]$OptionalPatterns = @()
    )
    
    Write-Host "Checking $Description..." -ForegroundColor Cyan
    
    if (Test-Path $FilePath) {
        $content = Get-Content $FilePath -Raw
        $allFound = $true
        
        foreach ($pattern in $RequiredPatterns) {
            if ($content -match $pattern) {
                Write-Host "  ✓ Found: $pattern" -ForegroundColor Green
            } else {
                Write-Host "  ✗ Missing: $pattern" -ForegroundColor Red
                $allFound = $false
            }
        }
        
        foreach ($pattern in $OptionalPatterns) {
            if ($content -match $pattern) {
                Write-Host "  ✓ Found (optional): $pattern" -ForegroundColor Yellow
            } else {
                Write-Host "  - Not found (optional): $pattern" -ForegroundColor Gray
            }
        }
        
        return $allFound
    } else {
        Write-Host "  ✗ File not found: $FilePath" -ForegroundColor Red
        return $false
    }
}

# Check data collection service configuration
Write-Host ""
Write-Host "=== Data Collection Service ===" -ForegroundColor Yellow
$collectionConfig = Test-FileContent -FilePath "binance-data-collection/src/main/resources/application-testnet.yml" -Description "Collection Service Config" -RequiredPatterns @(
    "management:",
    "endpoints:",
    "web:",
    "exposure:",
    "include:.*prometheus",
    "metrics:",
    "export:",
    "prometheus:",
    "enabled: true"
)

# Check data storage service configuration
Write-Host ""
Write-Host "=== Data Storage Service ===" -ForegroundColor Yellow
$storageConfig = Test-FileContent -FilePath "binance-data-storage/src/main/resources/application-testnet.yml" -Description "Storage Service Config" -RequiredPatterns @(
    "management:",
    "endpoints:",
    "web:",
    "exposure:",
    "include:.*\*",
    "health:",
    "show-details: always"
)

# Check metrics classes
Write-Host ""
Write-Host "=== Metrics Classes ===" -ForegroundColor Yellow
$collectionMetrics = Test-FileContent -FilePath "binance-data-collection/src/main/java/com/oyakov/binance_data_collection/metrics/DataCollectionMetrics.java" -Description "Collection Metrics Class" -RequiredPatterns @(
    "@Component",
    "MeterRegistry",
    "Counter\.builder",
    "Timer\.builder",
    "Gauge\.builder",
    "binance_data_collection_"
)

$storageMetrics = Test-FileContent -FilePath "binance-data-storage/src/main/java/com/oyakov/binance_data_storage/metrics/DataStorageMetrics.java" -Description "Storage Metrics Class" -RequiredPatterns @(
    "@Component",
    "MeterRegistry",
    "Counter\.builder",
    "Timer\.builder",
    "Gauge\.builder",
    "binance_data_storage_"
)

# Check POM files for required dependencies
Write-Host ""
Write-Host "=== Dependencies ===" -ForegroundColor Yellow
$collectionPom = Test-FileContent -FilePath "binance-data-collection/pom.xml" -Description "Collection Service POM" -RequiredPatterns @(
    "spring-boot-starter-actuator",
    "micrometer-registry-prometheus"
)

$storagePom = Test-FileContent -FilePath "binance-data-storage/pom.xml" -Description "Storage Service POM" -RequiredPatterns @(
    "spring-boot-starter-actuator",
    "micrometer-registry-prometheus"
)

# Check Docker configuration
Write-Host ""
Write-Host "=== Docker Configuration ===" -ForegroundColor Yellow
$dockerCompose = Test-FileContent -FilePath "docker-compose-testnet.yml" -Description "Docker Compose" -RequiredPatterns @(
    "binance-data-collection-testnet:",
    "binance-data-storage-testnet:",
    "ports:",
    "8086:8080",
    "8087:8081",
    "healthcheck:",
    "actuator/health"
)

# Summary
Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Green
$allGood = $collectionConfig -and $storageConfig -and $collectionMetrics -and $storageMetrics -and $collectionPom -and $storagePom -and $dockerCompose

if ($allGood) {
    Write-Host "✓ All configurations look good!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Expected endpoints:" -ForegroundColor Yellow
    Write-Host "  Collection Service:" -ForegroundColor Cyan
    Write-Host "    - Health: http://localhost:8086/actuator/health" -ForegroundColor White
    Write-Host "    - Metrics: http://localhost:8086/actuator/metrics" -ForegroundColor White
    Write-Host "    - Prometheus: http://localhost:8086/actuator/prometheus" -ForegroundColor White
    Write-Host "    - Info: http://localhost:8086/actuator/info" -ForegroundColor White
    Write-Host "  Storage Service:" -ForegroundColor Cyan
    Write-Host "    - Health: http://localhost:8087/actuator/health" -ForegroundColor White
    Write-Host "    - Metrics: http://localhost:8087/actuator/metrics" -ForegroundColor White
    Write-Host "    - Prometheus: http://localhost:8087/actuator/prometheus" -ForegroundColor White
    Write-Host "    - Info: http://localhost:8087/actuator/info" -ForegroundColor White
} else {
    Write-Host "✗ Some configurations need attention!" -ForegroundColor Red
}

Write-Host ""
Write-Host "To test the services:" -ForegroundColor Yellow
Write-Host "1. Start Docker Desktop" -ForegroundColor Cyan
Write-Host "2. Run: .\test-collection-storage-metrics.ps1 -StartServices -TestMetrics" -ForegroundColor Cyan
Write-Host "3. Or manually: docker-compose -f docker-compose-testnet.yml up -d binance-data-collection-testnet binance-data-storage-testnet" -ForegroundColor Cyan