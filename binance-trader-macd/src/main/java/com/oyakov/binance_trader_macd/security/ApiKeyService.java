package com.oyakov.binance_trader_macd.security;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Service for managing and validating API keys
 */
@Slf4j
@Service
public class ApiKeyService {

    @Value("${api.key.admin:}")
    private String adminApiKey;

    @Value("${api.key.monitoring:}")
    private String monitoringApiKey;

    @Value("${api.key.readonly:}")
    private String readonlyApiKey;

    // Cache for validated API keys (simple implementation)
    private final Map<String, ApiKeyValidationResult> validationCache = new ConcurrentHashMap<>();

    // API key permissions
    private static final Map<String, Set<String>> PERMISSIONS = Map.of(
        "ADMIN", Set.of("/**"),
        "MONITORING", Set.of("/api/v1/macd/**", "/api/v1/trader/**", "/api/v1/signals/**"),
        "READONLY", Set.of("/api/v1/macd/signals", "/api/v1/trader/status")
    );

    /**
     * Validate API key
     */
    public ApiKeyValidationResult validateApiKey(String apiKey) {
        if (apiKey == null || apiKey.isEmpty()) {
            return ApiKeyValidationResult.invalid("API key is null or empty");
        }

        // Check cache first
        if (validationCache.containsKey(hashApiKey(apiKey))) {
            return validationCache.get(hashApiKey(apiKey));
        }

        // Validate against configured keys
        ApiKeyValidationResult result;
        
        if (apiKey.equals(adminApiKey)) {
            result = ApiKeyValidationResult.valid("admin", "ADMIN", PERMISSIONS.get("ADMIN"));
        } else if (apiKey.equals(monitoringApiKey)) {
            result = ApiKeyValidationResult.valid("monitoring", "MONITORING", PERMISSIONS.get("MONITORING"));
        } else if (apiKey.equals(readonlyApiKey)) {
            result = ApiKeyValidationResult.valid("readonly", "READONLY", PERMISSIONS.get("READONLY"));
        } else {
            result = ApiKeyValidationResult.invalid("API key not found");
        }

        // Cache the result
        if (result.isValid()) {
            validationCache.put(hashApiKey(apiKey), result);
        }

        return result;
    }

    /**
     * Check if API key has permission for specific endpoint
     */
    public boolean hasPermission(String apiKey, String path, String method) {
        ApiKeyValidationResult validation = validateApiKey(apiKey);
        
        if (!validation.isValid()) {
            return false;
        }

        Set<String> allowedPaths = validation.getAllowedPaths();
        
        // Check if path matches any allowed pattern
        for (String allowedPath : allowedPaths) {
            if (allowedPath.equals("/**")) {
                return true; // Admin has access to everything
            }
            
            if (pathMatches(path, allowedPath)) {
                // Check method restrictions
                if (validation.getKeyType().equals("READONLY") && 
                    !method.equalsIgnoreCase("GET")) {
                    return false; // Readonly keys can only use GET
                }
                return true;
            }
        }

        return false;
    }

    /**
     * Check if path matches the allowed pattern
     */
    private boolean pathMatches(String path, String pattern) {
        // Simple wildcard matching
        String regex = pattern.replace("**", ".*").replace("*", "[^/]*");
        return path.matches(regex);
    }

    /**
     * Hash API key for caching (never store plaintext in cache)
     */
    private String hashApiKey(String apiKey) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(apiKey.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(hash);
        } catch (Exception e) {
            log.error("Error hashing API key", e);
            return apiKey; // Fallback (not ideal but prevents service failure)
        }
    }

    /**
     * Clear validation cache (for key rotation)
     */
    public void clearCache() {
        validationCache.clear();
        log.info("API key validation cache cleared");
    }
}


