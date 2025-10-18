package com.oyakov.binance_trader_macd.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

/**
 * API Authentication Filter for securing REST endpoints
 * Validates X-API-Key header against configured API keys
 */
@Slf4j
@Component
public class ApiAuthenticationFilter extends OncePerRequestFilter {

    private static final String API_KEY_HEADER = "X-API-Key";
    private static final String API_KEY_PREFIX = "btai_testnet_";
    
    // Public endpoints that don't require authentication
    private static final List<String> PUBLIC_ENDPOINTS = Arrays.asList(
        "/health",
        "/actuator/health",
        "/error"
    );

    @Autowired
    private ApiKeyService apiKeyService;

    @Override
    protected void doFilterInternal(HttpServletRequest request, 
                                    HttpServletResponse response, 
                                    FilterChain filterChain) throws ServletException, IOException {
        
        String requestPath = request.getRequestURI();
        
        // Allow public endpoints without authentication
        if (isPublicEndpoint(requestPath)) {
            filterChain.doFilter(request, response);
            return;
        }

        // Extract API key from header
        String apiKey = request.getHeader(API_KEY_HEADER);
        
        if (apiKey == null || apiKey.isEmpty()) {
            log.warn("Missing API key for request: {} from IP: {}", 
                    requestPath, request.getRemoteAddr());
            sendUnauthorizedResponse(response, "Missing API key. Provide X-API-Key header.");
            return;
        }

        // Validate API key format
        if (!apiKey.startsWith(API_KEY_PREFIX)) {
            log.warn("Invalid API key format for request: {} from IP: {}", 
                    requestPath, request.getRemoteAddr());
            sendUnauthorizedResponse(response, "Invalid API key format.");
            return;
        }

        // Validate API key
        ApiKeyValidationResult validationResult = apiKeyService.validateApiKey(apiKey);
        
        if (!validationResult.isValid()) {
            log.warn("Invalid API key for request: {} from IP: {}. Reason: {}", 
                    requestPath, request.getRemoteAddr(), validationResult.getReason());
            sendUnauthorizedResponse(response, "Invalid or expired API key.");
            return;
        }

        // Check API key permissions for the requested endpoint
        if (!apiKeyService.hasPermission(apiKey, requestPath, request.getMethod())) {
            log.warn("Insufficient permissions for API key on request: {} {} from IP: {}", 
                    request.getMethod(), requestPath, request.getRemoteAddr());
            sendForbiddenResponse(response, "Insufficient permissions for this endpoint.");
            return;
        }

        // Log successful authentication
        log.debug("Authenticated request: {} from IP: {} with API key type: {}", 
                requestPath, request.getRemoteAddr(), validationResult.getKeyType());
        
        // Add API key type to request attributes for logging
        request.setAttribute("apiKeyType", validationResult.getKeyType());
        request.setAttribute("apiKeyId", validationResult.getKeyId());

        // Continue filter chain
        filterChain.doFilter(request, response);
    }

    /**
     * Check if the endpoint is public (no authentication required)
     */
    private boolean isPublicEndpoint(String path) {
        return PUBLIC_ENDPOINTS.stream().anyMatch(path::startsWith);
    }

    /**
     * Send 401 Unauthorized response
     */
    private void sendUnauthorizedResponse(HttpServletResponse response, String message) throws IOException {
        response.setStatus(HttpStatus.UNAUTHORIZED.value());
        response.setContentType("application/json");
        response.getWriter().write(String.format(
            "{\"error\":\"Unauthorized\",\"message\":\"%s\",\"status\":401}", 
            message
        ));
    }

    /**
     * Send 403 Forbidden response
     */
    private void sendForbiddenResponse(HttpServletResponse response, String message) throws IOException {
        response.setStatus(HttpStatus.FORBIDDEN.value());
        response.setContentType("application/json");
        response.getWriter().write(String.format(
            "{\"error\":\"Forbidden\",\"message\":\"%s\",\"status\":403}", 
            message
        ));
    }
}


