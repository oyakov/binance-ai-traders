# Comprehensive Health Metrics Exporter for All System Components
param(
    [int]$Port = 8089,
    [string]$Environment = "testnet"
)

Write-Host "Starting Comprehensive Health Metrics Exporter on port $Port" -ForegroundColor Green

# Function to get detailed PostgreSQL health metrics
function Get-PostgreSQLHealthMetrics {
    try {
        $containerStatus = docker inspect postgres-$Environment --format "{{.State.Status}}" 2>$null
        $isRunning = $containerStatus -eq "running"
        
        $pgReady = docker exec postgres-$Environment pg_isready -h localhost -p 5432 2>$null
        $isReady = $LASTEXITCODE -eq 0
        
        # Get detailed database metrics
        $dbSize = docker exec postgres-$Environment psql -U testnet_user -d binance_trader_testnet -t -c "SELECT pg_database_size('binance_trader_testnet');" 2>$null
        $dbSizeBytes = if ($dbSize) { [int64]$dbSize.Trim() } else { 0 }
        
        # Get connection count
        $connectionCount = docker exec postgres-$Environment psql -U testnet_user -d binance_trader_testnet -t -c "SELECT count(*) FROM pg_stat_activity;" 2>$null
        $activeConnections = if ($connectionCount) { [int]$connectionCount.Trim() } else { 0 }
        
        # Get table count
        $tableCount = docker exec postgres-$Environment psql -U testnet_user -d binance_trader_testnet -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>$null
        $tablesCount = if ($tableCount) { [int]$tableCount.Trim() } else { 0 }
        
        # Get uptime
        $uptime = docker exec postgres-$Environment psql -U testnet_user -d binance_trader_testnet -t -c "SELECT extract(epoch from now() - pg_postmaster_start_time());" 2>$null
        $uptimeSeconds = if ($uptime) { [int64]$uptime.Trim() } else { 0 }
        
        return @{
            postgres_container_up = if ($isRunning) { 1 } else { 0 }
            postgres_ready = if ($isReady) { 1 } else { 0 }
            postgres_database_size_bytes = $dbSizeBytes
            postgres_active_connections = $activeConnections
            postgres_tables_count = $tablesCount
            postgres_uptime_seconds = $uptimeSeconds
        }
    } catch {
        return @{
            postgres_container_up = 0
            postgres_ready = 0
            postgres_database_size_bytes = 0
            postgres_active_connections = 0
            postgres_tables_count = 0
            postgres_uptime_seconds = 0
        }
    }
}

# Function to get detailed Kafka health metrics
function Get-KafkaHealthMetrics {
    try {
        $containerStatus = docker inspect kafka-$Environment --format "{{.State.Status}}" 2>$null
        $isRunning = $containerStatus -eq "running"
        
        # Check consumer group activity
        $consumerGroups = docker logs kafka-$Environment --tail 50 2>$null | Select-String "GroupCoordinator"
        $isActive = $consumerGroups -ne $null
        $consumerGroupCount = if ($consumerGroups) { $consumerGroups.Count } else { 0 }
        
        # Check if data collection service is using Kafka
        $dataCollectionLogs = docker logs binance-data-collection-$Environment --tail 20 2>$null | Select-String "kafka"
        $isUsed = $dataCollectionLogs -ne $null
        
        # Check for errors in logs
        $errorLogs = docker logs kafka-$Environment --tail 100 2>$null | Select-String "ERROR|FATAL|Exception" -CaseSensitive:$false
        $errorCount = if ($errorLogs) { $errorLogs.Count } else { 0 }
        
        # Get container uptime
        $startTime = docker inspect kafka-$Environment --format "{{.State.StartedAt}}" 2>$null
        $uptimeSeconds = if ($startTime) { 
            $start = [DateTime]::Parse($startTime)
            [int64]((Get-Date) - $start).TotalSeconds
        } else { 0 }
        
        return @{
            kafka_container_up = if ($isRunning) { 1 } else { 0 }
            kafka_consumer_groups_active = if ($isActive) { 1 } else { 0 }
            kafka_consumer_groups_count = $consumerGroupCount
            kafka_being_used = if ($isUsed) { 1 } else { 0 }
            kafka_error_count = $errorCount
            kafka_uptime_seconds = $uptimeSeconds
        }
    } catch {
        return @{
            kafka_container_up = 0
            kafka_consumer_groups_active = 0
            kafka_consumer_groups_count = 0
            kafka_being_used = 0
            kafka_error_count = 0
            kafka_uptime_seconds = 0
        }
    }
}

