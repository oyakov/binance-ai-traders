# Simple Health Metrics Exporter - Reliable Version
param(
    [int]$Port = 8090,
    [string]$Environment = "testnet"
)

Write-Host "Starting Simple Health Metrics Exporter on port $Port" -ForegroundColor Green

# Function to get basic health metrics
function Get-BasicHealthMetrics {
    $metrics = @()
    
    # PostgreSQL
    try {
        $pgStatus = docker inspect postgres-$Environment --format "{{.State.Status}}" 2>$null
        $pgUp = if ($pgStatus -eq "running") { 1 } else { 0 }
        
        $pgReady = docker exec postgres-$Environment pg_isready -h localhost -p 5432 2>$null
        $pgReadyValue = if ($LASTEXITCODE -eq 0) { 1 } else { 0 }
        
        $metrics += "postgres_container_up{environment=`"$Environment`"} $pgUp"
        $metrics += "postgres_ready{environment=`"$Environment`"} $pgReadyValue"
    } catch {
        $metrics += "postgres_container_up{environment=`"$Environment`"} 0"
        $metrics += "postgres_ready{environment=`"$Environment`"} 0"
    }
    
    # Kafka
    try {
        $kafkaStatus = docker inspect kafka-$Environment --format "{{.State.Status}}" 2>$null
        $kafkaUp = if ($kafkaStatus -eq "running") { 1 } else { 0 }
        
        $consumerGroups = docker logs kafka-$Environment --tail 20 2>$null | Select-String "GroupCoordinator"
        $kafkaActive = if ($consumerGroups) { 1 } else { 0 }
        
        $metrics += "kafka_container_up{environment=`"$Environment`"} $kafkaUp"
        $metrics += "kafka_active{environment=`"$Environment`"} $kafkaActive"
    } catch {
        $metrics += "kafka_container_up{environment=`"$Environment`"} 0"
        $metrics += "kafka_active{environment=`"$Environment`"} 0"
    }
    
    # Elasticsearch
    try {
        $esStatus = docker inspect elasticsearch-$Environment --format "{{.State.Status}}" 2>$null
        $esUp = if ($esStatus -eq "running") { 1 } else { 0 }
        
        $esHealth = Invoke-WebRequest -Uri "http://localhost:9202/_cluster/health" -TimeoutSec 5 2>$null
        $esHealthy = if ($esHealth.StatusCode -eq 200) { 1 } else { 0 }
        
        $metrics += "elasticsearch_container_up{environment=`"$Environment`"} $esUp"
        $metrics += "elasticsearch_healthy{environment=`"$Environment`"} $esHealthy"
    } catch {
        $metrics += "elasticsearch_container_up{environment=`"$Environment`"} 0"
        $metrics += "elasticsearch_healthy{environment=`"$Environment`"} 0"
    }
    
    # Trading Service
    try {
        $tradingHealth = Invoke-WebRequest -Uri "http://localhost:8083/actuator/health" -TimeoutSec 5 2>$null
        $tradingUp = if ($tradingHealth.StatusCode -eq 200) { 1 } else { 0 }
        $metrics += "trading_service_up{environment=`"$Environment`"} $tradingUp"
    } catch {
        $metrics += "trading_service_up{environment=`"$Environment`"} 0"
    }
    
    # Data Collection Service
    try {
        $dataCollectionHealth = Invoke-WebRequest -Uri "http://localhost:8086/actuator/health" -TimeoutSec 5 2>$null
        $dataCollectionUp = if ($dataCollectionHealth.StatusCode -eq 200) { 1 } else { 0 }
        $metrics += "data_collection_service_up{environment=`"$Environment`"} $dataCollectionUp"
    } catch {
        $metrics += "data_collection_service_up{environment=`"$Environment`"} 0"
    }
    
    return $metrics
}

# Start HTTP listener
try {
    $listener = [System.Net.HttpListener]::new()
    $listener.Prefixes.Add("http://localhost:$Port/")
    $listener.Start()
    
    Write-Host "Simple Health Metrics Exporter running at http://localhost:$Port" -ForegroundColor Green
    Write-Host "Endpoints:" -ForegroundColor Yellow
    Write-Host "  GET /metrics - Prometheus metrics" -ForegroundColor White
    Write-Host "  GET /health - Health check" -ForegroundColor White
    Write-Host "`nPress Ctrl+C to stop" -ForegroundColor Yellow
    
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $path = $request.Url.AbsolutePath
        Write-Host "Request: $($request.HttpMethod) $path" -ForegroundColor Cyan
        
        $responseContent = ""
        $statusCode = 200
        $contentType = "text/plain"
        
        switch ($path) {
            "/metrics" {
                $metrics = Get-BasicHealthMetrics
                $responseContent = $metrics -join "`n"
                $contentType = "text/plain; version=0.0.4; charset=utf-8"
            }
            "/health" {
                $metrics = Get-BasicHealthMetrics
                $overallUp = ($metrics | Select-String "_up.*1").Count
                $totalServices = ($metrics | Select-String "_up").Count
                $overallHealth = if ($overallUp -eq $totalServices) { "UP" } else { "DEGRADED" }
                
                $responseContent = @{
                    status = $overallHealth
                    timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
                    services_up = $overallUp
                    total_services = $totalServices
                } | ConvertTo-Json -Depth 10
                $contentType = "application/json"
                
                if ($overallHealth -ne "UP") { $statusCode = 503 }
            }
            "/" {
                $responseContent = @{
                    service = "Simple Health Metrics Exporter"
                    version = "1.0.0"
                    environment = $Environment
                    endpoints = @("/", "/metrics", "/health")
                    timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
                } | ConvertTo-Json -Depth 10
                $contentType = "application/json"
            }
            default {
                $responseContent = @{
                    error = "Not Found"
                    message = "Endpoint not found"
                    available_endpoints = @("/", "/metrics", "/health")
                } | ConvertTo-Json -Depth 10
                $contentType = "application/json"
                $statusCode = 404
            }
        }
        
        $response.StatusCode = $statusCode
        $response.ContentType = $contentType
        $response.Headers.Add("Access-Control-Allow-Origin", "*")
        
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($responseContent)
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
        $response.OutputStream.Close()
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    if ($listener) {
        $listener.Stop()
        $listener.Close()
    }
}
