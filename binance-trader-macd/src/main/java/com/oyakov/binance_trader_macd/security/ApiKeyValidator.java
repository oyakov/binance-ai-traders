package com.oyakov.binance_trader_macd.security;

import com.oyakov.binance_trader_macd.config.MACDTraderConfig;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

@Slf4j
@Component
public class ApiKeyValidator {

    private static final int MIN_API_KEY_LENGTH = 20;
    private static final int MAX_API_KEY_LENGTH = 100;
    private static final Pattern API_KEY_PATTERN = Pattern.compile("^[A-Za-z0-9]+$");
    private static final Pattern SECRET_KEY_PATTERN = Pattern.compile("^[A-Za-z0-9]+$");
    
    private static final String TESTNET_BASE_URL = "https://testnet.binance.vision";
    private static final String MAINNET_BASE_URL = "https://api.binance.com";

    /**
     * Validates the format of an API key
     */
    public boolean isValidApiKeyFormat(String apiKey) {
        if (apiKey == null || apiKey.trim().isEmpty()) {
            return false;
        }
        
        if (apiKey.length() < MIN_API_KEY_LENGTH || apiKey.length() > MAX_API_KEY_LENGTH) {
            return false;
        }
        
        return API_KEY_PATTERN.matcher(apiKey).matches();
    }

    /**
     * Validates the format of a secret key
     */
    public boolean isValidSecretKeyFormat(String secretKey) {
        if (secretKey == null || secretKey.trim().isEmpty()) {
            return false;
        }
        
        if (secretKey.length() < MIN_API_KEY_LENGTH || secretKey.length() > MAX_API_KEY_LENGTH) {
            return false;
        }
        
        return SECRET_KEY_PATTERN.matcher(secretKey).matches();
    }

    /**
     * Validates the base URL format
     */
    public boolean isValidBaseUrl(String baseUrl) {
        if (baseUrl == null || baseUrl.trim().isEmpty()) {
            return false;
        }
        
        try {
            @SuppressWarnings("deprecation")
            URL url = new URL(baseUrl);
            return "https".equals(url.getProtocol()) && 
                   (baseUrl.contains("binance.com") || baseUrl.contains("binance.vision"));
        } catch (MalformedURLException e) {
            log.debug("Invalid base URL format: {}", baseUrl, e);
            return false;
        }
    }

    /**
     * Validates complete API credentials configuration
     */
    public ApiKeyValidationResult validateApiCredentials(MACDTraderConfig config) {
        List<String> errors = new ArrayList<>();
        boolean isValid = true;
        boolean isTestnet = false;

        if (config == null || config.getRest() == null) {
            errors.add("Configuration or REST configuration is null");
            return new ApiKeyValidationResult(false, errors, false);
        }

        MACDTraderConfig.Rest rest = config.getRest();

        // Validate API key
        if (!isValidApiKeyFormat(rest.getApiToken())) {
            errors.add("API key is missing or empty");
            isValid = false;
        }

        // Validate secret key
        if (!isValidSecretKeyFormat(rest.getSecretApiToken())) {
            errors.add("Secret key is missing or empty");
            isValid = false;
        }

        // Validate base URL
        if (!isValidBaseUrl(rest.getBaseUrl())) {
            errors.add("Base URL is missing or invalid. Must be a valid Binance API URL");
            isValid = false;
        } else {
            // Determine if this is testnet or mainnet
            isTestnet = TESTNET_BASE_URL.equals(rest.getBaseUrl());
        }

        if (isValid) {
            log.info("API credentials validation successful. Environment: {}", 
                    isTestnet ? "TESTNET" : "MAINNET");
        } else {
            log.warn("API credentials validation failed. Errors: {}", errors);
        }

        return new ApiKeyValidationResult(isValid, errors, isTestnet);
    }

    /**
     * Validates API credentials for a specific environment
     */
    public ApiKeyValidationResult validateApiCredentialsForEnvironment(MACDTraderConfig config, boolean expectTestnet) {
        ApiKeyValidationResult result = validateApiCredentials(config);
        
        if (result.isValid()) {
            if (expectTestnet && !result.isTestnet()) {
                List<String> newErrors = new ArrayList<>(result.getErrors());
                newErrors.add("Expected testnet configuration but found mainnet");
                result = new ApiKeyValidationResult(false, newErrors, result.isTestnet());
            } else if (!expectTestnet && result.isTestnet()) {
                List<String> newErrors = new ArrayList<>(result.getErrors());
                newErrors.add("Expected mainnet configuration but found testnet");
                result = new ApiKeyValidationResult(false, newErrors, result.isTestnet());
            }
        }
        
        return result;
    }

    /**
     * Checks if the configuration is for testnet
     */
    public boolean isTestnetConfiguration(MACDTraderConfig config) {
        if (config == null || config.getRest() == null || config.getRest().getBaseUrl() == null) {
            return false;
        }
        return TESTNET_BASE_URL.equals(config.getRest().getBaseUrl());
    }

    /**
     * Checks if the configuration is for mainnet
     */
    public boolean isMainnetConfiguration(MACDTraderConfig config) {
        if (config == null || config.getRest() == null || config.getRest().getBaseUrl() == null) {
            return false;
        }
        return MAINNET_BASE_URL.equals(config.getRest().getBaseUrl());
    }
}