# Function to get detailed Elasticsearch health metrics
function Get-ElasticsearchHealthMetrics {
    try {
        $containerStatus = docker inspect elasticsearch-$Environment --format "{{.State.Status}}" 2>$null
        $isRunning = $containerStatus -eq "running"
        
        # Get cluster health
        $clusterHealth = Invoke-WebRequest -Uri "http://localhost:9202/_cluster/health" -TimeoutSec 5 2>$null
        $isHealthy = $clusterHealth.StatusCode -eq 200
        $healthData = if ($isHealthy) { $clusterHealth.Content | ConvertFrom-Json } else { $null }
        
        # Get cluster stats
        $clusterStats = Invoke-WebRequest -Uri "http://localhost:9202/_cluster/stats" -TimeoutSec 5 2>$null
        $statsData = if ($clusterStats.StatusCode -eq 200) { $clusterStats.Content | ConvertFrom-Json } else { $null }
        
        # Get indices info
        $indicesInfo = Invoke-WebRequest -Uri "http://localhost:9202/_cat/indices?v&format=json" -TimeoutSec 5 2>$null
        $indicesData = if ($indicesInfo.StatusCode -eq 200) { $indicesInfo.Content | ConvertFrom-Json } else { @() }
        
        $nodeCount = if ($statsData) { $statsData.nodes.count.total } else { 0 }
        $indicesCount = if ($statsData) { $statsData.indices.count } else { 0 }
        $clusterStatus = if ($healthData) { $healthData.status } else { "unknown" }
        $clusterStatusValue = if ($clusterStatus -eq "green") { 3 } elseif ($clusterStatus -eq "yellow") { 2 } elseif ($clusterStatus -eq "red") { 1 } else { 0 }
        
        # Calculate total storage used
        $totalStorage = 0
        if ($indicesData) {
            $totalStorage = ($indicesData | Measure-Object -Property "store.size" -Sum).Sum
        }
        
        return @{
            elasticsearch_container_up = if ($isRunning) { 1 } else { 0 }
            elasticsearch_cluster_healthy = if ($isHealthy) { 1 } else { 0 }
            elasticsearch_cluster_status = $clusterStatusValue
            elasticsearch_nodes_count = $nodeCount
            elasticsearch_indices_count = $indicesCount
            elasticsearch_storage_bytes = $totalStorage
        }
    } catch {
        return @{
            elasticsearch_container_up = 0
            elasticsearch_cluster_healthy = 0
            elasticsearch_cluster_status = 0
            elasticsearch_nodes_count = 0
            elasticsearch_indices_count = 0
            elasticsearch_storage_bytes = 0
        }
    }
}

# Function to get application service health metrics
function Get-ApplicationHealthMetrics {
    $metrics = @{}
    
    # Trading Service
    try {
        $tradingHealth = Invoke-WebRequest -Uri "http://localhost:8083/actuator/health" -TimeoutSec 5 2>$null
        $tradingUp = $tradingHealth.StatusCode -eq 200
        $tradingData = if ($tradingUp) { $tradingHealth.Content | ConvertFrom-Json } else { $null }
        $tradingStatus = if ($tradingData) { $tradingData.status } else { "DOWN" }
        
        $metrics.trading_service_up = if ($tradingUp) { 1 } else { 0 }
        $metrics.trading_service_status = if ($tradingStatus -eq "UP") { 1 } else { 0 }
    } catch {
        $metrics.trading_service_up = 0
        $metrics.trading_service_status = 0
    }
    
    # Data Collection Service
    try {
        $dataCollectionHealth = Invoke-WebRequest -Uri "http://localhost:8086/actuator/health" -TimeoutSec 5 2>$null
        $dataCollectionUp = $dataCollectionHealth.StatusCode -eq 200
        $dataCollectionData = if ($dataCollectionUp) { $dataCollectionHealth.Content | ConvertFrom-Json } else { $null }
        $dataCollectionStatus = if ($dataCollectionData) { $dataCollectionData.status } else { "DOWN" }
        
        $metrics.data_collection_service_up = if ($dataCollectionUp) { 1 } else { 0 }
        $metrics.data_collection_service_status = if ($dataCollectionStatus -eq "UP") { 1 } else { 0 }
    } catch {
        $metrics.data_collection_service_up = 0
        $metrics.data_collection_service_status = 0
    }
    
    return $metrics
}

