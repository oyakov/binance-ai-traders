# Health API Service for PostgreSQL and Kafka
# This script provides HTTP endpoints for health checking PostgreSQL and Kafka

param(
    [int]$Port = 8087,
    [string]$Environment = "testnet"
)

# Import required modules
Add-Type -AssemblyName System.Web

# Function to create HTTP response
function Send-HttpResponse {
    param(
        [int]$StatusCode,
        [string]$Content,
        [string]$ContentType = "application/json"
    )
    
    $response = "HTTP/1.1 $StatusCode $([System.Net.HttpStatusCode]::GetName($StatusCode))`r`n"
    $response += "Content-Type: $ContentType`r`n"
    $response += "Content-Length: $($Content.Length)`r`n"
    $response += "Access-Control-Allow-Origin: *`r`n"
    $response += "`r`n"
    $response += $Content
    
    return $response
}

# Function to check PostgreSQL health
function Test-PostgreSQLHealth {
    try {
        # Check if container is running
        $containerStatus = docker inspect postgres-$Environment --format "{{.State.Status}}" 2>$null
        if ($containerStatus -ne "running") {
            return @{
                status = "DOWN"
                message = "PostgreSQL container is not running"
                details = @{
                    container_status = $containerStatus
                    timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
                }
            }
        }
        
        # Check if PostgreSQL is accepting connections
        $pgReady = docker exec postgres-$Environment pg_isready -h localhost -p 5432 2>$null
        if ($LASTEXITCODE -ne 0) {
            return @{
                status = "DOWN"
                message = "PostgreSQL is not accepting connections"
                details = @{
                    container_status = $containerStatus
                    pg_isready = "FAILED"
                    timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
                }
            }
        }
        
        # Test database connection
        $dbTest = docker exec postgres-$Environment psql -U postgres -d postgres -c "SELECT 1 as test;" 2>$null
        $dbHealthy = $LASTEXITCODE -eq 0
        
        return @{
            status = if ($dbHealthy) { "UP" } else { "DEGRADED" }
            message = if ($dbHealthy) { "PostgreSQL is healthy" } else { "PostgreSQL is running but database connection test failed" }
            details = @{
                container_status = $containerStatus
                pg_isready = "PASSED"
                database_connection = if ($dbHealthy) { "PASSED" } else { "FAILED" }
                timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            }
        }
    }
    catch {
        return @{
            status = "DOWN"
            message = "PostgreSQL health check failed: $($_.Exception.Message)"
            details = @{
                error = $_.Exception.Message
                timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            }
        }
    }
}

# Function to check Kafka health
function Test-KafkaHealth {
    try {
        # Check if container is running
        $containerStatus = docker inspect kafka-$Environment --format "{{.State.Status}}" 2>$null
        if ($containerStatus -ne "running") {
            return @{
                status = "DOWN"
                message = "Kafka container is not running"
                details = @{
                    container_status = $containerStatus
                    timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
                }
            }
        }
        
        # Check if Kafka is listening on port 9092
        $portCheck = docker exec kafka-$Environment netstat -tlnp 2>$null | Select-String ":9092"
        if (-not $portCheck) {
            return @{
                status = "DOWN"
                message = "Kafka is not listening on port 9092"
                details = @{
                    container_status = $containerStatus
                    port_9092 = "NOT_LISTENING"
                    timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
                }
            }
        }
        
        # Try to list topics (this tests the full connection)
        $topics = docker exec kafka-$Environment kafka-topics --bootstrap-server kafka-$Environment:9092 --list --timeout-ms 5000 2>$null
        $topicsHealthy = $LASTEXITCODE -eq 0
        
        return @{
            status = if ($topicsHealthy) { "UP" } else { "DEGRADED" }
            message = if ($topicsHealthy) { "Kafka is healthy" } else { "Kafka is running but topic listing failed" }
            details = @{
                container_status = $containerStatus
                port_9092 = "LISTENING"
                topic_listing = if ($topicsHealthy) { "PASSED" } else { "FAILED" }
                available_topics = if ($topics) { $topics -split "`n" | Where-Object { $_.Trim() -ne "" } } else { @() }
                timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            }
        }
    }
    catch {
        return @{
            status = "DOWN"
            message = "Kafka health check failed: $($_.Exception.Message)"
            details = @{
                error = $_.Exception.Message
                timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            }
        }
    }
}

