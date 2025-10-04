#!/bin/bash
# Performance Testing Script
set -e

echo "=== Performance Testing ==="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Performance thresholds
MAX_RESPONSE_TIME=1000  # milliseconds
MAX_MEMORY_USAGE=80     # percentage
MAX_CPU_USAGE=80        # percentage

# Function to install Apache Bench if not available
install_ab() {
    if ! command -v ab &> /dev/null; then
        echo -e "${YELLOW}Installing Apache Bench...${NC}"
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get update && sudo apt-get install -y apache2-utils
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install httpd
        else
            echo -e "${RED}Please install Apache Bench manually${NC}"
            exit 1
        fi
    fi
}

# Function to run load test
run_load_test() {
    local service_name=$1
    local url=$2
    local requests=$3
    local concurrency=$4
    
    echo -e "${YELLOW}Running load test for $service_name...${NC}"
    echo "URL: $url"
    echo "Requests: $requests, Concurrency: $concurrency"
    
    # Run Apache Bench test
    ab -n "$requests" -c "$concurrency" -g "/tmp/${service_name}_results.tsv" "$url" > "/tmp/${service_name}_ab_results.txt" 2>&1
    
    # Parse results
    local requests_per_second=$(grep "Requests per second" "/tmp/${service_name}_ab_results.txt" | awk '{print $4}')
    local time_per_request=$(grep "Time per request" "/tmp/${service_name}_ab_results.txt" | head -1 | awk '{print $4}')
    local failed_requests=$(grep "Failed requests" "/tmp/${service_name}_ab_results.txt" | awk '{print $3}')
    
    echo "Results:"
    echo "  Requests per second: $requests_per_second"
    echo "  Time per request: ${time_per_request}ms"
    echo "  Failed requests: $failed_requests"
    
    # Check performance thresholds
    if (( $(echo "$time_per_request < $MAX_RESPONSE_TIME" | bc -l) )); then
        echo -e "${GREEN}  ✓ Response time within threshold${NC}"
    else
        echo -e "${RED}  ✗ Response time exceeds threshold (${time_per_request}ms > ${MAX_RESPONSE_TIME}ms)${NC}"
    fi
    
    if [ "$failed_requests" = "0" ]; then
        echo -e "${GREEN}  ✓ No failed requests${NC}"
    else
        echo -e "${RED}  ✗ $failed_requests failed requests${NC}"
    fi
    
    echo "----------------------------------------"
}

# Function to test memory usage
test_memory_usage() {
    echo -e "${YELLOW}Testing memory usage...${NC}"
    
    # Get container memory usage
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" > /tmp/memory_usage.txt
    
    echo "Container Memory Usage:"
    cat /tmp/memory_usage.txt
    
    # Check if any container exceeds memory threshold
    while IFS=$'\t' read -r container cpu mem_usage mem_perc; do
        if [[ "$mem_perc" =~ ^[0-9]+\.?[0-9]*%$ ]]; then
            mem_value=$(echo "$mem_perc" | sed 's/%//')
            if (( $(echo "$mem_value > $MAX_MEMORY_USAGE" | bc -l) )); then
                echo -e "${RED}✗ $container exceeds memory threshold (${mem_perc} > ${MAX_MEMORY_USAGE}%)${NC}"
            else
                echo -e "${GREEN}✓ $container memory usage OK (${mem_perc})${NC}"
            fi
        fi
    done < <(tail -n +2 /tmp/memory_usage.txt)
    
    echo "----------------------------------------"
}

# Function to test CPU usage
test_cpu_usage() {
    echo -e "${YELLOW}Testing CPU usage...${NC}"
    
    # Get container CPU usage
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" > /tmp/cpu_usage.txt
    
    echo "Container CPU Usage:"
    cat /tmp/cpu_usage.txt
    
    # Check if any container exceeds CPU threshold
    while IFS=$'\t' read -r container cpu_perc mem_usage mem_perc; do
        if [[ "$cpu_perc" =~ ^[0-9]+\.?[0-9]*%$ ]]; then
            cpu_value=$(echo "$cpu_perc" | sed 's/%//')
            if (( $(echo "$cpu_value > $MAX_CPU_USAGE" | bc -l) )); then
                echo -e "${RED}✗ $container exceeds CPU threshold (${cpu_perc} > ${MAX_CPU_USAGE}%)${NC}"
            else
                echo -e "${GREEN}✓ $container CPU usage OK (${cpu_perc})${NC}"
            fi
        fi
    done < <(tail -n +2 /tmp/cpu_usage.txt)
    
    echo "----------------------------------------"
}