# Function to get system resource metrics
function Get-SystemResourceMetrics {
    try {
        # Get Docker container resource usage
        $containers = @("postgres-$Environment", "kafka-$Environment", "elasticsearch-$Environment", "binance-trader-macd-$Environment", "binance-data-collection-$Environment")
        $totalMemoryUsage = 0
        $totalCpuUsage = 0
        
        foreach ($container in $containers) {
            try {
                $stats = docker stats $container --no-stream --format "table {{.MemUsage}}\t{{.CPUPerc}}" 2>$null
                if ($stats) {
                    $lines = $stats -split "`n" | Where-Object { $_ -match "MiB|GiB|%" }
                    if ($lines.Count -gt 1) {
                        $memLine = $lines[1] -split "`t"
                        $memUsage = $memLine[0] -replace "[^\d.]", ""
                        $cpuUsage = $memLine[1] -replace "[^\d.]", ""
                        
                        if ($memUsage -match "^\d+\.?\d*$") { $totalMemoryUsage += [double]$memUsage }
                        if ($cpuUsage -match "^\d+\.?\d*$") { $totalCpuUsage += [double]$cpuUsage }
                    }
                }
            } catch {
                # Ignore individual container errors
            }
        }
        
        return @{
            system_memory_usage_mb = $totalMemoryUsage
            system_cpu_usage_percent = $totalCpuUsage
        }
    } catch {
        return @{
            system_memory_usage_mb = 0
            system_cpu_usage_percent = 0
        }
    }
}

