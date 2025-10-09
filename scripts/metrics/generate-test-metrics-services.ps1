# Generate Test Metrics
# This script makes API calls to generate some test metrics

Write-Host "=== Generating Test Metrics ===" -ForegroundColor Green
Write-Host ""

# Function to make API calls
function Invoke-ServiceCall {
    param(
        [string]$ServiceName,
        [string]$Url,
        [string]$Description
    )
    
    Write-Host "Testing $ServiceName..." -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Host "✓ $Description - Status: $($response.StatusCode)" -ForegroundColor Green
        } else {
            Write-Host "⚠ $Description - Status: $($response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "✗ $Description - Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test Collection Service
Write-Host "=== Testing Collection Service ===" -ForegroundColor Cyan
Invoke-ServiceCall -ServiceName "Collection" -Url "http://localhost:8086/actuator/health" -Description "Health Check"
Invoke-ServiceCall -ServiceName "Collection" -Url "http://localhost:8086/actuator/metrics" -Description "Metrics Endpoint"
Invoke-ServiceCall -ServiceName "Collection" -Url "http://localhost:8086/actuator/prometheus" -Description "Prometheus Metrics"

# Test Storage Service
Write-Host ""
Write-Host "=== Testing Storage Service ===" -ForegroundColor Cyan
Invoke-ServiceCall -ServiceName "Storage" -Url "http://localhost:8087/actuator/health" -Description "Health Check"
Invoke-ServiceCall -ServiceName "Storage" -Url "http://localhost:8087/actuator/metrics" -Description "Metrics Endpoint"
Invoke-ServiceCall -ServiceName "Storage" -Url "http://localhost:8087/actuator/prometheus" -Description "Prometheus Metrics"

# Test Prometheus
Write-Host ""
Write-Host "=== Testing Prometheus ===" -ForegroundColor Cyan
Invoke-ServiceCall -ServiceName "Prometheus" -Url "http://localhost:9091/api/v1/targets" -Description "Targets API"
Invoke-ServiceCall -ServiceName "Prometheus" -Url "http://localhost:9091/api/v1/label/__name__/values" -Description "Label Values API"

# Check for specific metrics
Write-Host ""
Write-Host "=== Checking for Specific Metrics ===" -ForegroundColor Cyan

# Check collection metrics
Write-Host "Checking collection service metrics..." -ForegroundColor Yellow
try {
    $collectionMetrics = Invoke-WebRequest -Uri "http://localhost:8086/actuator/prometheus" -UseBasicParsing
    $metrics = $collectionMetrics.Content
    
    $customMetrics = @(
        "binance_data_collection_kline_events_received_total",
        "binance_data_collection_kline_events_sent_kafka_total",
        "binance_data_collection_websocket_connections_established_total",
        "binance_data_collection_active_websocket_connections"
    )
    
    foreach ($metric in $customMetrics) {
        if ($metrics -match $metric) {
            Write-Host "✓ Found: $metric" -ForegroundColor Green
        } else {
            Write-Host "✗ Missing: $metric" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "✗ Failed to check collection metrics: $($_.Exception.Message)" -ForegroundColor Red
}

# Check storage metrics
Write-Host "Checking storage service metrics..." -ForegroundColor Yellow
try {
    $storageMetrics = Invoke-WebRequest -Uri "http://localhost:8087/actuator/prometheus" -UseBasicParsing
    $metrics = $storageMetrics.Content
    
    $customMetrics = @(
        "binance_data_storage_kline_events_received_total",
        "binance_data_storage_kline_events_saved_total",
        "binance_data_storage_postgres_connection_status",
        "binance_data_storage_elasticsearch_connection_status"
    )
    
    foreach ($metric in $customMetrics) {
        if ($metrics -match $metric) {
            Write-Host "✓ Found: $metric" -ForegroundColor Green
        } else {
            Write-Host "✗ Missing: $metric" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "✗ Failed to check storage metrics: $($_.Exception.Message)" -ForegroundColor Red
}

# Generate some test data by making multiple calls
Write-Host ""
Write-Host "=== Generating Test Data ===" -ForegroundColor Cyan
Write-Host "Making multiple API calls to generate metrics..." -ForegroundColor Yellow

for ($i = 1; $i -le 10; $i++) {
    Write-Host "Call $i/10..." -NoNewline
    try {
        # Make calls to both services
        $null = Invoke-WebRequest -Uri "http://localhost:8086/actuator/health" -UseBasicParsing -TimeoutSec 5
        $null = Invoke-WebRequest -Uri "http://localhost:8087/actuator/health" -UseBasicParsing -TimeoutSec 5
        Write-Host " ✓" -ForegroundColor Green
    } catch {
        Write-Host " ✗" -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 500
}

Write-Host ""
Write-Host "=== Test Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Now check your Grafana dashboard at:" -ForegroundColor Cyan
Write-Host "http://localhost:3001/d/binance-comprehensive-metrics/binance-ai-traders-comprehensive-metrics-dashboard" -ForegroundColor White
Write-Host ""
Write-Host "Or check Prometheus directly at:" -ForegroundColor Cyan
Write-Host "http://localhost:9091" -ForegroundColor White
Write-Host ""
Write-Host "If you still see 'No data', the services might not be actively processing real data." -ForegroundColor Yellow
Write-Host "The metrics will only show data when the services are actually processing kline events." -ForegroundColor Yellow
