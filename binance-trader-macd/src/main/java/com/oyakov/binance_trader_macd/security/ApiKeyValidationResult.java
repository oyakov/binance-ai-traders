package com.oyakov.binance_trader_macd.security;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.Collections;
import java.util.List;

@Data
public class ApiKeyValidationResult {
    
    private final boolean valid;
    private final List<String> errors;
    private final boolean testnet;

    public ApiKeyValidationResult(boolean valid, List<String> errors, boolean testnet) {
        this.valid = valid;
        this.errors = errors != null ? List.copyOf(errors) : Collections.emptyList();
        this.testnet = testnet;
    }

    public boolean isValid() {
        return valid;
    }

    public List<String> getErrors() {
        return errors;
    }

    public boolean isTestnet() {
        return testnet;
    }

    public boolean isMainnet() {
        return !testnet;
    }

    public String getEnvironment() {
        return testnet ? "TESTNET" : "MAINNET";
    }

    public boolean hasErrors() {
        return !errors.isEmpty();
    }

    public String getErrorSummary() {
        if (errors.isEmpty()) {
            return "No errors";
        }
        return String.join("; ", errors);
    }
}
