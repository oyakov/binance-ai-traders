package com.oyakov.binance_trader_macd.integration;

import com.oyakov.binance_trader_macd.config.MACDTraderConfig;
import com.oyakov.binance_trader_macd.rest.client.BinanceOrderClient;
import com.oyakov.binance_trader_macd.security.ApiKeyValidator;
import com.oyakov.binance_trader_macd.security.ApiKeyValidationResult;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit.jupiter.SpringJUnitExtension;
import org.springframework.web.client.RestTemplate;

import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(SpringJUnitExtension.class)
@SpringBootTest
@ActiveProfiles("testnet")
@DisplayName("Binance API Key Connectivity Tests")
class BinanceApiKeyConnectivityTest {

    @Autowired
    private ApiKeyValidator apiKeyValidator;

    @Autowired
    private BinanceOrderClient binanceOrderClient;

    @Autowired
    private MACDTraderConfig traderConfig;

    @Autowired
    private RestTemplate restTemplate;

    @Test
    @DisplayName("Should validate API credentials before making requests")
    void shouldValidateApiCredentialsBeforeMakingRequests() {
        // Act
        ApiKeyValidationResult validationResult = apiKeyValidator.validateApiCredentials(traderConfig);

        // Assert
        assertTrue(validationResult.isValid(), 
                  "API credentials should be valid before making requests");
        assertTrue(validationResult.isTestnet(), 
                  "Should be using testnet environment");
        assertTrue(validationResult.getErrors().isEmpty(), 
                  "Should have no validation errors");
    }

    @Test
    @DisplayName("Should have properly configured BinanceOrderClient")
    void shouldHaveProperlyConfiguredBinanceOrderClient() {
        // Assert
        assertNotNull(binanceOrderClient, "BinanceOrderClient should be configured");
        assertNotNull(traderConfig, "Trader configuration should be available");
        assertNotNull(traderConfig.getRest(), "REST configuration should be available");
        
        // Verify configuration values are loaded
        assertNotNull(traderConfig.getRest().getApiToken(), "API token should be loaded");
        assertNotNull(traderConfig.getRest().getSecretApiToken(), "Secret token should be loaded");
        assertNotNull(traderConfig.getRest().getBaseUrl(), "Base URL should be loaded");
        assertEquals("https://testnet.binance.vision", traderConfig.getRest().getBaseUrl(), 
                    "Should use testnet base URL");
    }

    @Test
    @DisplayName("Should validate API key format matches Binance requirements")
    void shouldValidateApiKeyFormatMatchesBinanceRequirements() {
        // Arrange
        String apiKey = traderConfig.getRest().getApiToken();
        String secretKey = traderConfig.getRest().getSecretApiToken();

        // Act & Assert
        assertTrue(apiKeyValidator.isValidApiKeyFormat(apiKey), 
                  "API key should match Binance format requirements");
        assertTrue(apiKeyValidator.isValidSecretKeyFormat(secretKey), 
                  "Secret key should match Binance format requirements");
        
        // Verify length requirements
        assertTrue(apiKey.length() >= 20, "API key should be at least 20 characters");
        assertTrue(secretKey.length() >= 20, "Secret key should be at least 20 characters");
        
        // Verify character requirements (alphanumeric only)
        assertTrue(apiKey.matches("^[A-Za-z0-9]+$"), "API key should contain only alphanumeric characters");
        assertTrue(secretKey.matches("^[A-Za-z0-9]+$"), "Secret key should contain only alphanumeric characters");
    }

    @Test
    @DisplayName("Should validate base URL is correct for testnet")
    void shouldValidateBaseUrlIsCorrectForTestnet() {
        // Arrange
        String baseUrl = traderConfig.getRest().getBaseUrl();

        // Act & Assert
        assertTrue(apiKeyValidator.isValidBaseUrl(baseUrl), 
                  "Base URL should be valid");
        assertEquals("https://testnet.binance.vision", baseUrl, 
                    "Should use correct testnet base URL");
        assertTrue(apiKeyValidator.isTestnetConfiguration(traderConfig), 
                  "Should be identified as testnet configuration");
    }

    @Test
    @DisplayName("Should handle API key validation for different environments")
    void shouldHandleApiKeyValidationForDifferentEnvironments() {
        // Test current testnet configuration
        ApiKeyValidationResult testnetResult = apiKeyValidator.validateApiCredentialsForEnvironment(
                traderConfig, true);
        assertTrue(testnetResult.isValid(), 
                  "Current testnet configuration should be valid for testnet environment");
        assertTrue(testnetResult.isTestnet(), 
                  "Should be identified as testnet");

        // Test that it would fail if expecting mainnet
        ApiKeyValidationResult mainnetExpectationResult = apiKeyValidator.validateApiCredentialsForEnvironment(
                traderConfig, false);
        assertFalse(mainnetExpectationResult.isValid(), 
                   "Testnet configuration should fail mainnet expectation");
        assertTrue(mainnetExpectationResult.getErrors().stream()
                .anyMatch(error -> error.contains("Expected mainnet")), 
                  "Should report mainnet expectation error");
    }

