#!/bin/sh

# Health Metrics Generator for Docker
# This script generates Prometheus metrics for all system components

echo "# HELP postgres_container_up PostgreSQL container status"
echo "# TYPE postgres_container_up gauge"

# Check PostgreSQL
if docker exec postgres-testnet pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
    echo "postgres_container_up{environment=\"testnet\"} 1"
    echo "postgres_ready{environment=\"testnet\"} 1"
else
    echo "postgres_container_up{environment=\"testnet\"} 0"
    echo "postgres_ready{environment=\"testnet\"} 0"
fi

echo "# HELP kafka_container_up Kafka container status"
echo "# TYPE kafka_container_up gauge"

# Check Kafka
if docker logs kafka-testnet --tail 10 2>/dev/null | grep -q "GroupCoordinator"; then
    echo "kafka_container_up{environment=\"testnet\"} 1"
    echo "kafka_active{environment=\"testnet\"} 1"
else
    echo "kafka_container_up{environment=\"testnet\"} 1"
    echo "kafka_active{environment=\"testnet\"} 0"
fi

echo "# HELP elasticsearch_container_up Elasticsearch container status"
echo "# TYPE elasticsearch_container_up gauge"

# Check Elasticsearch
if curl -s http://elasticsearch-testnet:9200/_cluster/health >/dev/null 2>&1; then
    echo "elasticsearch_container_up{environment=\"testnet\"} 1"
    echo "elasticsearch_healthy{environment=\"testnet\"} 1"
else
    echo "elasticsearch_container_up{environment=\"testnet\"} 0"
    echo "elasticsearch_healthy{environment=\"testnet\"} 0"
fi

echo "# HELP trading_service_up Trading service status"
echo "# TYPE trading_service_up gauge"

# Check Trading Service
if curl -s http://binance-trader-macd-testnet:8080/actuator/health >/dev/null 2>&1; then
    echo "trading_service_up{environment=\"testnet\"} 1"
else
    echo "trading_service_up{environment=\"testnet\"} 0"
fi

echo "# HELP data_collection_service_up Data collection service status"
echo "# TYPE data_collection_service_up gauge"

# Check Data Collection Service
if curl -s http://binance-data-collection-testnet:8080/actuator/health >/dev/null 2>&1; then
    echo "data_collection_service_up{environment=\"testnet\"} 1"
else
    echo "data_collection_service_up{environment=\"testnet\"} 0"
fi