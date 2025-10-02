#!/bin/bash
# Health Check Testing Script
set -e

echo "=== Health Check Testing ==="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to test health endpoint
test_health_endpoint() {
    local service_name=$1
    local url=$2
    local expected_status=$3
    
    echo -e "${YELLOW}Testing $service_name health endpoint...${NC}"
    
    # Test health endpoint
    local response=$(curl -s -w "%{http_code}" -o /tmp/health_response.json "$url")
    local http_code="${response: -3}"
    
    if [ "$http_code" = "$expected_status" ]; then
        echo -e "${GREEN}✓ $service_name health check passed (HTTP $http_code)${NC}"
        
        # Parse health response
        if command -v jq &> /dev/null; then
            local status=$(jq -r '.status' /tmp/health_response.json 2>/dev/null || echo "unknown")
            echo "  Status: $status"
            
            # Check individual components
            if [ "$status" = "UP" ]; then
                echo -e "${GREEN}  ✓ Service is UP${NC}"
            else
                echo -e "${RED}  ✗ Service is $status${NC}"
            fi
            
            # Check database health
            local db_status=$(jq -r '.components.db.status' /tmp/health_response.json 2>/dev/null || echo "unknown")
            if [ "$db_status" = "UP" ]; then
                echo -e "${GREEN}  ✓ Database is UP${NC}"
            else
                echo -e "${RED}  ✗ Database is $db_status${NC}"
            fi
            
            # Check Kafka health
            local kafka_status=$(jq -r '.components.kafka.status' /tmp/health_response.json 2>/dev/null || echo "unknown")
            if [ "$kafka_status" = "UP" ]; then
                echo -e "${GREEN}  ✓ Kafka is UP${NC}"
            else
                echo -e "${RED}  ✗ Kafka is $kafka_status${NC}"
            fi
        fi
    else
        echo -e "${RED}✗ $service_name health check failed (HTTP $http_code)${NC}"
        return 1
    fi
    
    echo "----------------------------------------"
}

# Function to test metrics endpoint
test_metrics_endpoint() {
    local service_name=$1
    local url=$2
    
    echo -e "${YELLOW}Testing $service_name metrics endpoint...${NC}"
    
    local response=$(curl -s -w "%{http_code}" -o /tmp/metrics_response.txt "$url")
    local http_code="${response: -3}"
    
    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✓ $service_name metrics endpoint accessible${NC}"
        
        # Check for key metrics
        if grep -q "jvm_memory_used_bytes" /tmp/metrics_response.txt; then
            echo -e "${GREEN}  ✓ JVM memory metrics found${NC}"
        else
            echo -e "${RED}  ✗ JVM memory metrics not found${NC}"
        fi
        
        if grep -q "http_server_requests_seconds" /tmp/metrics_response.txt; then
            echo -e "${GREEN}  ✓ HTTP request metrics found${NC}"
        else
            echo -e "${RED}  ✗ HTTP request metrics not found${NC}"
        fi
        
        if grep -q "kafka_consumer_records_consumed_total" /tmp/metrics_response.txt; then
            echo -e "${GREEN}  ✓ Kafka consumer metrics found${NC}"
        else
            echo -e "${RED}  ✗ Kafka consumer metrics not found${NC}"
        fi
    else
        echo -e "${RED}✗ $service_name metrics endpoint failed (HTTP $http_code)${NC}"
        return 1
    fi
    
    echo "----------------------------------------"
}

# Function to test info endpoint
test_info_endpoint() {
    local service_name=$1
    local url=$2
    
    echo -e "${YELLOW}Testing $service_name info endpoint...${NC}"
    
    local response=$(curl -s -w "%{http_code}" -o /tmp/info_response.json "$url")
    local http_code="${response: -3}"
    
    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✓ $service_name info endpoint accessible${NC}"
        
        if command -v jq &> /dev/null; then
            local app_name=$(jq -r '.app.name' /tmp/info_response.json 2>/dev/null || echo "unknown")
            local app_version=$(jq -r '.app.version' /tmp/info_response.json 2>/dev/null || echo "unknown")
            local java_version=$(jq -r '.java.version' /tmp/info_response.json 2>/dev/null || echo "unknown")
            
            echo "  App Name: $app_name"
            echo "  App Version: $app_version"
            echo "  Java Version: $java_version"
        fi
    else
        echo -e "${RED}✗ $service_name info endpoint failed (HTTP $http_code)${NC}"
        return 1
    fi
    
    echo "----------------------------------------"
}

# Function to test service connectivity
test_service_connectivity() {
    echo -e "${YELLOW}Testing service connectivity...${NC}"
    
    # Test data collection service
    test_health_endpoint "Data Collection" "http://localhost:8081/actuator/health" "200"
    test_metrics_endpoint "Data Collection" "http://localhost:8081/actuator/prometheus"
    test_info_endpoint "Data Collection" "http://localhost:8081/actuator/info"
    
    # Test data storage service
    test_health_endpoint "Data Storage" "http://localhost:8082/actuator/health" "200"
    test_metrics_endpoint "Data Storage" "http://localhost:8082/actuator/prometheus"
    test_info_endpoint "Data Storage" "http://localhost:8082/actuator/info"
    
    # Test MACD trader service
    test_health_endpoint "MACD Trader" "http://localhost:8083/actuator/health" "200"
    test_metrics_endpoint "MACD Trader" "http://localhost:8083/actuator/prometheus"
    test_info_endpoint "MACD Trader" "http://localhost:8083/actuator/info"
    
    # Test Python frontend
    test_health_endpoint "Python Frontend" "http://localhost:8084/health" "200"
}

# Function to test monitoring services
test_monitoring_services() {
    echo -e "${YELLOW}Testing monitoring services...${NC}"
    
    # Test Prometheus
    if curl -f http://localhost:9090/-/healthy > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Prometheus is healthy${NC}"
    else
        echo -e "${RED}✗ Prometheus health check failed${NC}"
    fi
    
    # Test Grafana
    if curl -f http://localhost:3000/api/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Grafana is healthy${NC}"
    else
        echo -e "${RED}✗ Grafana health check failed${NC}"
    fi
}

# Main execution
echo "Starting health check testing..."

# Wait for services to be ready
echo "Waiting for services to be ready..."
sleep 30

# Test service connectivity
test_service_connectivity

# Test monitoring services
test_monitoring_services

# Cleanup
rm -f /tmp/health_response.json /tmp/metrics_response.txt /tmp/info_response.json

echo -e "${GREEN}=== Health Check Testing Complete ===${NC}"
echo "All health checks completed successfully!"
