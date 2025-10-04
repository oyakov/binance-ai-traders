package com.oyakov.binance_trader_macd.comprehensive;

import com.oyakov.binance_trader_macd.config.MACDTraderConfig;
import com.oyakov.binance_trader_macd.security.ApiKeyValidationResult;
import com.oyakov.binance_trader_macd.security.ApiKeyValidator;
import com.oyakov.binance_trader_macd.testutil.ApiKeyTestUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("Comprehensive API Key Testing Suite")
class ApiKeyComprehensiveTest {

    private ApiKeyTestUtil apiKeyTestUtil;
    private ApiKeyValidator apiKeyValidator;

    @BeforeEach
    void setUp() {
        apiKeyValidator = new ApiKeyValidator();
        apiKeyTestUtil = new ApiKeyTestUtil();
        // Manually inject the validator since we're not using Spring context
        apiKeyTestUtil.setApiKeyValidator(apiKeyValidator);
    }

    @Test
    @DisplayName("Should validate all test scenarios correctly")
    void shouldValidateAllTestScenariosCorrectly() {
        // Act
        Map<ApiKeyTestUtil.TestScenario, ApiKeyValidationResult> results = 
                apiKeyTestUtil.runAllScenarios();

        // Assert - Valid scenarios should pass
        assertTrue(results.get(ApiKeyTestUtil.TestScenario.VALID_TESTNET).isValid(), 
                  "Valid testnet scenario should pass");
        assertTrue(results.get(ApiKeyTestUtil.TestScenario.VALID_MAINNET).isValid(), 
                  "Valid mainnet scenario should pass");

        // Assert - Invalid scenarios should fail
        assertFalse(results.get(ApiKeyTestUtil.TestScenario.INVALID_API_KEY).isValid(), 
                   "Invalid API key scenario should fail");
        assertFalse(results.get(ApiKeyTestUtil.TestScenario.INVALID_SECRET_KEY).isValid(), 
                   "Invalid secret key scenario should fail");
        assertFalse(results.get(ApiKeyTestUtil.TestScenario.INVALID_BASE_URL).isValid(), 
                   "Invalid base URL scenario should fail");
        assertFalse(results.get(ApiKeyTestUtil.TestScenario.MISSING_API_KEY).isValid(), 
                   "Missing API key scenario should fail");
        assertFalse(results.get(ApiKeyTestUtil.TestScenario.MISSING_SECRET_KEY).isValid(), 
                   "Missing secret key scenario should fail");
        assertFalse(results.get(ApiKeyTestUtil.TestScenario.MISSING_BASE_URL).isValid(), 
                   "Missing base URL scenario should fail");
        assertFalse(results.get(ApiKeyTestUtil.TestScenario.EMPTY_CONFIGURATION).isValid(), 
                   "Empty configuration scenario should fail");
        assertFalse(results.get(ApiKeyTestUtil.TestScenario.NULL_CONFIGURATION).isValid(), 
                   "Null configuration scenario should fail");

        // Print detailed report
        apiKeyTestUtil.printValidationReport(results);
    }

    @Test
    @DisplayName("Should correctly identify testnet vs mainnet environments")
    void shouldCorrectlyIdentifyTestnetVsMainnetEnvironments() {
        // Test testnet identification
        ApiKeyValidationResult testnetResult = apiKeyTestUtil.validateScenario(
                ApiKeyTestUtil.TestScenario.VALID_TESTNET);
        assertTrue(testnetResult.isTestnet(), "Should identify testnet environment");
        assertFalse(testnetResult.isMainnet(), "Should not identify as mainnet");

        // Test mainnet identification
        ApiKeyValidationResult mainnetResult = apiKeyTestUtil.validateScenario(
                ApiKeyTestUtil.TestScenario.VALID_MAINNET);
        assertFalse(mainnetResult.isTestnet(), "Should not identify as testnet");
        assertTrue(mainnetResult.isMainnet(), "Should identify mainnet environment");
    }