# Function to generate comprehensive Prometheus metrics
function Get-ComprehensivePrometheusMetrics {
    $postgresMetrics = Get-PostgreSQLHealthMetrics
    $kafkaMetrics = Get-KafkaHealthMetrics
    $elasticsearchMetrics = Get-ElasticsearchHealthMetrics
    $applicationMetrics = Get-ApplicationHealthMetrics
    $systemMetrics = Get-SystemResourceMetrics
    
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
    
    $metrics += "# HELP postgres_active_connections PostgreSQL active connections count"
    $metrics += "# TYPE postgres_active_connections gauge"
    $metrics += "postgres_active_connections{environment=`"$Environment`"} $($postgresMetrics.postgres_active_connections)"
    
    $metrics += "# HELP postgres_tables_count PostgreSQL tables count"
    $metrics += "# TYPE postgres_tables_count gauge"
    $metrics += "postgres_tables_count{environment=`"$Environment`"} $($postgresMetrics.postgres_tables_count)"
    
    $metrics += "# HELP postgres_uptime_seconds PostgreSQL uptime in seconds"
    $metrics += "# TYPE postgres_uptime_seconds gauge"
    $metrics += "postgres_uptime_seconds{environment=`"$Environment`"} $($postgresMetrics.postgres_uptime_seconds)"
    
    # Kafka metrics
    $metrics += "# HELP kafka_container_up Kafka container status"
    $metrics += "# TYPE kafka_container_up gauge"
    $metrics += "kafka_container_up{environment=`"$Environment`"} $($kafkaMetrics.kafka_container_up)"
    
    $metrics += "# HELP kafka_consumer_groups_active Kafka consumer groups activity"
    $metrics += "# TYPE kafka_consumer_groups_active gauge"
    $metrics += "kafka_consumer_groups_active{environment=`"$Environment`"} $($kafkaMetrics.kafka_consumer_groups_active)"
    
    $metrics += "# HELP kafka_consumer_groups_count Kafka consumer groups count"
    $metrics += "# TYPE kafka_consumer_groups_count gauge"
    $metrics += "kafka_consumer_groups_count{environment=`"$Environment`"} $($kafkaMetrics.kafka_consumer_groups_count)"
    
    $metrics += "# HELP kafka_being_used Kafka usage by applications"
    $metrics += "# TYPE kafka_being_used gauge"
    $metrics += "kafka_being_used{environment=`"$Environment`"} $($kafkaMetrics.kafka_being_used)"
    
    $metrics += "# HELP kafka_error_count Kafka error count from logs"
    $metrics += "# TYPE kafka_error_count gauge"
    $metrics += "kafka_error_count{environment=`"$Environment`"} $($kafkaMetrics.kafka_error_count)"
    
    $metrics += "# HELP kafka_uptime_seconds Kafka uptime in seconds"
    $metrics += "# TYPE kafka_uptime_seconds gauge"
    $metrics += "kafka_uptime_seconds{environment=`"$Environment`"} $($kafkaMetrics.kafka_uptime_seconds)"
    
    # Elasticsearch metrics
    $metrics += "# HELP elasticsearch_container_up Elasticsearch container status"
    $metrics += "# TYPE elasticsearch_container_up gauge"
    $metrics += "elasticsearch_container_up{environment=`"$Environment`"} $($elasticsearchMetrics.elasticsearch_container_up)"
    
    $metrics += "# HELP elasticsearch_cluster_healthy Elasticsearch cluster health"
    $metrics += "# TYPE elasticsearch_cluster_healthy gauge"
    $metrics += "elasticsearch_cluster_healthy{environment=`"$Environment`"} $($elasticsearchMetrics.elasticsearch_cluster_healthy)"
    
    $metrics += "# HELP elasticsearch_cluster_status Elasticsearch cluster status (0=unknown, 1=red, 2=yellow, 3=green)"
    $metrics += "# TYPE elasticsearch_cluster_status gauge"
    $metrics += "elasticsearch_cluster_status{environment=`"$Environment`"} $($elasticsearchMetrics.elasticsearch_cluster_status)"
    
    $metrics += "# HELP elasticsearch_nodes_count Elasticsearch nodes count"
    $metrics += "# TYPE elasticsearch_nodes_count gauge"
    $metrics += "elasticsearch_nodes_count{environment=`"$Environment`"} $($elasticsearchMetrics.elasticsearch_nodes_count)"
    
    $metrics += "# HELP elasticsearch_indices_count Elasticsearch indices count"
    $metrics += "# TYPE elasticsearch_indices_count gauge"
    $metrics += "elasticsearch_indices_count{environment=`"$Environment`"} $($elasticsearchMetrics.elasticsearch_indices_count)"
    
    $metrics += "# HELP elasticsearch_storage_bytes Elasticsearch storage used in bytes"
    $metrics += "# TYPE elasticsearch_storage_bytes gauge"
    $metrics += "elasticsearch_storage_bytes{environment=`"$Environment`"} $($elasticsearchMetrics.elasticsearch_storage_bytes)"
    
    # Application metrics
    $metrics += "# HELP trading_service_up Trading service container status"
    $metrics += "# TYPE trading_service_up gauge"
    $metrics += "trading_service_up{environment=`"$Environment`"} $($applicationMetrics.trading_service_up)"
    
    $metrics += "# HELP trading_service_status Trading service health status"
    $metrics += "# TYPE trading_service_status gauge"
    $metrics += "trading_service_status{environment=`"$Environment`"} $($applicationMetrics.trading_service_status)"
    
    $metrics += "# HELP data_collection_service_up Data collection service container status"
    $metrics += "# TYPE data_collection_service_up gauge"
    $metrics += "data_collection_service_up{environment=`"$Environment`"} $($applicationMetrics.data_collection_service_up)"
    
    $metrics += "# HELP data_collection_service_status Data collection service health status"
    $metrics += "# TYPE data_collection_service_status gauge"
    $metrics += "data_collection_service_status{environment=`"$Environment`"} $($applicationMetrics.data_collection_service_status)"
    
    # System metrics
    $metrics += "# HELP system_memory_usage_mb System memory usage in MB"
    $metrics += "# TYPE system_memory_usage_mb gauge"
    $metrics += "system_memory_usage_mb{environment=`"$Environment`"} $($systemMetrics.system_memory_usage_mb)"
    
    $metrics += "# HELP system_cpu_usage_percent System CPU usage percentage"
    $metrics += "# TYPE system_cpu_usage_percent gauge"
    $metrics += "system_cpu_usage_percent{environment=`"$Environment`"} $($systemMetrics.system_cpu_usage_percent)"
    
    return $metrics -join "`n"
}

