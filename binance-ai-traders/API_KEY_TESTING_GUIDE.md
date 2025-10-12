# API Key Testing Guide

## Overview

This guide provides comprehensive information about API key testing in the Binance AI Traders project. The testing framework ensures that API keys are properly validated, configured, and functioning correctly across all environments.

## Table of Contents

1. [API Key Testing Components](#api-key-testing-components)
2. [Test Categories](#test-categories)
3. [Running API Key Tests](#running-api-key-tests)
4. [Test Configuration](#test-configuration)
5. [API Key Validation Rules](#api-key-validation-rules)
6. [Environment-Specific Testing](#environment-specific-testing)
7. [Troubleshooting](#troubleshooting)
8. [Best Practices](#best-practices)

## API Key Testing Components

### Core Components

1. **ApiKeyValidator** - Main validation service
2. **ApiKeyValidationResult** - Result container with detailed error information
3. **ApiKeyTestUtil** - Test utility for creating test scenarios
4. **Test Classes** - Comprehensive test suites

### Test Classes

- `ApiKeyValidationTest` - Unit tests for API key validation
- `ApiKeyIntegrationTest` - Integration tests with Spring context
- `ApiKeyComprehensiveTest` - Comprehensive test scenarios
- `BinanceApiKeyConnectivityTest` - Real API connectivity tests

## Test Categories

### 1. Unit Tests
- **Purpose**: Test individual API key validation methods
- **Scope**: Format validation, length checks, character validation
- **Location**: `src/test/java/com/oyakov/binance_trader_macd/security/ApiKeyValidationTest.java`

### 2. Integration Tests
- **Purpose**: Test API key validation within Spring context
- **Scope**: Configuration loading, environment detection, dependency injection
- **Location**: `src/test/java/com/oyakov/binance_trader_macd/integration/ApiKeyIntegrationTest.java`

### 3. Comprehensive Tests
- **Purpose**: Test all possible API key scenarios
- **Scope**: Multiple test scenarios, edge cases, error conditions
- **Location**: `src/test/java/com/oyakov/binance_trader_macd/comprehensive/ApiKeyComprehensiveTest.java`

### 4. Connectivity Tests
- **Purpose**: Test actual API connectivity with real credentials
- **Scope**: Real API calls, environment validation, configuration verification
- **Location**: `src/test/java/com/oyakov/binance_trader_macd/integration/BinanceApiKeyConnectivityTest.java`

## Running API Key Tests

### Quick Start

```bash
# Run all API key tests
./scripts/test-api-keys.sh

# On Windows
.\scripts\test-api-keys.ps1
```

### Individual Test Execution

```bash
# Unit tests only
mvn test -pl binance-trader-macd -Dtest=ApiKeyValidationTest

# Integration tests only
mvn test -pl binance-trader-macd -Dtest=ApiKeyIntegrationTest

# Comprehensive tests only
mvn test -pl binance-trader-macd -Dtest=ApiKeyComprehensiveTest

# Connectivity tests only
mvn test -pl binance-trader-macd -Dtest=BinanceApiKeyConnectivityTest
```

### Profile-Specific Testing

```bash
# Test with testnet profile
mvn test -pl binance-trader-macd -Dspring.profiles.active=testnet

# Test with mainnet profile
mvn test -pl binance-trader-macd -Dspring.profiles.active=mainnet
```

## Test Configuration

### Environment Variables

The tests use the following environment variables from `testnet.env`:

```bash
# Testnet API Credentials
TESTNET_API_KEY=F4vS8U6mvUXST5TVbQbnMlUL4jOpQiI1Iy8QlVqXpVNMAxplu8pamFDZLB5mpOwU
TESTNET_SECRET_KEY=N26b6O6QlHmprRf40wEECqAEQjaD4ijMdIx5GRdBk0e34iTnVDRmFxZzrjgleT20

# Additional testnet configuration
BINANCE_REST_BASE_URL=https://testnet.binance.vision
BINANCE_API_KEY=F4vS8U6mvUXST5TVbQbnMlUL4jOpQiI1Iy8QlVqXpVNMAxplu8pamFDZLB5mpOwU
BINANCE_API_SECRET=N26b6O6QlHmprRf40wEECqAEQjaD4ijMdIx5GRdBk0e34iTnVDRmFxZzrjgleT20
BINANCE_TRADER_TEST_ORDER_MODE_ENABLED=true
```

### Test Scenarios

The `ApiKeyTestUtil` provides the following test scenarios:

- `VALID_TESTNET` - Valid testnet configuration
- `VALID_MAINNET` - Valid mainnet configuration
- `INVALID_API_KEY` - Invalid API key format
- `INVALID_SECRET_KEY` - Invalid secret key format
- `INVALID_BASE_URL` - Invalid base URL
- `MISSING_API_KEY` - Missing API key
- `MISSING_SECRET_KEY` - Missing secret key
- `MISSING_BASE_URL` - Missing base URL
- `NULL_CONFIGURATION` - Null configuration
- `EMPTY_CONFIGURATION` - Empty configuration

## API Key Validation Rules

### Format Requirements

1. **Length**: 20-100 characters
2. **Characters**: Alphanumeric only (A-Z, a-z, 0-9)
3. **No special characters**: No spaces, dashes, underscores, or symbols
4. **Not empty**: Cannot be null, empty, or whitespace-only

### Security Requirements

1. **Not placeholder values**: Cannot be "your-api-key-here" or similar
2. **Mixed content**: Should contain both letters and numbers
3. **Reasonable length**: Should be at least 30 characters for security
4. **Environment-specific**: Must match expected environment (testnet/mainnet)

### Base URL Requirements

1. **HTTPS only**: Must use HTTPS protocol
2. **Valid Binance URLs**: Must be from binance.com or binance.vision domains
3. **Environment matching**: Must match expected environment

## Environment-Specific Testing

### Testnet Testing

```java
// Validate testnet configuration
ApiKeyValidationResult result = apiKeyValidator.validateApiCredentialsForEnvironment(
    config, true); // expectTestnet = true

assertTrue(result.isValid());
assertTrue(result.isTestnet());
```

### Mainnet Testing

```java
// Validate mainnet configuration
ApiKeyValidationResult result = apiKeyValidator.validateApiCredentialsForEnvironment(
    config, false); // expectTestnet = false

assertTrue(result.isValid());
assertTrue(result.isMainnet());
```

## Troubleshooting

### Common Issues

1. **API Key Format Invalid**
   - **Cause**: API key doesn't meet format requirements
   - **Solution**: Check length (20-100 chars) and characters (alphanumeric only)

2. **Missing Configuration**
   - **Cause**: Environment variables not loaded
   - **Solution**: Ensure `testnet.env` exists and is properly formatted

3. **Environment Mismatch**
   - **Cause**: Configuration doesn't match expected environment
   - **Solution**: Check base URL matches expected environment

4. **Test Failures**
   - **Cause**: Invalid test data or configuration
   - **Solution**: Use `ApiKeyTestUtil` to create valid test configurations

### Debug Mode

Enable debug logging to see detailed validation information:

```bash
mvn test -pl binance-trader-macd -Dtest=ApiKeyValidationTest -Dlogging.level.com.oyakov.binance_trader_macd.security=DEBUG
```

### Test Reports

Check test reports for detailed failure information:

```bash
# View test reports
ls target/surefire-reports/

# View specific test report
cat target/surefire-reports/com.oyakov.binance_trader_macd.security.ApiKeyValidationTest.txt
```

## Best Practices

### 1. Test Data Management

- Use `ApiKeyTestUtil` for consistent test data
- Never use real production API keys in tests
- Use environment-specific test configurations

### 2. Test Organization

- Group related tests together
- Use descriptive test names
- Include both positive and negative test cases

### 3. Error Handling

- Test all error conditions
- Verify error messages are informative
- Test edge cases and boundary conditions

### 4. Security

- Never commit real API keys to version control
- Use environment variables for sensitive data
- Validate API keys before making real API calls

### 5. Performance

- Run tests in parallel when possible
- Use mocked services for unit tests
- Use real services only for integration tests

## Example Usage

### Basic Validation

```java
@Autowired
private ApiKeyValidator apiKeyValidator;

@Test
void testApiKeyValidation() {
    ApiKeyValidationResult result = apiKeyValidator.validateApiCredentials(config);
    
    assertTrue(result.isValid());
    assertTrue(result.getErrors().isEmpty());
}
```

### Environment-Specific Validation

```java
@Test
void testTestnetValidation() {
    ApiKeyValidationResult result = apiKeyValidator.validateApiCredentialsForEnvironment(
        config, true);
    
    assertTrue(result.isValid());
    assertTrue(result.isTestnet());
}
```

### Using Test Utilities

```java
@Autowired
private ApiKeyTestUtil apiKeyTestUtil;

@Test
void testAllScenarios() {
    Map<TestScenario, ApiKeyValidationResult> results = 
        apiKeyTestUtil.runAllScenarios();
    
    // Validate results
    assertTrue(results.get(TestScenario.VALID_TESTNET).isValid());
    assertFalse(results.get(TestScenario.INVALID_API_KEY).isValid());
}
```

## Integration with CI/CD

### GitHub Actions

```yaml
- name: Run API Key Tests
  run: |
    ./scripts/test-api-keys.sh
  env:
    TESTNET_API_KEY: ${{ secrets.TESTNET_API_KEY }}
    TESTNET_SECRET_KEY: ${{ secrets.TESTNET_SECRET_KEY }}
```

### Jenkins Pipeline

```groovy
stage('API Key Testing') {
    steps {
        sh './scripts/test-api-keys.sh'
    }
    environment {
        TESTNET_API_KEY = credentials('testnet-api-key')
        TESTNET_SECRET_KEY = credentials('testnet-secret-key')
    }
}
```

## Conclusion

The API key testing framework provides comprehensive validation and testing capabilities for the Binance AI Traders project. By following this guide, you can ensure that API keys are properly validated, configured, and functioning correctly across all environments.

For additional support or questions, please refer to the project documentation or create an issue in the project repository.
