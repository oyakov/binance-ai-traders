# API Key Testing Script for Binance AI Traders (PowerShell Version)
# This script runs comprehensive API key validation tests

param(
    [switch]$Verbose,
    [switch]$SkipUnitTests,
    [switch]$SkipIntegrationTests,
    [switch]$SkipComprehensiveTests,
    [switch]$SkipConnectivityTests
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Colors for output
$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Cyan"
    White = "White"
}

# Function to print colored output
function Write-Status {
    param(
        [string]$Status,
        [string]$Message
    )
    
    switch ($Status) {
        "SUCCESS" { Write-Host "✅ $Message" -ForegroundColor $Colors.Green }
        "ERROR" { Write-Host "❌ $Message" -ForegroundColor $Colors.Red }
        "WARNING" { Write-Host "⚠️  $Message" -ForegroundColor $Colors.Yellow }
        "INFO" { Write-Host "ℹ️  $Message" -ForegroundColor $Colors.Blue }
        default { Write-Host "ℹ️  $Message" -ForegroundColor $Colors.White }
    }
}

# Function to run tests and capture results
function Invoke-Test {
    param(
        [string]$TestName,
        [string]$TestCommand
    )
    
    Write-Host "`n🔵 Running: $TestName" -ForegroundColor $Colors.Blue
    Write-Host "Command: $TestCommand" -ForegroundColor $Colors.White
    Write-Host "----------------------------------------" -ForegroundColor $Colors.White
    
    try {
        Invoke-Expression $TestCommand
        if ($LASTEXITCODE -eq 0) {
            Write-Status "SUCCESS" "$TestName completed successfully"
            return $true
        } else {
            Write-Status "ERROR" "$TestName failed with exit code $LASTEXITCODE"
            return $false
        }
    } catch {
        Write-Status "ERROR" "$TestName failed with exception: $($_.Exception.Message)"
        return $false
    }
}

# Check if we're in the project root
if (-not (Test-Path "pom.xml")) {
    Write-Status "ERROR" "Please run this script from the project root directory"
    exit 1
}

# Check if Maven is available
try {
    $mvnVersion = mvn --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Maven not found"
    }
} catch {
    Write-Status "ERROR" "Maven is not installed or not in PATH"
    exit 1
}

# Check if testnet.env exists
if (-not (Test-Path "testnet.env")) {
    Write-Status "WARNING" "testnet.env file not found. Some tests may fail."
}

Write-Status "INFO" "Project structure validated"

Write-Host "`n🔐 Starting API Key Testing Suite" -ForegroundColor $Colors.Blue
Write-Host "=================================" -ForegroundColor $Colors.Blue

# Test 1: Unit Tests for API Key Validation
if (-not $SkipUnitTests) {
    Write-Host "`n🧪 Running API Key Unit Tests" -ForegroundColor $Colors.Blue
    $unitTestResult = Invoke-Test "API Key Validation Unit Tests" "mvn test -pl binance-trader-macd -Dtest=ApiKeyValidationTest"
}

# Test 2: Integration Tests
if (-not $SkipIntegrationTests) {
    Write-Host "`n🔗 Running API Key Integration Tests" -ForegroundColor $Colors.Blue
    $integrationTestResult = Invoke-Test "API Key Integration Tests" "mvn test -pl binance-trader-macd -Dtest=ApiKeyIntegrationTest"
}

# Test 3: Comprehensive API Key Tests
if (-not $SkipComprehensiveTests) {
    Write-Host "`n📊 Running Comprehensive API Key Tests" -ForegroundColor $Colors.Blue
    $comprehensiveTestResult = Invoke-Test "Comprehensive API Key Tests" "mvn test -pl binance-trader-macd -Dtest=ApiKeyComprehensiveTest"
}

# Test 4: Binance API Connectivity Tests
if (-not $SkipConnectivityTests) {
    Write-Host "`n🌐 Running Binance API Connectivity Tests" -ForegroundColor $Colors.Blue
    $connectivityTestResult = Invoke-Test "Binance API Connectivity Tests" "mvn test -pl binance-trader-macd -Dtest=BinanceApiKeyConnectivityTest"
}

# Test 5: All MACD Trader Tests (including API key tests)
Write-Host "`n🎯 Running All MACD Trader Tests" -ForegroundColor $Colors.Blue
$allTestsResult = Invoke-Test "All MACD Trader Tests" "mvn test -pl binance-trader-macd"

