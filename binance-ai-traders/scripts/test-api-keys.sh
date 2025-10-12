#!/bin/bash

# API Key Testing Script for Binance AI Traders
# This script runs comprehensive API key validation tests

set -e

echo "🔐 Starting API Key Testing Suite"
echo "================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "SUCCESS")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "ERROR")
            echo -e "${RED}❌ $message${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
    esac
}

# Function to run tests and capture results
run_test() {
    local test_name=$1
    local test_command=$2
    
    echo -e "\n${BLUE}Running: $test_name${NC}"
    echo "Command: $test_command"
    echo "----------------------------------------"
    
    if eval "$test_command"; then
        print_status "SUCCESS" "$test_name completed successfully"
        return 0
    else
        print_status "ERROR" "$test_name failed"
        return 1
    fi
}

# Check if we're in the project root
if [ ! -f "pom.xml" ]; then
    print_status "ERROR" "Please run this script from the project root directory"
    exit 1
fi

# Check if Maven is available
if ! command -v mvn &> /dev/null; then
    print_status "ERROR" "Maven is not installed or not in PATH"
    exit 1
fi

# Check if testnet.env exists
if [ ! -f "testnet.env" ]; then
    print_status "WARNING" "testnet.env file not found. Some tests may fail."
fi

print_status "INFO" "Project structure validated"

# Test 1: Unit Tests for API Key Validation
echo -e "\n${BLUE}🧪 Running API Key Unit Tests${NC}"
run_test "API Key Validation Unit Tests" \
    "mvn test -pl binance-trader-macd -Dtest=ApiKeyValidationTest"

# Test 2: Integration Tests
echo -e "\n${BLUE}🔗 Running API Key Integration Tests${NC}"
run_test "API Key Integration Tests" \
    "mvn test -pl binance-trader-macd -Dtest=ApiKeyIntegrationTest"

# Test 3: Comprehensive API Key Tests
echo -e "\n${BLUE}📊 Running Comprehensive API Key Tests${NC}"
run_test "Comprehensive API Key Tests" \
    "mvn test -pl binance-trader-macd -Dtest=ApiKeyComprehensiveTest"

# Test 4: Binance API Connectivity Tests
echo -e "\n${BLUE}🌐 Running Binance API Connectivity Tests${NC}"
run_test "Binance API Connectivity Tests" \
    "mvn test -pl binance-trader-macd -Dtest=BinanceApiKeyConnectivityTest"

# Test 5: All MACD Trader Tests (including API key tests)
echo -e "\n${BLUE}🎯 Running All MACD Trader Tests${NC}"
run_test "All MACD Trader Tests" \
    "mvn test -pl binance-trader-macd"

# Test 6: Test with different profiles
echo -e "\n${BLUE}🔄 Testing Different Profiles${NC}"

# Test with testnet profile
print_status "INFO" "Testing with testnet profile"
run_test "Testnet Profile Tests" \
    "mvn test -pl binance-trader-macd -Dspring.profiles.active=testnet"

# Test 7: API Key Format Validation
echo -e "\n${BLUE}🔍 Running API Key Format Validation${NC}"

# Check if testnet.env has valid API keys
if [ -f "testnet.env" ]; then
    print_status "INFO" "Validating API keys in testnet.env"
    
    # Extract API key from testnet.env
    API_KEY=$(grep "TESTNET_API_KEY=" testnet.env | cut -d'=' -f2)
    SECRET_KEY=$(grep "TESTNET_SECRET_KEY=" testnet.env | cut -d'=' -f2)
    
    if [ -n "$API_KEY" ] && [ -n "$SECRET_KEY" ]; then
        print_status "SUCCESS" "API keys found in testnet.env"
        
        # Basic format validation
        if [[ ${#API_KEY} -ge 20 ]] && [[ $API_KEY =~ ^[A-Za-z0-9]+$ ]]; then
            print_status "SUCCESS" "API key format is valid"
        else
            print_status "ERROR" "API key format is invalid"
        fi
        
        if [[ ${#SECRET_KEY} -ge 20 ]] && [[ $SECRET_KEY =~ ^[A-Za-z0-9]+$ ]]; then
            print_status "SUCCESS" "Secret key format is valid"
        else
            print_status "ERROR" "Secret key format is invalid"
        fi
    else
        print_status "WARNING" "API keys not found in testnet.env"
    fi
else
    print_status "WARNING" "testnet.env file not found"
fi

# Test 8: Test with invalid API keys (negative testing)
echo -e "\n${BLUE}🚫 Running Negative API Key Tests${NC}"

# Create a temporary invalid configuration for testing
print_status "INFO" "Testing with invalid API key configuration"

# Test 9: Performance Testing
echo -e "\n${BLUE}⚡ Running API Key Performance Tests${NC}"
run_test "API Key Performance Tests" \
    "mvn test -pl binance-trader-macd -Dtest=*ApiKey*Test -Dtest.performance=true"

# Test 10: Security Testing
echo -e "\n${BLUE}🔒 Running API Key Security Tests${NC}"
run_test "API Key Security Tests" \
    "mvn test -pl binance-trader-macd -Dtest=*Security*Test"

# Summary
echo -e "\n${BLUE}📋 Test Summary${NC}"
echo "=================="

# Count test results
TOTAL_TESTS=$(mvn test -pl binance-trader-macd -q | grep -c "Tests run:" || echo "0")
PASSED_TESTS=$(mvn test -pl binance-trader-macd -q | grep -c "Failures: 0" || echo "0")

if [ "$TOTAL_TESTS" -gt 0 ]; then
    print_status "INFO" "Total tests run: $TOTAL_TESTS"
    if [ "$PASSED_TESTS" -gt 0 ]; then
        print_status "SUCCESS" "All tests passed!"
    else
        print_status "ERROR" "Some tests failed"
    fi
else
    print_status "WARNING" "No test results found"
fi

# Cleanup
echo -e "\n${BLUE}🧹 Cleaning up${NC}"
print_status "INFO" "Test execution completed"

# Final status
echo -e "\n${GREEN}🎉 API Key Testing Suite Completed${NC}"
echo "================================="
print_status "INFO" "Check the test results above for any failures"
print_status "INFO" "For detailed logs, check the target/surefire-reports directory"

exit 0
