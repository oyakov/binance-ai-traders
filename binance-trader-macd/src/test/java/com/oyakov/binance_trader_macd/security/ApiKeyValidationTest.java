package com.oyakov.binance_trader_macd.security;

import com.oyakov.binance_trader_macd.config.MACDTraderConfig;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("API Key Validation Tests")
class ApiKeyValidationTest {

    private ApiKeyValidator apiKeyValidator;
    private MACDTraderConfig config;

    @BeforeEach
    void setUp() {
        config = new MACDTraderConfig();
        apiKeyValidator = new ApiKeyValidator();
    }

    @Test
    @DisplayName("Should validate correct API key format")
    void shouldValidateCorrectApiKeyFormat() {
        // Arrange
        String validApiKey = "F4vS8U6mvUXST5TVbQbnMlUL4jOpQiI1Iy8QlVqXpVNMAxplu8pamFDZLB5mpOwU";
        
        // Act
        boolean isValid = apiKeyValidator.isValidApiKeyFormat(validApiKey);
        
        // Assert
        assertTrue(isValid, "Valid API key should pass format validation");
    }

    @Test
    @DisplayName("Should reject null API key")
    void shouldRejectNullApiKey() {
        // Act & Assert
        assertFalse(apiKeyValidator.isValidApiKeyFormat(null), "Null API key should be rejected");
    }

    @Test
    @DisplayName("Should reject empty API key")
    void shouldRejectEmptyApiKey() {
        // Act & Assert
        assertFalse(apiKeyValidator.isValidApiKeyFormat(""), "Empty API key should be rejected");
        assertFalse(apiKeyValidator.isValidApiKeyFormat("   "), "Whitespace-only API key should be rejected");
    }

    @Test
    @DisplayName("Should reject API key that is too short")
    void shouldRejectApiKeyTooShort() {
        // Arrange
        String shortApiKey = "short";
        
        // Act
        boolean isValid = apiKeyValidator.isValidApiKeyFormat(shortApiKey);
        
        // Assert
        assertFalse(isValid, "API key shorter than 20 characters should be rejected");
    }

    @Test
    @DisplayName("Should reject API key with invalid characters")
    void shouldRejectApiKeyWithInvalidCharacters() {
        // Arrange
        String invalidApiKey = "F4vS8U6mvUXST5TVbQbnMlUL4jOpQiI1Iy8QlVqXpVNMAxplu8pamFDZLB5mpOwU!@#";
        
        // Act
        boolean isValid = apiKeyValidator.isValidApiKeyFormat(invalidApiKey);
        
        // Assert
        assertFalse(isValid, "API key with special characters should be rejected");
    }

    @Test
    @DisplayName("Should validate secret key format")
    void shouldValidateSecretKeyFormat() {
        // Arrange
        String validSecretKey = "N26b6O6QlHmprRf40wEECqAEQjaD4ijMdIx5GRdBk0e34iTnVDRmFxZzrjgleT20";
        
        // Act
        boolean isValid = apiKeyValidator.isValidSecretKeyFormat(validSecretKey);
        
        // Assert
        assertTrue(isValid, "Valid secret key should pass format validation");
    }

    @Test
    @DisplayName("Should validate complete API credentials")
    void shouldValidateCompleteApiCredentials() {
        // Arrange
        MACDTraderConfig.Rest rest = new MACDTraderConfig.Rest();
        rest.setApiToken("F4vS8U6mvUXST5TVbQbnMlUL4jOpQiI1Iy8QlVqXpVNMAxplu8pamFDZLB5mpOwU");
        rest.setSecretApiToken("N26b6O6QlHmprRf40wEECqAEQjaD4ijMdIx5GRdBk0e34iTnVDRmFxZzrjgleT20");
        rest.setBaseUrl("https://testnet.binance.vision");
        config.setRest(rest);
        
        // Act
        ApiKeyValidationResult result = apiKeyValidator.validateApiCredentials(config);
        
        // Assert
        assertTrue(result.isValid(), "Valid API credentials should pass validation");
        assertTrue(result.getErrors().isEmpty(), "Valid credentials should have no errors");
    }