# Start HTTP listener
try {
    $listener = [System.Net.HttpListener]::new()
    $listener.Prefixes.Add("http://localhost:$Port/")
    $listener.Start()
    
    Write-Host "Comprehensive Health Metrics Exporter running at http://localhost:$Port" -ForegroundColor Green
    Write-Host "Endpoints:" -ForegroundColor Yellow
    Write-Host "  GET /metrics - Comprehensive Prometheus metrics" -ForegroundColor White
    Write-Host "  GET /health - Overall system health" -ForegroundColor White
    Write-Host "  GET /health/postgresql - PostgreSQL health details" -ForegroundColor White
    Write-Host "  GET /health/kafka - Kafka health details" -ForegroundColor White
    Write-Host "  GET /health/elasticsearch - Elasticsearch health details" -ForegroundColor White
    Write-Host "  GET /health/applications - Application services health" -ForegroundColor White
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
                $responseContent = Get-ComprehensivePrometheusMetrics
                $contentType = "text/plain; version=0.0.4; charset=utf-8"
            }
            "/health" {
                $postgresMetrics = Get-PostgreSQLHealthMetrics
                $kafkaMetrics = Get-KafkaHealthMetrics
                $elasticsearchMetrics = Get-ElasticsearchHealthMetrics
                $applicationMetrics = Get-ApplicationHealthMetrics
                
                $overallHealth = if ($postgresMetrics.postgres_container_up -and $kafkaMetrics.kafka_container_up -and $elasticsearchMetrics.elasticsearch_container_up -and $applicationMetrics.trading_service_up -and $applicationMetrics.data_collection_service_up) { "UP" } else { "DOWN" }
                
                $responseContent = @{
                    status = $overallHealth
                    timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
                    environment = $Environment
                    services = @{
                        postgresql = @{
                            container_up = $postgresMetrics.postgres_container_up -eq 1
                            ready = $postgresMetrics.postgres_ready -eq 1
                            active_connections = $postgresMetrics.postgres_active_connections
                            database_size_bytes = $postgresMetrics.postgres_database_size_bytes
                        }
                        kafka = @{
                            container_up = $kafkaMetrics.kafka_container_up -eq 1
                            active = $kafkaMetrics.kafka_consumer_groups_active -eq 1
                            consumer_groups_count = $kafkaMetrics.kafka_consumer_groups_count
                            error_count = $kafkaMetrics.kafka_error_count
                        }
                        elasticsearch = @{
                            container_up = $elasticsearchMetrics.elasticsearch_container_up -eq 1
                            healthy = $elasticsearchMetrics.elasticsearch_cluster_healthy -eq 1
                            cluster_status = $elasticsearchMetrics.elasticsearch_cluster_status
                            nodes_count = $elasticsearchMetrics.elasticsearch_nodes_count
                        }
                        applications = @{
                            trading_service_up = $applicationMetrics.trading_service_up -eq 1
                            trading_service_status = $applicationMetrics.trading_service_status -eq 1
                            data_collection_service_up = $applicationMetrics.data_collection_service_up -eq 1
                            data_collection_service_status = $applicationMetrics.data_collection_service_status -eq 1
                        }
                    }
                } | ConvertTo-Json -Depth 10
                $contentType = "application/json"
                
                if ($overallHealth -ne "UP") { $statusCode = 503 }
            }
            "/health/postgresql" {
                $postgresMetrics = Get-PostgreSQLHealthMetrics
                $responseContent = $postgresMetrics | ConvertTo-Json -Depth 10
                $contentType = "application/json"
                if ($postgresMetrics.postgres_container_up -ne 1) { $statusCode = 503 }
            }
            "/health/kafka" {
                $kafkaMetrics = Get-KafkaHealthMetrics
                $responseContent = $kafkaMetrics | ConvertTo-Json -Depth 10
                $contentType = "application/json"
                if ($kafkaMetrics.kafka_container_up -ne 1) { $statusCode = 503 }
            }
            "/health/elasticsearch" {
                $elasticsearchMetrics = Get-ElasticsearchHealthMetrics
                $responseContent = $elasticsearchMetrics | ConvertTo-Json -Depth 10
                $contentType = "application/json"
                if ($elasticsearchMetrics.elasticsearch_container_up -ne 1) { $statusCode = 503 }
            }
            "/health/applications" {
                $applicationMetrics = Get-ApplicationHealthMetrics
                $responseContent = $applicationMetrics | ConvertTo-Json -Depth 10
                $contentType = "application/json"
                if ($applicationMetrics.trading_service_up -ne 1 -or $applicationMetrics.data_collection_service_up -ne 1) { $statusCode = 503 }
            }
            "/" {
                $responseContent = @{
                    service = "Comprehensive Health Metrics Exporter"
                    version = "2.0.0"
                    environment = $Environment
                    endpoints = @("/", "/metrics", "/health", "/health/postgresql", "/health/kafka", "/health/elasticsearch", "/health/applications")
                    timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
                } | ConvertTo-Json -Depth 10
                $contentType = "application/json"
            }
            default {
                $responseContent = @{
                    error = "Not Found"
                    message = "Endpoint not found"
                    available_endpoints = @("/", "/metrics", "/health", "/health/postgresql", "/health/kafka", "/health/elasticsearch", "/health/applications")
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