    @Test
    @DisplayName("Should validate environment-specific expectations")
    void shouldValidateEnvironmentSpecificExpectations() {
        // Test testnet expectation with testnet config
        ApiKeyValidationResult testnetExpectation = apiKeyTestUtil.validateScenarioForEnvironment(
                ApiKeyTestUtil.TestScenario.VALID_TESTNET, true);
        assertTrue(testnetExpectation.isValid(), 
                  "Valid testnet config should pass testnet expectation");

        // Test mainnet expectation with testnet config (should fail)
        ApiKeyValidationResult mainnetExpectation = apiKeyTestUtil.validateScenarioForEnvironment(
                ApiKeyTestUtil.TestScenario.VALID_TESTNET, false);
        assertFalse(mainnetExpectation.isValid(), 
                   "Testnet config should fail mainnet expectation");

        // Test mainnet expectation with mainnet config
        ApiKeyValidationResult validMainnetExpectation = apiKeyTestUtil.validateScenarioForEnvironment(
                ApiKeyTestUtil.TestScenario.VALID_MAINNET, false);
        assertTrue(validMainnetExpectation.isValid(), 
                  "Valid mainnet config should pass mainnet expectation");
    }

    @Test
    @DisplayName("Should generate valid test configurations")
    void shouldGenerateValidTestConfigurations() {
        // Test testnet configuration generation
        MACDTraderConfig testnetConfig = apiKeyTestUtil.createValidTestConfiguration(true);
        assertNotNull(testnetConfig, "Generated testnet config should not be null");
        assertTrue(apiKeyTestUtil.validateEnvironmentConfiguration(testnetConfig), 
                  "Generated testnet config should be valid");

        // Test mainnet configuration generation
        MACDTraderConfig mainnetConfig = apiKeyTestUtil.createValidTestConfiguration(false);
        assertNotNull(mainnetConfig, "Generated mainnet config should not be null");
        assertTrue(apiKeyTestUtil.validateEnvironmentConfiguration(mainnetConfig), 
                  "Generated mainnet config should be valid");
    }

    @Test
    @DisplayName("Should validate custom configurations")
    void shouldValidateCustomConfigurations() {
        // Test with valid custom configuration
        MACDTraderConfig validCustomConfig = apiKeyTestUtil.createCustomConfiguration(
                "CUSTOMAPIKEY12345678901234567890",
                "CUSTOMSECRETKEY12345678901234567890",
                "https://testnet.binance.vision"
        );
        assertTrue(apiKeyTestUtil.validateEnvironmentConfiguration(validCustomConfig), 
                  "Valid custom config should be valid");

        // Test with invalid custom configuration
        MACDTraderConfig invalidCustomConfig = apiKeyTestUtil.createCustomConfiguration(
                "short",
                "also_short",
                "invalid-url"
        );
        assertFalse(apiKeyTestUtil.validateEnvironmentConfiguration(invalidCustomConfig), 
                   "Invalid custom config should be invalid");
    }

    @Test
    @DisplayName("Should validate scenario expectations correctly")
    void shouldValidateScenarioExpectationsCorrectly() {
        // Test valid scenarios
        assertTrue(apiKeyTestUtil.validateScenarioExpectation(
                ApiKeyTestUtil.TestScenario.VALID_TESTNET, true, true), 
                  "Valid testnet should meet expectations");
        assertTrue(apiKeyTestUtil.validateScenarioExpectation(
                ApiKeyTestUtil.TestScenario.VALID_MAINNET, true, false), 
                  "Valid mainnet should meet expectations");

        // Test invalid scenarios
        assertTrue(apiKeyTestUtil.validateScenarioExpectation(
                ApiKeyTestUtil.TestScenario.INVALID_API_KEY, false, true), 
                  "Invalid API key should meet expectations");
        assertTrue(apiKeyTestUtil.validateScenarioExpectation(
                ApiKeyTestUtil.TestScenario.MISSING_SECRET_KEY, false, true), 
                  "Missing secret key should meet expectations");
    }