# Function to test database performance
test_database_performance() {
    echo -e "${YELLOW}Testing database performance...${NC}"
    
    # Test database connection
    local start_time=$(date +%s%3N)
    curl -f http://localhost:8082/actuator/health/db > /dev/null 2>&1
    local end_time=$(date +%s%3N)
    local response_time=$((end_time - start_time))
    
    echo "Database health check response time: ${response_time}ms"
    
    if [ "$response_time" -lt 500 ]; then
        echo -e "${GREEN}✓ Database response time acceptable${NC}"
    else
        echo -e "${RED}✗ Database response time too slow (${response_time}ms)${NC}"
    fi
    
    echo "----------------------------------------"
}

# Function to test Kafka performance
test_kafka_performance() {
    echo -e "${YELLOW}Testing Kafka performance...${NC}"
    
    # Test Kafka connectivity
    local start_time=$(date +%s%3N)
    curl -f http://localhost:8081/actuator/health/kafka > /dev/null 2>&1
    local end_time=$(date +%s%3N)
    local response_time=$((end_time - start_time))
    
    echo "Kafka health check response time: ${response_time}ms"
    
    if [ "$response_time" -lt 500 ]; then
        echo -e "${GREEN}✓ Kafka response time acceptable${NC}"
    else
        echo -e "${RED}✗ Kafka response time too slow (${response_time}ms)${NC}"
    fi
    
    echo "----------------------------------------"
}

# Function to generate performance report
generate_performance_report() {
    echo -e "${YELLOW}Generating performance report...${NC}"
    
    local report_file="performance_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "=== Performance Test Report ==="
        echo "Generated: $(date)"
        echo ""
        echo "=== Load Test Results ==="
        
        for service in "data-collection" "data-storage" "macd-trader" "python-frontend"; do
            if [ -f "/tmp/${service}_ab_results.txt" ]; then
                echo "--- $service ---"
                cat "/tmp/${service}_ab_results.txt"
                echo ""
            fi
        done
        
        echo "=== Resource Usage ==="
        echo "Memory Usage:"
        cat /tmp/memory_usage.txt
        echo ""
        echo "CPU Usage:"
        cat /tmp/cpu_usage.txt
        echo ""
        
        echo "=== Performance Thresholds ==="
        echo "Max Response Time: ${MAX_RESPONSE_TIME}ms"
        echo "Max Memory Usage: ${MAX_MEMORY_USAGE}%"
        echo "Max CPU Usage: ${MAX_CPU_USAGE}%"
        
    } > "$report_file"
    
    echo -e "${GREEN}✓ Performance report generated: $report_file${NC}"
}

# Main execution
echo "Starting performance testing..."

# Install Apache Bench if needed
install_ab

# Wait for services to be ready
echo "Waiting for services to be ready..."
sleep 30

# Run load tests
run_load_test "data-collection" "http://localhost:8081/actuator/health" 100 10
run_load_test "data-storage" "http://localhost:8082/actuator/health" 100 10
run_load_test "macd-trader" "http://localhost:8083/actuator/health" 100 10
run_load_test "python-frontend" "http://localhost:8084/health" 100 10

# Test resource usage
test_memory_usage
test_cpu_usage

# Test infrastructure performance
test_database_performance
test_kafka_performance

# Generate performance report
generate_performance_report

# Cleanup
rm -f /tmp/*_ab_results.txt /tmp/*_results.tsv /tmp/memory_usage.txt /tmp/cpu_usage.txt

echo -e "${GREEN}=== Performance Testing Complete ===${NC}"
echo "Performance testing completed successfully!"
