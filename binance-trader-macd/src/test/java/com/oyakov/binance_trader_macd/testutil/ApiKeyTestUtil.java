package com.oyakov.binance_trader_macd.testutil;

import com.oyakov.binance_trader_macd.config.MACDTraderConfig;
import com.oyakov.binance_trader_macd.security.ApiKeyValidationResult;
import com.oyakov.binance_trader_macd.security.ApiKeyValidator;
import java.util.HashMap;
import java.util.Map;

/**
 * Utility class for API key testing across the project.
 * Provides common test scenarios and helper methods for API key validation.
 */
public class ApiKeyTestUtil {

    private ApiKeyValidator apiKeyValidator;

    public void setApiKeyValidator(ApiKeyValidator apiKeyValidator) {
        this.apiKeyValidator = apiKeyValidator;
    }

    /**
     * Test scenarios for API key validation
     */
    public enum TestScenario {
        VALID_TESTNET,
        VALID_MAINNET,
        INVALID_API_KEY,
        INVALID_SECRET_KEY,
        INVALID_BASE_URL,
        MISSING_API_KEY,
        MISSING_SECRET_KEY,
        MISSING_BASE_URL,
        NULL_CONFIGURATION,
        EMPTY_CONFIGURATION
    }

    /**
     * Creates a test configuration for the specified scenario
     */
    public MACDTraderConfig createTestConfiguration(TestScenario scenario) {
        MACDTraderConfig config = new MACDTraderConfig();
        MACDTraderConfig.Rest rest = new MACDTraderConfig.Rest();

        switch (scenario) {
            case VALID_TESTNET:
                rest.setApiToken("F4vS8U6mvUXST5TVbQbnMlUL4jOpQiI1Iy8QlVqXpVNMAxplu8pamFDZLB5mpOwU");
                rest.setSecretApiToken("N26b6O6QlHmprRf40wEECqAEQjaD4ijMdIx5GRdBk0e34iTnVDRmFxZzrjgleT20");
                rest.setBaseUrl("https://testnet.binance.vision");
                break;

            case VALID_MAINNET:
                rest.setApiToken("F4vS8U6mvUXST5TVbQbnMlUL4jOpQiI1Iy8QlVqXpVNMAxplu8pamFDZLB5mpOwU");
                rest.setSecretApiToken("N26b6O6QlHmprRf40wEECqAEQjaD4ijMdIx5GRdBk0e34iTnVDRmFxZzrjgleT20");
                rest.setBaseUrl("https://api.binance.com");
                break;

            case INVALID_API_KEY:
                rest.setApiToken("invalid-api-key");
                rest.setSecretApiToken("N26b6O6QlHmprRf40wEECqAEQjaD4ijMdIx5GRdBk0e34iTnVDRmFxZzrjgleT20");
                rest.setBaseUrl("https://testnet.binance.vision");
                break;

            case INVALID_SECRET_KEY:
                rest.setApiToken("F4vS8U6mvUXST5TVbQbnMlUL4jOpQiI1Iy8QlVqXpVNMAxplu8pamFDZLB5mpOwU");
                rest.setSecretApiToken("invalid-secret-key");
                rest.setBaseUrl("https://testnet.binance.vision");
                break;

            case INVALID_BASE_URL:
                rest.setApiToken("F4vS8U6mvUXST5TVbQbnMlUL4jOpQiI1Iy8QlVqXpVNMAxplu8pamFDZLB5mpOwU");
                rest.setSecretApiToken("N26b6O6QlHmprRf40wEECqAEQjaD4ijMdIx5GRdBk0e34iTnVDRmFxZzrjgleT20");
                rest.setBaseUrl("https://invalid-url.com");
                break;

            case MISSING_API_KEY:
                rest.setApiToken(null);
                rest.setSecretApiToken("N26b6O6QlHmprRf40wEECqAEQjaD4ijMdIx5GRdBk0e34iTnVDRmFxZzrjgleT20");
                rest.setBaseUrl("https://testnet.binance.vision");
                break;

            case MISSING_SECRET_KEY:
                rest.setApiToken("F4vS8U6mvUXST5TVbQbnMlUL4jOpQiI1Iy8QlVqXpVNMAxplu8pamFDZLB5mpOwU");
                rest.setSecretApiToken(null);
                rest.setBaseUrl("https://testnet.binance.vision");
                break;

            case MISSING_BASE_URL:
                rest.setApiToken("F4vS8U6mvUXST5TVbQbnMlUL4jOpQiI1Iy8QlVqXpVNMAxplu8pamFDZLB5mpOwU");
                rest.setSecretApiToken("N26b6O6QlHmprRf40wEECqAEQjaD4ijMdIx5GRdBk0e34iTnVDRmFxZzrjgleT20");
                rest.setBaseUrl(null);
                break;

            case EMPTY_CONFIGURATION:
                // Leave rest as default (null values)
                break;

            case NULL_CONFIGURATION:
                return null;
        }

        config.setRest(rest);
        return config;
    }