    @Test
    @DisplayName("Should provide detailed error information")
    void shouldProvideDetailedErrorInformation() {
        // Test invalid API key scenario
        ApiKeyValidationResult invalidApiKeyResult = apiKeyTestUtil.validateScenario(
                ApiKeyTestUtil.TestScenario.INVALID_API_KEY);
        assertFalse(invalidApiKeyResult.isValid(), "Invalid API key should be invalid");
        assertTrue(invalidApiKeyResult.hasErrors(), "Should have error details");
        assertTrue(invalidApiKeyResult.getErrorSummary().contains("API key"), 
                  "Should mention API key in error");

        // Test missing configuration scenario
        ApiKeyValidationResult missingConfigResult = apiKeyTestUtil.validateScenario(
                ApiKeyTestUtil.TestScenario.EMPTY_CONFIGURATION);
        assertFalse(missingConfigResult.isValid(), "Empty config should be invalid");
        assertTrue(missingConfigResult.hasErrors(), "Should have error details");
        assertTrue(missingConfigResult.getErrorSummary().contains("API key"), 
                  "Should mention missing API key in error");
    }

    @Test
    @DisplayName("Should handle edge cases gracefully")
    void shouldHandleEdgeCasesGracefully() {
        // Test null configuration
        ApiKeyValidationResult nullResult = apiKeyTestUtil.validateScenario(
                ApiKeyTestUtil.TestScenario.NULL_CONFIGURATION);
        assertFalse(nullResult.isValid(), "Null config should be invalid");
        assertTrue(nullResult.getErrors().contains("Configuration or REST configuration is null"), 
                  "Should report null configuration error");

        // Test empty configuration
        ApiKeyValidationResult emptyResult = apiKeyTestUtil.validateScenario(
                ApiKeyTestUtil.TestScenario.EMPTY_CONFIGURATION);
        assertFalse(emptyResult.isValid(), "Empty config should be invalid");
        assertTrue(emptyResult.hasErrors(), "Should have multiple errors for empty config");
    }

    @Test
    @DisplayName("Should validate API key format requirements")
    void shouldValidateApiKeyFormatRequirements() {
        // Test various API key formats
        String[] validApiKeys = {
                "F4vS8U6mvUXST5TVbQbnMlUL4jOpQiI1Iy8QlVqXpVNMAxplu8pamFDZLB5mpOwU",
                "TEST12345678901234567890",
                "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        };

        String[] invalidApiKeys = {
                null,
                "",
                "   ",
                "short",
                "key with spaces",
                "key-with-dashes",
                "key_with_underscores",
                "key.with.dots",
                "key@with#special$chars"
        };

        // Validate valid keys
        for (String validKey : validApiKeys) {
            MACDTraderConfig config = apiKeyTestUtil.createCustomConfiguration(
                    validKey, "N26b6O6QlHmprRf40wEECqAEQjaD4ijMdIx5GRdBk0e34iTnVDRmFxZzrjgleT20", 
                    "https://testnet.binance.vision");
            assertTrue(apiKeyTestUtil.validateEnvironmentConfiguration(config), 
                      "Valid API key should pass validation: " + validKey);
        }

        // Validate invalid keys
        for (String invalidKey : invalidApiKeys) {
            MACDTraderConfig config = apiKeyTestUtil.createCustomConfiguration(
                    invalidKey, "N26b6O6QlHmprRf40wEECqAEQjaD4ijMdIx5GRdBk0e34iTnVDRmFxZzrjgleT20", 
                    "https://testnet.binance.vision");
            assertFalse(apiKeyTestUtil.validateEnvironmentConfiguration(config), 
                       "Invalid API key should fail validation: " + invalidKey);
        }
    }
}
