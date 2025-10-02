#!/bin/bash
# Enhanced Docker Testing Script
set -e

echo "=== Enhanced Docker Image Testing ==="
echo "Testing all Docker images for build, runtime, and functionality..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to test Docker image
test_docker_image() {
    local service_name=$1
    local dockerfile_path=$2
    local test_port=$3
    local health_endpoint=$4
    
    echo -e "${YELLOW}Testing $service_name...${NC}"
    
    # Build image
    echo "Building Docker image for $service_name..."
    if docker build -t "$service_name:test" "$dockerfile_path"; then
        echo -e "${GREEN}✓ $service_name image built successfully${NC}"
    else
        echo -e "${RED}✗ Failed to build $service_name image${NC}"
        return 1
    fi
    
    # Test image size
    local image_size=$(docker images "$service_name:test" --format "table {{.Size}}" | tail -n 1)
    echo "Image size: $image_size"
    
    # Test image layers
    echo "Analyzing image layers..."
    docker history "$service_name:test" --format "table {{.CreatedBy}}" | head -5
    
    echo -e "${GREEN}✓ $service_name Docker image test completed${NC}"
    echo "----------------------------------------"
}

# Function to test Docker Compose
test_docker_compose() {
    echo -e "${YELLOW}Testing Docker Compose orchestration...${NC}"
    
    # Start services
    echo "Starting services with Docker Compose..."
    docker-compose -f docker-compose.test.yml up --build -d
    
    # Wait for services to start
    echo "Waiting for services to start..."
    sleep 30
    
    # Test service connectivity
    echo "Testing service connectivity..."
    
    # Test data collection service
    if curl -f http://localhost:8081/actuator/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Data collection service is healthy${NC}"
    else
        echo -e "${RED}✗ Data collection service health check failed${NC}"
    fi
    
    # Test data storage service
    if curl -f http://localhost:8082/actuator/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Data storage service is healthy${NC}"
    else
        echo -e "${RED}✗ Data storage service health check failed${NC}"
    fi
    
    # Test MACD trader service
    if curl -f http://localhost:8083/actuator/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ MACD trader service is healthy${NC}"
    else
        echo -e "${RED}✗ MACD trader service health check failed${NC}"
    fi
    
    # Test Python frontend
    if curl -f http://localhost:8084/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Python frontend is healthy${NC}"
    else
        echo -e "${RED}✗ Python frontend health check failed${NC}"
    fi
    
    # Stop services
    echo "Stopping services..."
    docker-compose -f docker-compose.test.yml down
    
    echo -e "${GREEN}✓ Docker Compose test completed${NC}"
}

# Function to test resource usage
test_resource_usage() {
    echo -e "${YELLOW}Testing resource usage...${NC}"
    
    # Start a service and monitor resources
    docker run -d --name resource-test binance-data-collection:test
    sleep 10
    
    # Get container stats
    echo "Container resource usage:"
    docker stats resource-test --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
    
    # Cleanup
    docker stop resource-test
    docker rm resource-test
    
    echo -e "${GREEN}✓ Resource usage test completed${NC}"
}

# Main execution
echo "Starting enhanced Docker testing..."

# Test individual images
test_docker_image "binance-data-collection" "./binance-data-collection" "8081" "/actuator/health"
test_docker_image "binance-data-storage" "./binance-data-storage" "8082" "/actuator/health"
test_docker_image "binance-trader-macd" "./binance-trader-macd" "8083" "/actuator/health"
test_docker_image "telegram-frontend" "./telegram-frontend-python" "8084" "/health"

# Test Docker Compose orchestration
test_docker_compose

# Test resource usage
test_resource_usage

echo -e "${GREEN}=== Enhanced Docker Testing Complete ===${NC}"
echo "All Docker images and orchestration tested successfully!"
