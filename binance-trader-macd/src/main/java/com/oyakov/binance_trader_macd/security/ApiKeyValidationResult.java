package com.oyakov.binance_trader_macd.security;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.Collections;
import java.util.Set;

/**
 * Result of API key validation
 */
@Data
@AllArgsConstructor
public class ApiKeyValidationResult {
    private boolean valid;
    private String keyId;
    private String keyType;
    private String reason;
    private Set<String> allowedPaths;

    public static ApiKeyValidationResult valid(String keyId, String keyType, Set<String> allowedPaths) {
        return new ApiKeyValidationResult(true, keyId, keyType, null, allowedPaths);
    }

    public static ApiKeyValidationResult invalid(String reason) {
        return new ApiKeyValidationResult(false, null, null, reason, Collections.emptySet());
    }
}
