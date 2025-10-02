#!/bin/bash
# Enhanced Test Execution Script
set -e

echo "=== Enhanced Test Execution ==="
echo "Running comprehensive tests including Docker, observability, and end-to-end testing..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run test and track results
run_test() {
    local test_name=$1
    local test_command=$2
    
    echo -e "${BLUE}Running: $test_name${NC}"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if eval "$test_command"; then
        echo -e "${GREEN}✓ $test_name PASSED${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}✗ $test_name FAILED${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    echo "----------------------------------------"
}

# Function to check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}Checking prerequisites...${NC}"
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Docker is not installed${NC}"
        exit 1
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}Docker Compose is not installed${NC}"
        exit 1
    fi
    
    # Check Maven
    if ! command -v mvn &> /dev/null; then
        echo -e "${RED}Maven is not installed${NC}"
        exit 1
    fi
    
    # Check Python
    if ! command -v python &> /dev/null; then
        echo -e "${RED}Python is not installed${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ All prerequisites met${NC}"
}

# Function to clean up
cleanup() {
    echo -e "${YELLOW}Cleaning up...${NC}"
    
    # Stop Docker Compose services
    docker-compose -f docker-compose.test.yml down -v 2>/dev/null || true
    
    # Remove test images
    docker rmi binance-data-collection:test 2>/dev/null || true
    docker rmi binance-data-storage:test 2>/dev/null || true
    docker rmi binance-trader-macd:test 2>/dev/null || true
    docker rmi telegram-frontend:test 2>/dev/null || true
    
    echo -e "${GREEN}✓ Cleanup completed${NC}"
}

# Function to generate test report
generate_test_report() {
    local report_file="enhanced_test_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "=== Enhanced Test Report ==="
        echo "Generated: $(date)"
        echo ""
        echo "=== Test Summary ==="
        echo "Total Tests: $TOTAL_TESTS"
        echo "Passed: $PASSED_TESTS"
        echo "Failed: $FAILED_TESTS"
        echo "Success Rate: $((PASSED_TESTS * 100 / TOTAL_TESTS))%"
        echo ""
        
        if [ $FAILED_TESTS -eq 0 ]; then
            echo "=== RESULT: ALL TESTS PASSED ==="
        else
            echo "=== RESULT: SOME TESTS FAILED ==="
        fi
        
        echo ""
        echo "=== Test Categories ==="
        echo "1. Unit Tests - Java and Python services"
        echo "2. Docker Image Tests - Container build and runtime"
        echo "3. Observability Tests - Health checks and metrics"
        echo "4. Performance Tests - Load and resource usage"
        echo "5. End-to-End Tests - Complete workflow validation"
        echo "6. Integration Tests - Service communication"
        
    } > "$report_file"
    
    echo -e "${GREEN}✓ Test report generated: $report_file${NC}"
}

# Main execution
echo "Starting enhanced test execution..."

# Check prerequisites
check_prerequisites

# Clean up any existing test environment
cleanup

# 1. Unit Tests
echo -e "${YELLOW}=== PHASE 1: Unit Tests ===${NC}"
run_test "Java Unit Tests" "mvn test -Dtest='!*IntegrationTest,!*EndToEndTest'"
run_test "Python Unit Tests" "cd telegram-frontend-python && python -m pytest tests/ -v"

# 2. Docker Image Tests
echo -e "${YELLOW}=== PHASE 2: Docker Image Tests ===${NC}"
run_test "Docker Image Build Tests" "./scripts/docker-test.sh"

# 3. Start Test Environment
echo -e "${YELLOW}=== PHASE 3: Starting Test Environment ===${NC}"
run_test "Start Docker Compose Services" "docker-compose -f docker-compose.test.yml up --build -d"

# Wait for services to be ready
echo "Waiting for services to be ready..."
sleep 60

# 4. Observability Tests
echo -e "${YELLOW}=== PHASE 4: Observability Tests ===${NC}"
run_test "Health Check Tests" "./scripts/health-check-test.sh"
run_test "Observability Integration Tests" "mvn test -Dtest='*ObservabilityIntegrationTest'"

# 5. Performance Tests
echo -e "${YELLOW}=== PHASE 5: Performance Tests ===${NC}"
run_test "Performance Tests" "./scripts/performance-test.sh"

# 6. End-to-End Tests
echo -e "${YELLOW}=== PHASE 6: End-to-End Tests ===${NC}"
run_test "End-to-End Integration Tests" "mvn test -Dtest='*EndToEndIntegrationTest'"

# 7. Integration Tests
echo -e "${YELLOW}=== PHASE 7: Integration Tests ===${NC}"
run_test "Service Integration Tests" "mvn test -Dtest='*IntegrationTest'"

# 8. Cleanup
cleanup

# 9. Generate Report
generate_test_report

# Final Results
echo -e "${YELLOW}=== FINAL RESULTS ===${NC}"
echo "Total Tests: $TOTAL_TESTS"
echo "Passed: $PASSED_TESTS"
echo "Failed: $FAILED_TESTS"
echo "Success Rate: $((PASSED_TESTS * 100 / TOTAL_TESTS))%"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}=== ALL TESTS PASSED ===${NC}"
    echo -e "${GREEN}Enhanced testing completed successfully!${NC}"
    exit 0
else
    echo -e "${RED}=== SOME TESTS FAILED ===${NC}"
    echo -e "${RED}Enhanced testing completed with failures.${NC}"
    exit 1
fi