    /**
     * Validates a test scenario and returns the result
     */
    public ApiKeyValidationResult validateScenario(TestScenario scenario) {
        MACDTraderConfig config = createTestConfiguration(scenario);
        return apiKeyValidator.validateApiCredentials(config);
    }

    /**
     * Validates a test scenario for a specific environment
     */
    public ApiKeyValidationResult validateScenarioForEnvironment(TestScenario scenario, boolean expectTestnet) {
        MACDTraderConfig config = createTestConfiguration(scenario);
        return apiKeyValidator.validateApiCredentialsForEnvironment(config, expectTestnet);
    }

    /**
     * Runs all test scenarios and returns a summary
     */
    public Map<TestScenario, ApiKeyValidationResult> runAllScenarios() {
        Map<TestScenario, ApiKeyValidationResult> results = new HashMap<>();
        
        for (TestScenario scenario : TestScenario.values()) {
            results.put(scenario, validateScenario(scenario));
        }
        
        return results;
    }

    /**
     * Validates that a scenario produces the expected result
     */
    public boolean validateScenarioExpectation(TestScenario scenario, boolean expectedValid, boolean expectedTestnet) {
        ApiKeyValidationResult result = validateScenario(scenario);
        return result.isValid() == expectedValid && result.isTestnet() == expectedTestnet;
    }

    /**
     * Creates a configuration with custom values
     */
    public MACDTraderConfig createCustomConfiguration(String apiKey, String secretKey, String baseUrl) {
        MACDTraderConfig config = new MACDTraderConfig();
        MACDTraderConfig.Rest rest = new MACDTraderConfig.Rest();
        
        rest.setApiToken(apiKey);
        rest.setSecretApiToken(secretKey);
        rest.setBaseUrl(baseUrl);
        config.setRest(rest);
        
        return config;
    }

    /**
     * Generates a valid test API key for testing purposes
     */
    public String generateValidTestApiKey() {
        return "TEST" + System.currentTimeMillis() + "APIKEY" + (int)(Math.random() * 1000);
    }

    /**
     * Generates a valid test secret key for testing purposes
     */
    public String generateValidTestSecretKey() {
        return "TEST" + System.currentTimeMillis() + "SECRET" + (int)(Math.random() * 1000);
    }

    /**
     * Creates a valid test configuration with generated keys
     */
    public MACDTraderConfig createValidTestConfiguration(boolean testnet) {
        String apiKey = generateValidTestApiKey();
        String secretKey = generateValidTestSecretKey();
        String baseUrl = testnet ? "https://testnet.binance.vision" : "https://api.binance.com";
        
        return createCustomConfiguration(apiKey, secretKey, baseUrl);
    }

    /**
     * Validates that the configuration is properly loaded from environment
     */
    public boolean validateEnvironmentConfiguration(MACDTraderConfig config) {
        if (config == null || config.getRest() == null) {
            return false;
        }
        
        MACDTraderConfig.Rest rest = config.getRest();
        return rest.getApiToken() != null && 
               rest.getSecretApiToken() != null && 
               rest.getBaseUrl() != null &&
               apiKeyValidator.isValidApiKeyFormat(rest.getApiToken()) &&
               apiKeyValidator.isValidSecretKeyFormat(rest.getSecretApiToken()) &&
               apiKeyValidator.isValidBaseUrl(rest.getBaseUrl());
    }

    /**
     * Prints a detailed validation report
     */
    public void printValidationReport(Map<TestScenario, ApiKeyValidationResult> results) {
        System.out.println("=== API Key Validation Report ===");
        System.out.println();
        
        for (Map.Entry<TestScenario, ApiKeyValidationResult> entry : results.entrySet()) {
            TestScenario scenario = entry.getKey();
            ApiKeyValidationResult result = entry.getValue();
            
            System.out.printf("Scenario: %s%n", scenario);
            System.out.printf("  Valid: %s%n", result.isValid());
            System.out.printf("  Environment: %s%n", result.getEnvironment());
            System.out.printf("  Errors: %s%n", result.getErrorSummary());
            System.out.println();
        }
    }
}