    @Test
    @DisplayName("Should detect missing API key")
    void shouldDetectMissingApiKey() {
        // Arrange
        MACDTraderConfig.Rest rest = new MACDTraderConfig.Rest();
        rest.setSecretApiToken("N26b6O6QlHmprRf40wEECqAEQjaD4ijMdIx5GRdBk0e34iTnVDRmFxZzrjgleT20");
        rest.setBaseUrl("https://testnet.binance.vision");
        config.setRest(rest);
        
        // Act
        ApiKeyValidationResult result = apiKeyValidator.validateApiCredentials(config);
        
        // Assert
        assertFalse(result.isValid(), "Missing API key should fail validation");
        assertTrue(result.getErrors().contains("API key is missing or empty"), 
                  "Should report missing API key error");
    }

    @Test
    @DisplayName("Should detect missing secret key")
    void shouldDetectMissingSecretKey() {
        // Arrange
        MACDTraderConfig.Rest rest = new MACDTraderConfig.Rest();
        rest.setApiToken("F4vS8U6mvUXST5TVbQbnMlUL4jOpQiI1Iy8QlVqXpVNMAxplu8pamFDZLB5mpOwU");
        rest.setBaseUrl("https://testnet.binance.vision");
        config.setRest(rest);
        
        // Act
        ApiKeyValidationResult result = apiKeyValidator.validateApiCredentials(config);
        
        // Assert
        assertFalse(result.isValid(), "Missing secret key should fail validation");
        assertTrue(result.getErrors().contains("Secret key is missing or empty"), 
                  "Should report missing secret key error");
    }

    @Test
    @DisplayName("Should detect invalid base URL")
    void shouldDetectInvalidBaseUrl() {
        // Arrange
        MACDTraderConfig.Rest rest = new MACDTraderConfig.Rest();
        rest.setApiToken("F4vS8U6mvUXST5TVbQbnMlUL4jOpQiI1Iy8QlVqXpVNMAxplu8pamFDZLB5mpOwU");
        rest.setSecretApiToken("N26b6O6QlHmprRf40wEECqAEQjaD4ijMdIx5GRdBk0e34iTnVDRmFxZzrjgleT20");
        rest.setBaseUrl("invalid-url");
        config.setRest(rest);
        
        // Act
        ApiKeyValidationResult result = apiKeyValidator.validateApiCredentials(config);
        
        // Assert
        assertFalse(result.isValid(), "Invalid base URL should fail validation");
        assertTrue(result.getErrors().stream().anyMatch(error -> error.contains("Base URL")), 
                  "Should report invalid base URL error");
    }

    @Test
    @DisplayName("Should validate testnet configuration")
    void shouldValidateTestnetConfiguration() {
        // Arrange
        MACDTraderConfig.Rest rest = new MACDTraderConfig.Rest();
        rest.setApiToken("F4vS8U6mvUXST5TVbQbnMlUL4jOpQiI1Iy8QlVqXpVNMAxplu8pamFDZLB5mpOwU");
        rest.setSecretApiToken("N26b6O6QlHmprRf40wEECqAEQjaD4ijMdIx5GRdBk0e34iTnVDRmFxZzrjgleT20");
        rest.setBaseUrl("https://testnet.binance.vision");
        config.setRest(rest);
        
        // Act
        ApiKeyValidationResult result = apiKeyValidator.validateApiCredentials(config);
        
        // Assert
        assertTrue(result.isValid(), "Testnet configuration should be valid");
        assertTrue(result.isTestnet(), "Should detect testnet configuration");
    }

    @Test
    @DisplayName("Should validate mainnet configuration")
    void shouldValidateMainnetConfiguration() {
        // Arrange
        MACDTraderConfig.Rest rest = new MACDTraderConfig.Rest();
        rest.setApiToken("F4vS8U6mvUXST5TVbQbnMlUL4jOpQiI1Iy8QlVqXpVNMAxplu8pamFDZLB5mpOwU");
        rest.setSecretApiToken("N26b6O6QlHmprRf40wEECqAEQjaD4ijMdIx5GRdBk0e34iTnVDRmFxZzrjgleT20");
        rest.setBaseUrl("https://api.binance.com");
        config.setRest(rest);
        
        // Act
        ApiKeyValidationResult result = apiKeyValidator.validateApiCredentials(config);
        
        // Assert
        assertTrue(result.isValid(), "Mainnet configuration should be valid");
        assertFalse(result.isTestnet(), "Should detect mainnet configuration");
    }
}
