# Simple HTTP Health Check Service
param([int]$Port = 8087)

Write-Host "Starting HTTP Health Check Service on port $Port" -ForegroundColor Green

# Function to check PostgreSQL
function Test-PostgreSQL {
    try {
        $pgStatus = docker inspect postgres-testnet --format "{{.State.Status}}" 2>$null
        if ($pgStatus -ne "running") {
            return @{ status = "DOWN"; message = "Container not running" }
        }
        
        $pgReady = docker exec postgres-testnet pg_isready -h localhost -p 5432 2>$null
        if ($LASTEXITCODE -eq 0) {
            return @{ status = "UP"; message = "PostgreSQL is healthy" }
        } else {
            return @{ status = "DOWN"; message = "Not accepting connections" }
        }
    } catch {
        return @{ status = "DOWN"; message = $_.Exception.Message }
    }
}

# Function to check Kafka
function Test-Kafka {
    try {
        $kafkaStatus = docker inspect kafka-testnet --format "{{.State.Status}}" 2>$null
        if ($kafkaStatus -ne "running") {
            return @{ status = "DOWN"; message = "Container not running" }
        }
        
        # Check if Kafka is processing consumer groups
        $consumerGroups = docker logs kafka-testnet --tail 20 2>$null | Select-String "GroupCoordinator"
        if ($consumerGroups) {
            return @{ status = "UP"; message = "Kafka is processing consumer groups" }
        } else {
            return @{ status = "DEGRADED"; message = "Container running but no activity detected" }
        }
    } catch {
        return @{ status = "DOWN"; message = $_.Exception.Message }
    }
}

# Start HTTP listener
try {
    $listener = [System.Net.HttpListener]::new()
    $listener.Prefixes.Add("http://localhost:$Port/")
    $listener.Start()
    
    Write-Host "Health API running at http://localhost:$Port" -ForegroundColor Green
    Write-Host "Endpoints:" -ForegroundColor Yellow
    Write-Host "  GET /health - Overall health" -ForegroundColor White
    Write-Host "  GET /health/postgresql - PostgreSQL health" -ForegroundColor White
    Write-Host "  GET /health/kafka - Kafka health" -ForegroundColor White
    Write-Host "`nPress Ctrl+C to stop" -ForegroundColor Yellow
    
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $path = $request.Url.AbsolutePath
        Write-Host "Request: $($request.HttpMethod) $path" -ForegroundColor Cyan
        
        $responseContent = ""
        $statusCode = 200
        
        switch ($path) {
            "/health" {
                $postgres = Test-PostgreSQL
                $kafka = Test-Kafka
                $overallStatus = if ($postgres.status -eq "UP" -and $kafka.status -eq "UP") { "UP" } else { "DOWN" }
                
                $responseContent = @{
                    status = $overallStatus
                    timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
                    services = @{
                        postgresql = $postgres
                        kafka = $kafka
                    }
                } | ConvertTo-Json -Depth 10
                
                if ($overallStatus -ne "UP") { $statusCode = 503 }
            }
            "/health/postgresql" {
                $postgres = Test-PostgreSQL
                $responseContent = $postgres | ConvertTo-Json -Depth 10
                if ($postgres.status -ne "UP") { $statusCode = 503 }
            }
            "/health/kafka" {
                $kafka = Test-Kafka
                $responseContent = $kafka | ConvertTo-Json -Depth 10
                if ($kafka.status -ne "UP") { $statusCode = 503 }
            }
            "/" {
                $responseContent = @{
                    service = "PostgreSQL and Kafka Health Check API"
                    version = "1.0.0"
                    endpoints = @("/", "/health", "/health/postgresql", "/health/kafka")
                    timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
                } | ConvertTo-Json -Depth 10
            }
            default {
                $responseContent = @{
                    error = "Not Found"
                    message = "Endpoint not found"
                    available_endpoints = @("/", "/health", "/health/postgresql", "/health/kafka")
                } | ConvertTo-Json -Depth 10
                $statusCode = 404
            }
        }
        
        $response.StatusCode = $statusCode
        $response.ContentType = "application/json"
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
