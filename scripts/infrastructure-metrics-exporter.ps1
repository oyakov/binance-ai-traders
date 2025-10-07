# Infrastructure Metrics Exporter for PostgreSQL, Kafka, and Elasticsearch
# This script exposes metrics in Prometheus format for infrastructure services

param(
    [int]$Port = 8088,
    [string]$Environment = "testnet"
)

Write-Host "Starting Infrastructure Metrics Exporter on port $Port" -ForegroundColor Green

# Function to check PostgreSQL metrics
function Get-PostgreSQLMetrics {
    try {
        $containerStatus = docker inspect postgres-$Environment --format "{{.State.Status}}" 2>$null
        $isRunning = $containerStatus -eq "running"
        
        $pgReady = docker exec postgres-$Environment pg_isready -h localhost -p 5432 2>$null
        $isReady = $LASTEXITCODE -eq 0
        
        # Get database size
        $dbSize = docker exec postgres-$Environment psql -U testnet_user -d binance_trader_testnet -t -c "SELECT pg_database_size('binance_trader_testnet');" 2>$null
        $dbSizeBytes = if ($dbSize) { [int64]$dbSize.Trim() } else { 0 }
        
        return @{
            postgres_container_up = if ($isRunning) { 1 } else { 0 }
            postgres_ready = if ($isReady) { 1 } else { 0 }
            postgres_database_size_bytes = $dbSizeBytes
        }
    } catch {
        return @{
            postgres_container_up = 0
            postgres_ready = 0
            postgres_database_size_bytes = 0
        }
    }
}

# Function to check Kafka metrics
function Get-KafkaMetrics {
    try {
        $containerStatus = docker inspect kafka-$Environment --format "{{.State.Status}}" 2>$null
        $isRunning = $containerStatus -eq "running"
        
        # Check if Kafka is processing consumer groups
        $consumerGroups = docker logs kafka-$Environment --tail 20 2>$null | Select-String "GroupCoordinator"
        $isActive = $consumerGroups -ne $null
        
        # Check if data collection service is using Kafka
        $dataCollectionLogs = docker logs binance-data-collection-$Environment --tail 10 2>$null | Select-String "kafka"
        $isUsed = $dataCollectionLogs -ne $null
        
        return @{
            kafka_container_up = if ($isRunning) { 1 } else { 0 }
            kafka_consumer_groups_active = if ($isActive) { 1 } else { 0 }
            kafka_being_used = if ($isUsed) { 1 } else { 0 }
        }
    } catch {
        return @{
            kafka_container_up = 0
            kafka_consumer_groups_active = 0
            kafka_being_used = 0
        }
    }
}

# Function to check Elasticsearch metrics
function Get-ElasticsearchMetrics {
    try {
        $containerStatus = docker inspect elasticsearch-$Environment --format "{{.State.Status}}" 2>$null
        $isRunning = $containerStatus -eq "running"
        
        # Check cluster health
        $clusterHealth = Invoke-WebRequest -Uri "http://localhost:9202/_cluster/health" -TimeoutSec 5 2>$null
        $isHealthy = $clusterHealth.StatusCode -eq 200
        
        # Get cluster stats
        $clusterStats = Invoke-WebRequest -Uri "http://localhost:9202/_cluster/stats" -TimeoutSec 5 2>$null
        $statsData = if ($clusterStats.StatusCode -eq 200) { $clusterStats.Content | ConvertFrom-Json } else { $null }
        
        $nodeCount = if ($statsData) { $statsData.nodes.count.total } else { 0 }
        $indicesCount = if ($statsData) { $statsData.indices.count } else { 0 }
        
        return @{
            elasticsearch_container_up = if ($isRunning) { 1 } else { 0 }
            elasticsearch_cluster_healthy = if ($isHealthy) { 1 } else { 0 }
            elasticsearch_nodes_count = $nodeCount
            elasticsearch_indices_count = $indicesCount
        }
    } catch {
        return @{
            elasticsearch_container_up = 0
            elasticsearch_cluster_healthy = 0
            elasticsearch_nodes_count = 0
            elasticsearch_indices_count = 0
        }
    }
}