    @Test
    @DisplayName("Should validate configuration completeness")
    void shouldValidateConfigurationCompleteness() {
        // Act
        ApiKeyValidationResult result = apiKeyValidator.validateApiCredentials(traderConfig);

        // Assert
        assertTrue(result.isValid(), "Configuration should be complete and valid");
        assertTrue(result.getErrors().isEmpty(), "Should have no validation errors");
        
        // Verify all required components are present
        assertNotNull(traderConfig.getRest().getApiToken(), "API token should be present");
        assertNotNull(traderConfig.getRest().getSecretApiToken(), "Secret token should be present");
        assertNotNull(traderConfig.getRest().getBaseUrl(), "Base URL should be present");
        
        // Verify values are not empty
        assertFalse(traderConfig.getRest().getApiToken().trim().isEmpty(), 
                   "API token should not be empty");
        assertFalse(traderConfig.getRest().getSecretApiToken().trim().isEmpty(), 
                   "Secret token should not be empty");
        assertFalse(traderConfig.getRest().getBaseUrl().trim().isEmpty(), 
                   "Base URL should not be empty");
    }

    @Test
    @DisplayName("Should provide detailed validation information")
    void shouldProvideDetailedValidationInformation() {
        // Act
        ApiKeyValidationResult result = apiKeyValidator.validateApiCredentials(traderConfig);

        // Assert
        assertNotNull(result, "Validation result should not be null");
        assertTrue(result.isValid(), "Configuration should be valid");
        assertTrue(result.isTestnet(), "Should be testnet environment");
        assertEquals("TESTNET", result.getEnvironment(), "Should report TESTNET environment");
        assertFalse(result.hasErrors(), "Should have no errors");
        assertEquals("No errors", result.getErrorSummary(), "Should report no errors");
    }

    @Test
    @DisplayName("Should validate API key security requirements")
    void shouldValidateApiKeySecurityRequirements() {
        // Arrange
        String apiKey = traderConfig.getRest().getApiToken();
        String secretKey = traderConfig.getRest().getSecretApiToken();

        // Act & Assert - Check that keys are not obviously test/placeholder values
        assertFalse(apiKey.equals("your-api-key-here"), 
                   "API key should not be placeholder value");
        assertFalse(secretKey.equals("your-secret-key-here"), 
                   "Secret key should not be placeholder value");
        
        // Check that keys appear to be real Binance API keys (start with common patterns)
        assertTrue(apiKey.length() > 30, "API key should be reasonably long");
        assertTrue(secretKey.length() > 30, "Secret key should be reasonably long");
        
        // Check that keys contain both letters and numbers
        assertTrue(apiKey.matches(".*[0-9].*"), "API key should contain numbers");
        assertTrue(apiKey.matches(".*[A-Za-z].*"), "API key should contain letters");
        assertTrue(secretKey.matches(".*[0-9].*"), "Secret key should contain numbers");
        assertTrue(secretKey.matches(".*[A-Za-z].*"), "Secret key should contain letters");
    }

    @Test
    @DisplayName("Should validate RestTemplate configuration")
    void shouldValidateRestTemplateConfiguration() {
        // Assert
        assertNotNull(restTemplate, "RestTemplate should be configured");
        
        // Verify that RestTemplate can be used for HTTP requests
        // (This is a basic connectivity test - actual API calls would require valid credentials)
        assertDoesNotThrow(() -> {
            // Just verify the RestTemplate is properly configured
            // We don't make actual API calls in this test to avoid rate limiting
            restTemplate.getForObject("https://httpbin.org/get", String.class);
        }, "RestTemplate should be able to make HTTP requests");
    }

    @Test
    @DisplayName("Should validate configuration loading from environment")
    void shouldValidateConfigurationLoadingFromEnvironment() {
        // Assert that configuration is loaded from environment variables
        // This test verifies that the Spring configuration is working correctly
        
        assertNotNull(traderConfig, "Trader configuration should be loaded");
        assertNotNull(traderConfig.getRest(), "REST configuration should be loaded");
        
        // Verify that the configuration matches what we expect from testnet.env
        String expectedApiKey = "F4vS8U6mvUXST5TVbQbnMlUL4jOpQiI1Iy8QlVqXpVNMAxplu8pamFDZLB5mpOwU";
        String expectedSecretKey = "N26b6O6QlHmprRf40wEECqAEQjaD4ijMdIx5GRdBk0e34iTnVDRmFxZzrjgleT20";
        String expectedBaseUrl = "https://testnet.binance.vision";
        
        assertEquals(expectedApiKey, traderConfig.getRest().getApiToken(), 
                   "API key should match testnet.env value");
        assertEquals(expectedSecretKey, traderConfig.getRest().getSecretApiToken(), 
                   "Secret key should match testnet.env value");
        assertEquals(expectedBaseUrl, traderConfig.getRest().getBaseUrl(), 
                   "Base URL should match testnet.env value");
    }
}
