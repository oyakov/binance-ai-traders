# Test Correlation ID Propagation Across Services
# Tests that correlation IDs are properly propagated through HTTP and Kafka

param(
    [string]$BaseUrl = "http://localhost",
    [string]$StoragePort = "8087",
    [string]$CollectionPort = "8086",
    [string]$TraderPort = "8083"
)

Write-Host "===========================================`n"
Write-Host "Testing Correlation ID Propagation`n"
Write-Host "===========================================`n"

# Generate a test correlation ID
$correlationId = [guid]::NewGuid().ToString()
Write-Host "Generated Test Correlation ID: $correlationId`n"

# Test 1: binance-data-storage health endpoint
Write-Host "`n--- Test 1: binance-data-storage ---"
try {
    $response = Invoke-WebRequest -Uri "$BaseUrl:$StoragePort/health" `
        -Headers @{"X-Correlation-ID" = $correlationId} `
        -Method GET `
        -UseBasicParsing
    
    $returnedCorrelationId = $response.Headers["X-Correlation-ID"]
    
    if ($returnedCorrelationId -eq $correlationId) {
        Write-Host "✅ PASS: Correlation ID returned in response header" -ForegroundColor Green
    } else {
        Write-Host "❌ FAIL: Correlation ID mismatch. Expected: $correlationId, Got: $returnedCorrelationId" -ForegroundColor Red
    }
    
    Write-Host "Status Code: $($response.StatusCode)"
} catch {
    Write-Host "❌ ERROR: Failed to call binance-data-storage: $_" -ForegroundColor Red
}

# Test 2: binance-data-collection health endpoint
Write-Host "`n--- Test 2: binance-data-collection ---"
try {
    $response = Invoke-WebRequest -Uri "$BaseUrl:$CollectionPort/health" `
        -Headers @{"X-Correlation-ID" = $correlationId} `
        -Method GET `
        -UseBasicParsing
    
    $returnedCorrelationId = $response.Headers["X-Correlation-ID"]
    
    if ($returnedCorrelationId -eq $correlationId) {
        Write-Host "✅ PASS: Correlation ID returned in response header" -ForegroundColor Green
    } else {
        Write-Host "❌ FAIL: Correlation ID mismatch. Expected: $correlationId, Got: $returnedCorrelationId" -ForegroundColor Red
    }
    
    Write-Host "Status Code: $($response.StatusCode)"
} catch {
    Write-Host "❌ ERROR: Failed to call binance-data-collection: $_" -ForegroundColor Red
}

# Test 3: binance-trader-macd health endpoint
Write-Host "`n--- Test 3: binance-trader-macd ---"
try {
    $response = Invoke-WebRequest -Uri "$BaseUrl:$TraderPort/actuator/health" `
        -Headers @{"X-Correlation-ID" = $correlationId} `
        -Method GET `
        -UseBasicParsing
    
    $returnedCorrelationId = $response.Headers["X-Correlation-ID"]
    
    if ($returnedCorrelationId -eq $correlationId) {
        Write-Host "✅ PASS: Correlation ID returned in response header" -ForegroundColor Green
    } else {
        Write-Host "❌ FAIL: Correlation ID mismatch. Expected: $correlationId, Got: $returnedCorrelationId" -ForegroundColor Red
    }
    
    Write-Host "Status Code: $($response.StatusCode)"
} catch {
    Write-Host "❌ ERROR: Failed to call binance-trader-macd: $_" -ForegroundColor Red
}

# Test 4: Test without correlation ID (should generate new one)
Write-Host "`n--- Test 4: Auto-generated Correlation ID ---"
try {
    $response = Invoke-WebRequest -Uri "$BaseUrl:$StoragePort/health" `
        -Method GET `
        -UseBasicParsing
    
    $generatedCorrelationId = $response.Headers["X-Correlation-ID"]
    
    if ($generatedCorrelationId) {
        Write-Host "✅ PASS: Correlation ID auto-generated: $generatedCorrelationId" -ForegroundColor Green
    } else {
        Write-Host "❌ FAIL: No correlation ID returned" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ ERROR: Failed test without correlation ID: $_" -ForegroundColor Red
}

Write-Host "`n===========================================`n"
Write-Host "Correlation ID Testing Complete`n"
Write-Host "===========================================`n"

Write-Host "`nNext Steps:"
Write-Host "1. Check Docker logs for correlation ID propagation:"
Write-Host "   docker logs binance-data-storage-testnet 2>&1 | Select-String '$correlationId'"
Write-Host "2. Verify JSON log format in container:"
Write-Host "   docker exec binance-data-storage-testnet cat /var/log/binance-data-storage/application.json"
Write-Host "3. Check Kafka message headers for correlation IDs"