# Function to handle HTTP requests
function Handle-Request {
    param([string]$Path, [string]$Method)
    
    switch ($Path) {
        "/health" {
            $postgresHealth = Test-PostgreSQLHealth
            $kafkaHealth = Test-KafkaHealth
            
            $overallStatus = if ($postgresHealth.status -eq "UP" -and $kafkaHealth.status -eq "UP") { "UP" } else { "DOWN" }
            
            $response = @{
                status = $overallStatus
                timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
                services = @{
                    postgresql = $postgresHealth
                    kafka = $kafkaHealth
                }
            }
            
            $jsonResponse = $response | ConvertTo-Json -Depth 10
            return Send-HttpResponse -StatusCode 200 -Content $jsonResponse
        }
        
        "/health/postgresql" {
            $postgresHealth = Test-PostgreSQLHealth
            $jsonResponse = $postgresHealth | ConvertTo-Json -Depth 10
            $statusCode = if ($postgresHealth.status -eq "UP") { 200 } else { 503 }
            return Send-HttpResponse -StatusCode $statusCode -Content $jsonResponse
        }
        
        "/health/kafka" {
            $kafkaHealth = Test-KafkaHealth
            $jsonResponse = $kafkaHealth | ConvertTo-Json -Depth 10
            $statusCode = if ($kafkaHealth.status -eq "UP") { 200 } else { 503 }
            return Send-HttpResponse -StatusCode $statusCode -Content $jsonResponse
        }
        
        "/" {
            $response = @{
                service = "PostgreSQL and Kafka Health Check API"
                version = "1.0.0"
                environment = $Environment
                endpoints = @(
                    "GET /health - Overall health status"
                    "GET /health/postgresql - PostgreSQL health"
                    "GET /health/kafka - Kafka health"
                )
                timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            }
            $jsonResponse = $response | ConvertTo-Json -Depth 10
            return Send-HttpResponse -StatusCode 200 -Content $jsonResponse
        }
        
        default {
            $response = @{
                error = "Not Found"
                message = "The requested endpoint was not found"
                available_endpoints = @("/", "/health", "/health/postgresql", "/health/kafka")
            }
            $jsonResponse = $response | ConvertTo-Json -Depth 10
            return Send-HttpResponse -StatusCode 404 -Content $jsonResponse
        }
    }
}

# Start HTTP listener
Write-Host "🚀 Starting Health Check API Service on port $Port" -ForegroundColor Green
Write-Host "Environment: $Environment" -ForegroundColor Cyan
Write-Host "Available endpoints:" -ForegroundColor Yellow
Write-Host "  GET http://localhost:$Port/health - Overall health status" -ForegroundColor White
Write-Host "  GET http://localhost:$Port/health/postgresql - PostgreSQL health" -ForegroundColor White
Write-Host "  GET http://localhost:$Port/health/kafka - Kafka health" -ForegroundColor White
Write-Host "`nPress Ctrl+C to stop the service" -ForegroundColor Yellow

try {
    $listener = [System.Net.HttpListener]::new()
    $listener.Prefixes.Add("http://localhost:$Port/")
    $listener.Start()
    
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        Write-Host "📥 $($request.HttpMethod) $($request.Url.AbsolutePath)" -ForegroundColor Cyan
        
        $responseContent = Handle-Request -Path $request.Url.AbsolutePath -Method $request.HttpMethod
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($responseContent)
        
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
        $response.OutputStream.Close()
    }
}
catch {
    Write-Host "❌ Error starting HTTP listener: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    if ($listener) {
        $listener.Stop()
        $listener.Close()
    }
}
