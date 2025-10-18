package com.oyakov.binance_trader_macd.security;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;

import java.util.Collections;
import java.util.List;
import java.util.Set;

/**
 * Result of API key validation
 * Supports both configuration validation and runtime API key validation
 */
@Data
@AllArgsConstructor
@Getter
public class ApiKeyValidationResult {
    private boolean valid;
    private List<String> errors;
    private boolean testnet;
    private String reason;
    private String keyId;
    private String keyType;
    private Set<String> allowedPaths;

    // Constructor for configuration validation (used by ApiKeyValidator)
    public ApiKeyValidationResult(boolean valid, List<String> errors, boolean testnet) {
        this.valid = valid;
        this.errors = errors;
        this.testnet = testnet;
        this.reason = errors.isEmpty() ? null : String.join(", ", errors);
        this.keyId = null;
        this.keyType = null;
        this.allowedPaths = Collections.emptySet();
    }

    // Factory method for runtime validation - valid key (used by ApiKeyService)
    public static ApiKeyValidationResult valid(String keyId, String keyType, Set<String> allowedPaths) {
        return new ApiKeyValidationResult(true, Collections.emptyList(), false, null, keyId, keyType, allowedPaths);
    }

    // Factory method for runtime validation - invalid key (used by ApiKeyService)
    public static ApiKeyValidationResult invalid(String reason) {
        return new ApiKeyValidationResult(false, Collections.singletonList(reason), false, reason, null, null, Collections.emptySet());
    }

    // Factory method for configuration validation - invalid
    public static ApiKeyValidationResult invalid(List<String> errors, boolean testnet) {
        return new ApiKeyValidationResult(false, errors, testnet);
    }
}
