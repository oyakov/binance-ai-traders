# Test script for Binance Data Collection and Storage Services
# This script tests all metrics endpoints and service functionality

param(
    [string]$CollectionUrl = "http://localhost:8086",
    [string]$StorageUrl = "http://localhost:8087",
    [switch]$StartServices = $false,
    [switch]$StopServices = $false,
    [switch]$TestMetrics = $true,
    [switch]$TestHealth = $true,
    [switch]$TestEndpoints = $true
)

Write-Host "=== Binance Data Collection and Storage Services Test ===" -ForegroundColor Green
Write-Host "Collection Service URL: $CollectionUrl" -ForegroundColor Yellow
Write-Host "Storage Service URL: $StorageUrl" -ForegroundColor Yellow
Write-Host ""

# Function to test HTTP endpoint
function Test-HttpEndpoint {
    param(
        [string]$Url,
        [string]$ServiceName,
        [string]$ExpectedStatus = "200"
    )
    
    try {
        Write-Host "Testing $ServiceName endpoint: $Url" -ForegroundColor Cyan
        $response = Invoke-WebRequest -Uri $Url -Method GET -TimeoutSec 10
        Write-Host "✓ $ServiceName - Status: $($response.StatusCode)" -ForegroundColor Green
        
        if ($response.StatusCode -eq $ExpectedStatus) {
            return $true
        } else {
            Write-Host "✗ $ServiceName - Expected status $ExpectedStatus, got $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "✗ $ServiceName - Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to test metrics endpoint and parse metrics
function Test-MetricsEndpoint {
    param(
        [string]$Url,
        [string]$ServiceName
    )
    
    try {
        Write-Host "Testing $ServiceName metrics endpoint: $Url" -ForegroundColor Cyan
        $response = Invoke-WebRequest -Uri $Url -Method GET -TimeoutSec 10
        Write-Host "✓ $ServiceName metrics - Status: $($response.StatusCode)" -ForegroundColor Green
        
        $metrics = $response.Content
        Write-Host "Metrics content length: $($metrics.Length) characters" -ForegroundColor Yellow
        
        # Check for specific metrics patterns
        $metricPatterns = @(
            "binance_data_collection_",
            "binance_data_storage_",
            "jvm_",
            "http_",
            "kafka_",
            "hikaricp_",
            "postgres_",
            "elasticsearch_"
        )
        
        $foundMetrics = @()
        foreach ($pattern in $metricPatterns) {
            if ($metrics -match $pattern) {
                $foundMetrics += $pattern
            }
        }
        
        Write-Host "Found metric patterns: $($foundMetrics -join ', ')" -ForegroundColor Yellow
        
        # Count total metrics
        $metricCount = ($metrics -split "`n" | Where-Object { $_ -match "^[^#]" -and $_ -ne "" }).Count
        Write-Host "Total metrics found: $metricCount" -ForegroundColor Yellow
        
        return $true
    }
    catch {
        Write-Host "✗ $ServiceName metrics - Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to start services
function Start-Services {
    Write-Host "Starting services..." -ForegroundColor Green
    try {
        # Start the services using docker-compose
        docker-compose -f docker-compose-testnet.yml up -d binance-data-collection-testnet binance-data-storage-testnet
        
        Write-Host "Waiting for services to start..." -ForegroundColor Yellow
        Start-Sleep -Seconds 30
        
        # Check if services are running
        $collectionRunning = Test-HttpEndpoint -Url "$CollectionUrl/actuator/health" -ServiceName "Collection Health" -ExpectedStatus "200"
        $storageRunning = Test-HttpEndpoint -Url "$StorageUrl/actuator/health" -ServiceName "Storage Health" -ExpectedStatus "200"
        
        if ($collectionRunning -and $storageRunning) {
            Write-Host "✓ Both services started successfully" -ForegroundColor Green
            return $true
        } else {
            Write-Host "✗ Services failed to start properly" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "✗ Error starting services: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to stop services
function Stop-Services {
    Write-Host "Stopping services..." -ForegroundColor Green
    try {
        docker-compose -f docker-compose-testnet.yml stop binance-data-collection-testnet binance-data-storage-testnet
        Write-Host "✓ Services stopped" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "✗ Error stopping services: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Main execution
if ($StartServices) {
    $servicesStarted = Start-Services
    if (-not $servicesStarted) {
        Write-Host "Failed to start services. Exiting." -ForegroundColor Red
        exit 1
    }
}

if ($TestHealth) {
    Write-Host "`n=== Testing Health Endpoints ===" -ForegroundColor Green
    
    # Test collection service health
    $collectionHealth = Test-HttpEndpoint -Url "$CollectionUrl/actuator/health" -ServiceName "Collection Health"
    
    # Test storage service health
    $storageHealth = Test-HttpEndpoint -Url "$StorageUrl/actuator/health" -ServiceName "Storage Health"
    
    # Test detailed health endpoints
    $collectionHealthDetails = Test-HttpEndpoint -Url "$CollectionUrl/actuator/health/readiness" -ServiceName "Collection Readiness"
    $storageHealthDetails = Test-HttpEndpoint -Url "$StorageUrl/actuator/health/readiness" -ServiceName "Storage Readiness"
}

if ($TestMetrics) {
    Write-Host "`n=== Testing Metrics Endpoints ===" -ForegroundColor Green
    
    # Test collection service metrics
    $collectionMetrics = Test-MetricsEndpoint -Url "$CollectionUrl/actuator/prometheus" -ServiceName "Collection"
    
    # Test storage service metrics
    $storageMetrics = Test-MetricsEndpoint -Url "$StorageUrl/actuator/prometheus" -ServiceName "Storage"
    
    # Test general metrics endpoints
    $collectionGeneralMetrics = Test-HttpEndpoint -Url "$CollectionUrl/actuator/metrics" -ServiceName "Collection General Metrics"
    $storageGeneralMetrics = Test-HttpEndpoint -Url "$StorageUrl/actuator/metrics" -ServiceName "Storage General Metrics"
}

if ($TestEndpoints) {
    Write-Host "`n=== Testing Additional Endpoints ===" -ForegroundColor Green
    
    # Test info endpoints
    $collectionInfo = Test-HttpEndpoint -Url "$CollectionUrl/actuator/info" -ServiceName "Collection Info"
    $storageInfo = Test-HttpEndpoint -Url "$StorageUrl/actuator/info" -ServiceName "Storage Info"
    
    # Test specific metrics endpoints
    $collectionSpecificMetrics = @(
        "binance_data_collection_kline_events_received_total",
        "binance_data_collection_websocket_connections_established_total",
        "binance_data_collection_active_websocket_connections"
    )
    
    $storageSpecificMetrics = @(
        "binance_data_storage_kline_events_received_total",
        "binance_data_storage_kline_events_saved_total",
        "binance_data_storage_postgres_connection_status"
    )
    
    Write-Host "`nTesting specific collection metrics:" -ForegroundColor Yellow
    foreach ($metric in $collectionSpecificMetrics) {
        $metricUrl = "$CollectionUrl/actuator/metrics/$metric"
        Test-HttpEndpoint -Url $metricUrl -ServiceName "Collection Metric: $metric"
    }
    
    Write-Host "`nTesting specific storage metrics:" -ForegroundColor Yellow
    foreach ($metric in $storageSpecificMetrics) {
        $metricUrl = "$StorageUrl/actuator/metrics/$metric"
        Test-HttpEndpoint -Url $metricUrl -ServiceName "Storage Metric: $metric"
    }
}

if ($StopServices) {
    Stop-Services
}

Write-Host "`n=== Test Summary ===" -ForegroundColor Green
Write-Host "Collection Service: $CollectionUrl" -ForegroundColor Yellow
Write-Host "Storage Service: $StorageUrl" -ForegroundColor Yellow
Write-Host "`nTo start services: .\test-collection-storage-metrics.ps1 -StartServices" -ForegroundColor Cyan
Write-Host "To test metrics: .\test-collection-storage-metrics.ps1 -TestMetrics" -ForegroundColor Cyan
Write-Host "To stop services: .\test-collection-storage-metrics.ps1 -StopServices" -ForegroundColor Cyan
Write-Host "`nTest completed!" -ForegroundColor Green
