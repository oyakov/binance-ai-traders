package com.oyakov.binance_trader_macd.integration;

import com.oyakov.binance_trader_macd.config.MACDTraderConfig;
import com.oyakov.binance_trader_macd.rest.client.BinanceOrderClient;
import com.oyakov.binance_trader_macd.security.ApiKeyValidator;
import com.oyakov.binance_trader_macd.security.ApiKeyValidationResult;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.web.client.RestTemplate;

import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("API Key Integration Tests")
class ApiKeyIntegrationTest {

    private ApiKeyValidator apiKeyValidator;
    private BinanceOrderClient binanceOrderClient;
    private MACDTraderConfig traderConfig;

    @Mock
    private RestTemplate restTemplate;

    @BeforeEach
    void setUp() {
        apiKeyValidator = new ApiKeyValidator();
        
        // Create test configuration
        traderConfig = new MACDTraderConfig();
        MACDTraderConfig.Rest rest = new MACDTraderConfig.Rest();
        rest.setBaseUrl("https://testnet.binance.vision");
        rest.setApiToken("F4vS8U6mvUXST5TVbQbnMlUL4jOpQiI1Iy8QlVqXpVNMAxplu8pamFDZLB5mpOwU");
        rest.setSecretApiToken("N26b6O6QlHmprRf40wEECqAEQjaD4ijMdIx5GRdBk0e34iTnVDRmFxZzrjgleT20");
        traderConfig.setRest(rest);
        
        binanceOrderClient = new BinanceOrderClient(restTemplate, traderConfig);
    }

    @Test
    @DisplayName("Should load testnet configuration with valid API keys")
    void shouldLoadTestnetConfigurationWithValidApiKeys() {
        // Act
        ApiKeyValidationResult result = apiKeyValidator.validateApiCredentials(traderConfig);

        // Assert
        assertTrue(result.isValid(), "Testnet configuration should be valid");
        assertTrue(result.isTestnet(), "Should detect testnet environment");
        assertTrue(result.getErrors().isEmpty(), "Should have no validation errors");
        
        // Verify configuration is properly loaded
        assertNotNull(traderConfig.getRest().getApiToken(), "API token should be loaded");
        assertNotNull(traderConfig.getRest().getSecretApiToken(), "Secret token should be loaded");
        assertNotNull(traderConfig.getRest().getBaseUrl(), "Base URL should be loaded");
        assertEquals("https://testnet.binance.vision", traderConfig.getRest().getBaseUrl(), 
                    "Should use testnet base URL");
    }

    @Test
    @DisplayName("Should create BinanceOrderClient with valid configuration")
    void shouldCreateBinanceOrderClientWithValidConfiguration() {
        // Assert
        assertNotNull(binanceOrderClient, "BinanceOrderClient should be created");
        
        // Verify that the client has access to the configuration
        assertNotNull(traderConfig, "Trader configuration should be available");
        assertNotNull(traderConfig.getRest(), "REST configuration should be available");
    }

    @Test
    @DisplayName("Should validate API key format from environment")
    void shouldValidateApiKeyFormatFromEnvironment() {
        // Arrange
        String apiKey = traderConfig.getRest().getApiToken();
        String secretKey = traderConfig.getRest().getSecretApiToken();

        // Act & Assert
        assertTrue(apiKeyValidator.isValidApiKeyFormat(apiKey), 
                  "API key from environment should have valid format");
        assertTrue(apiKeyValidator.isValidSecretKeyFormat(secretKey), 
                  "Secret key from environment should have valid format");
    }

    @Test
    @DisplayName("Should detect testnet environment correctly")
    void shouldDetectTestnetEnvironmentCorrectly() {
        // Act
        boolean isTestnet = apiKeyValidator.isTestnetConfiguration(traderConfig);
        boolean isMainnet = apiKeyValidator.isMainnetConfiguration(traderConfig);

        // Assert
        assertTrue(isTestnet, "Should detect testnet environment");
        assertFalse(isMainnet, "Should not detect mainnet environment");
    }

    @Test
    @DisplayName("Should validate configuration for testnet environment")
    void shouldValidateConfigurationForTestnetEnvironment() {
        // Act
        ApiKeyValidationResult result = apiKeyValidator.validateApiCredentialsForEnvironment(
                traderConfig, true);

        // Assert
        assertTrue(result.isValid(), "Testnet configuration should be valid for testnet environment");
        assertTrue(result.isTestnet(), "Should be identified as testnet");
        assertTrue(result.getErrors().isEmpty(), "Should have no validation errors");
    }