# Function to generate Prometheus metrics
function Get-PrometheusMetrics {
    $postgresMetrics = Get-PostgreSQLMetrics
    $kafkaMetrics = Get-KafkaMetrics
    $elasticsearchMetrics = Get-ElasticsearchMetrics
    
    $metrics = @()
    
    # PostgreSQL metrics
    $metrics += "# HELP postgres_container_up PostgreSQL container status"
    $metrics += "# TYPE postgres_container_up gauge"
    $metrics += "postgres_container_up{environment=`"$Environment`"} $($postgresMetrics.postgres_container_up)"
    
    $metrics += "# HELP postgres_ready PostgreSQL readiness status"
    $metrics += "# TYPE postgres_ready gauge"
    $metrics += "postgres_ready{environment=`"$Environment`"} $($postgresMetrics.postgres_ready)"
    
    $metrics += "# HELP postgres_database_size_bytes PostgreSQL database size in bytes"
    $metrics += "# TYPE postgres_database_size_bytes gauge"
    $metrics += "postgres_database_size_bytes{environment=`"$Environment`"} $($postgresMetrics.postgres_database_size_bytes)"
    
    # Kafka metrics
    $metrics += "# HELP kafka_container_up Kafka container status"
    $metrics += "# TYPE kafka_container_up gauge"
    $metrics += "kafka_container_up{environment=`"$Environment`"} $($kafkaMetrics.kafka_container_up)"
    
    $metrics += "# HELP kafka_consumer_groups_active Kafka consumer groups activity"
    $metrics += "# TYPE kafka_consumer_groups_active gauge"
    $metrics += "kafka_consumer_groups_active{environment=`"$Environment`"} $($kafkaMetrics.kafka_consumer_groups_active)"
    
    $metrics += "# HELP kafka_being_used Kafka usage by applications"
    $metrics += "# TYPE kafka_being_used gauge"
    $metrics += "kafka_being_used{environment=`"$Environment`"} $($kafkaMetrics.kafka_being_used)"
    
    # Elasticsearch metrics
    $metrics += "# HELP elasticsearch_container_up Elasticsearch container status"
    $metrics += "# TYPE elasticsearch_container_up gauge"
    $metrics += "elasticsearch_container_up{environment=`"$Environment`"} $($elasticsearchMetrics.elasticsearch_container_up)"
    
    $metrics += "# HELP elasticsearch_cluster_healthy Elasticsearch cluster health"
    $metrics += "# TYPE elasticsearch_cluster_healthy gauge"
    $metrics += "elasticsearch_cluster_healthy{environment=`"$Environment`"} $($elasticsearchMetrics.elasticsearch_cluster_healthy)"
    
    $metrics += "# HELP elasticsearch_nodes_count Elasticsearch nodes count"
    $metrics += "# TYPE elasticsearch_nodes_count gauge"
    $metrics += "elasticsearch_nodes_count{environment=`"$Environment`"} $($elasticsearchMetrics.elasticsearch_nodes_count)"
    
    $metrics += "# HELP elasticsearch_indices_count Elasticsearch indices count"
    $metrics += "# TYPE elasticsearch_indices_count gauge"
    $metrics += "elasticsearch_indices_count{environment=`"$Environment`"} $($elasticsearchMetrics.elasticsearch_indices_count)"
    
    return $metrics -join "`n"
}

# Start HTTP listener
try {
    $listener = [System.Net.HttpListener]::new()
    $listener.Prefixes.Add("http://localhost:$Port/")
    $listener.Start()
    
    Write-Host "Infrastructure Metrics Exporter running at http://localhost:$Port" -ForegroundColor Green
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
                $responseContent = Get-PrometheusMetrics
                $contentType = "text/plain; version=0.0.4; charset=utf-8"
            }
            "/health" {
                $postgresMetrics = Get-PostgreSQLMetrics
                $kafkaMetrics = Get-KafkaMetrics
                $elasticsearchMetrics = Get-ElasticsearchMetrics
                
                $overallHealth = if ($postgresMetrics.postgres_container_up -and $kafkaMetrics.kafka_container_up -and $elasticsearchMetrics.elasticsearch_container_up) { "UP" } else { "DOWN" }
                
                $responseContent = @{
                    status = $overallHealth
                    timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
                    services = @{
                        postgresql = @{
                            container_up = $postgresMetrics.postgres_container_up -eq 1
                            ready = $postgresMetrics.postgres_ready -eq 1
                        }
                        kafka = @{
                            container_up = $kafkaMetrics.kafka_container_up -eq 1
                            active = $kafkaMetrics.kafka_consumer_groups_active -eq 1
                        }
                        elasticsearch = @{
                            container_up = $elasticsearchMetrics.elasticsearch_container_up -eq 1
                            healthy = $elasticsearchMetrics.elasticsearch_cluster_healthy -eq 1
                        }
                    }
                } | ConvertTo-Json -Depth 10
                $contentType = "application/json"
                
                if ($overallHealth -ne "UP") { $statusCode = 503 }
            }
            "/" {
                $responseContent = @{
                    service = "Infrastructure Metrics Exporter"
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