# Test 6: Test with different profiles
Write-Host "`n🔄 Testing Different Profiles" -ForegroundColor $Colors.Blue

# Test with testnet profile
Write-Status "INFO" "Testing with testnet profile"
$testnetProfileResult = Invoke-Test "Testnet Profile Tests" "mvn test -pl binance-trader-macd -Dspring.profiles.active=testnet"

# Test 7: API Key Format Validation
Write-Host "`n🔍 Running API Key Format Validation" -ForegroundColor $Colors.Blue

# Check if testnet.env has valid API keys
if (Test-Path "testnet.env") {
    Write-Status "INFO" "Validating API keys in testnet.env"
    
    # Extract API key from testnet.env
    $envContent = Get-Content "testnet.env"
    $apiKeyLine = $envContent | Where-Object { $_ -match "^TESTNET_API_KEY=" }
    $secretKeyLine = $envContent | Where-Object { $_ -match "^TESTNET_SECRET_KEY=" }
    
    if ($apiKeyLine -and $secretKeyLine) {
        $apiKey = ($apiKeyLine -split "=", 2)[1]
        $secretKey = ($secretKeyLine -split "=", 2)[1]
        
        Write-Status "SUCCESS" "API keys found in testnet.env"
        
        # Basic format validation
        if ($apiKey.Length -ge 20 -and $apiKey -match "^[A-Za-z0-9]+$") {
            Write-Status "SUCCESS" "API key format is valid"
        } else {
            Write-Status "ERROR" "API key format is invalid"
        }
        
        if ($secretKey.Length -ge 20 -and $secretKey -match "^[A-Za-z0-9]+$") {
            Write-Status "SUCCESS" "Secret key format is valid"
        } else {
            Write-Status "ERROR" "Secret key format is invalid"
        }
    } else {
        Write-Status "WARNING" "API keys not found in testnet.env"
    }
} else {
    Write-Status "WARNING" "testnet.env file not found"
}

# Test 8: Test with invalid API keys (negative testing)
Write-Host "`n🚫 Running Negative API Key Tests" -ForegroundColor $Colors.Blue
Write-Status "INFO" "Testing with invalid API key configuration"

# Test 9: Performance Testing
Write-Host "`n⚡ Running API Key Performance Tests" -ForegroundColor $Colors.Blue
$performanceTestResult = Invoke-Test "API Key Performance Tests" "mvn test -pl binance-trader-macd -Dtest=*ApiKey*Test"

# Test 10: Security Testing
Write-Host "`n🔒 Running API Key Security Tests" -ForegroundColor $Colors.Blue
$securityTestResult = Invoke-Test "API Key Security Tests" "mvn test -pl binance-trader-macd -Dtest=*Security*Test"

# Summary
Write-Host "`n📋 Test Summary" -ForegroundColor $Colors.Blue
Write-Host "==================" -ForegroundColor $Colors.Blue

# Count test results
try {
    $testOutput = mvn test -pl binance-trader-macd -q 2>$null
    $totalTests = ($testOutput | Select-String "Tests run:" | Measure-Object).Count
    $passedTests = ($testOutput | Select-String "Failures: 0" | Measure-Object).Count
    
    if ($totalTests -gt 0) {
        Write-Status "INFO" "Total tests run: $totalTests"
        if ($passedTests -gt 0) {
            Write-Status "SUCCESS" "All tests passed!"
        } else {
            Write-Status "ERROR" "Some tests failed"
        }
    } else {
        Write-Status "WARNING" "No test results found"
    }
} catch {
    Write-Status "WARNING" "Could not parse test results"
}

# Cleanup
Write-Host "`n🧹 Cleaning up" -ForegroundColor $Colors.Blue
Write-Status "INFO" "Test execution completed"

# Final status
Write-Host "`n🎉 API Key Testing Suite Completed" -ForegroundColor $Colors.Green
Write-Host "=================================" -ForegroundColor $Colors.Green
Write-Status "INFO" "Check the test results above for any failures"
Write-Status "INFO" "For detailed logs, check the target/surefire-reports directory"

# Return appropriate exit code
if ($allTestsResult) {
    exit 0
} else {
    exit 1
}