    @Test
    @DisplayName("Should reject testnet configuration when expecting mainnet")
    void shouldRejectTestnetConfigurationWhenExpectingMainnet() {
        // Act
        ApiKeyValidationResult result = apiKeyValidator.validateApiCredentialsForEnvironment(
                traderConfig, false);

        // Assert
        assertFalse(result.isValid(), "Testnet configuration should be invalid when expecting mainnet");
        assertTrue(result.getErrors().stream().anyMatch(error -> error.contains("Expected mainnet")), 
                  "Should report mainnet expectation error");
    }

    @Test
    @DisplayName("Should provide detailed error information for invalid configuration")
    void shouldProvideDetailedErrorInformationForInvalidConfiguration() {
        // Arrange - Create invalid configuration
        MACDTraderConfig invalidConfig = new MACDTraderConfig();
        MACDTraderConfig.Rest invalidRest = new MACDTraderConfig.Rest();
        invalidRest.setApiToken(""); // Invalid - empty
        invalidRest.setSecretApiToken("invalid"); // Invalid - too short
        invalidRest.setBaseUrl("invalid-url"); // Invalid URL
        invalidConfig.setRest(invalidRest);

        // Act
        ApiKeyValidationResult result = apiKeyValidator.validateApiCredentials(invalidConfig);

        // Assert
        assertFalse(result.isValid(), "Invalid configuration should fail validation");
        assertTrue(result.hasErrors(), "Should have validation errors");
        assertTrue(result.getErrors().size() >= 3, "Should have multiple validation errors");
        
        // Check specific error messages
        assertTrue(result.getErrors().stream().anyMatch(error -> error.contains("API key")), 
                  "Should report API key error");
        assertTrue(result.getErrors().stream().anyMatch(error -> error.contains("Secret key")), 
                  "Should report secret key error");
        assertTrue(result.getErrors().stream().anyMatch(error -> error.contains("Base URL")), 
                  "Should report base URL error");
    }

    @Test
    @DisplayName("Should handle null configuration gracefully")
    void shouldHandleNullConfigurationGracefully() {
        // Act
        ApiKeyValidationResult result = apiKeyValidator.validateApiCredentials(null);

        // Assert
        assertFalse(result.isValid(), "Null configuration should be invalid");
        assertTrue(result.getErrors().contains("Configuration or REST configuration is null"), 
                  "Should report null configuration error");
    }

    @Test
    @DisplayName("Should validate API key length requirements")
    void shouldValidateApiKeyLengthRequirements() {
        // Test minimum length
        assertFalse(apiKeyValidator.isValidApiKeyFormat("short"), 
                   "API key shorter than minimum should be invalid");
        
        // Test maximum length
        String longApiKey = "a".repeat(101);
        assertFalse(apiKeyValidator.isValidApiKeyFormat(longApiKey), 
                   "API key longer than maximum should be invalid");
        
        // Test valid length
        String validApiKey = "F4vS8U6mvUXST5TVbQbnMlUL4jOpQiI1Iy8QlVqXpVNMAxplu8pamFDZLB5mpOwU";
        assertTrue(apiKeyValidator.isValidApiKeyFormat(validApiKey), 
                  "API key with valid length should be valid");
    }

    @Test
    @DisplayName("Should validate secret key length requirements")
    void shouldValidateSecretKeyLengthRequirements() {
        // Test minimum length
        assertFalse(apiKeyValidator.isValidSecretKeyFormat("short"), 
                   "Secret key shorter than minimum should be invalid");
        
        // Test maximum length
        String longSecretKey = "a".repeat(101);
        assertFalse(apiKeyValidator.isValidSecretKeyFormat(longSecretKey), 
                   "Secret key longer than maximum should be invalid");
        
        // Test valid length
        String validSecretKey = "N26b6O6QlHmprRf40wEECqAEQjaD4ijMdIx5GRdBk0e34iTnVDRmFxZzrjgleT20";
        assertTrue(apiKeyValidator.isValidSecretKeyFormat(validSecretKey), 
                  "Secret key with valid length should be valid");
    }
}
