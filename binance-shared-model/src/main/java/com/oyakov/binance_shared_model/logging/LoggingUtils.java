package com.oyakov.binance_shared_model.logging;

import org.apache.logging.log4j.Logger;
import org.slf4j.MDC;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * Utility class for standardized logging across all services
 * Works with both SLF4J and Log4j2 loggers via polymorphism
 */
public final class LoggingUtils {

    private LoggingUtils() {
        // Utility class - prevent instantiation
    }

    /**
     * Generate a new correlation ID
     * 
     * @return A new UUID-based correlation ID
     */
    public static String generateCorrelationId() {
        return UUID.randomUUID().toString();
    }

    /**
     * Set correlation ID in MDC
     * 
     * @param correlationId The correlation ID to set
     */
    public static void setCorrelationId(String correlationId) {
        if (correlationId != null && !correlationId.isEmpty()) {
            MDC.put(CorrelationIdConstants.CORRELATION_ID_MDC_KEY, correlationId);
        }
    }

    /**
     * Get correlation ID from MDC
     * 
     * @return Current correlation ID or null if not set
     */
    public static String getCorrelationId() {
        return MDC.get(CorrelationIdConstants.CORRELATION_ID_MDC_KEY);
    }

    /**
     * Get or generate correlation ID
     * 
     * @return Current correlation ID from MDC or a new one if not set
     */
    public static String getOrGenerateCorrelationId() {
        String correlationId = getCorrelationId();
        if (correlationId == null || correlationId.isEmpty()) {
            correlationId = generateCorrelationId();
            setCorrelationId(correlationId);
        }
        return correlationId;
    }

    /**
     * Clear correlation ID from MDC
     */
    public static void clearCorrelationId() {
        MDC.remove(CorrelationIdConstants.CORRELATION_ID_MDC_KEY);
    }

    /**
     * Log error with structured context (Log4j2)
     * 
     * @param logger The Log4j2 logger instance
     * @param message Error message
     * @param throwable Exception to log
     * @param context Additional context as key-value pairs
     */
    public static void logError(org.apache.logging.log4j.Logger logger, String message, Throwable throwable, Map<String, Object> context) {
        String correlationId = getCorrelationId();
        StringBuilder logMessage = new StringBuilder(message);
        
        if (context != null && !context.isEmpty()) {
            logMessage.append(" | Context: ");
            context.forEach((key, value) -> 
                logMessage.append(key).append("=").append(value).append(", ")
            );
            // Remove trailing comma and space
            logMessage.setLength(logMessage.length() - 2);
        }
        
        if (correlationId != null) {
            logMessage.append(" | CorrelationId: ").append(correlationId);
        }
        
        logger.error(logMessage.toString(), throwable);
    }
    
    /**
     * Log error with structured context (SLF4J)
     * 
     * @param logger The SLF4J logger instance
     * @param message Error message
     * @param throwable Exception to log
     * @param context Additional context as key-value pairs
     */
    public static void logError(org.slf4j.Logger logger, String message, Throwable throwable, Map<String, Object> context) {
        String correlationId = getCorrelationId();
        StringBuilder logMessage = new StringBuilder(message);
        
        if (context != null && !context.isEmpty()) {
            logMessage.append(" | Context: ");
            context.forEach((key, value) -> 
                logMessage.append(key).append("=").append(value).append(", ")
            );
            // Remove trailing comma and space
            logMessage.setLength(logMessage.length() - 2);
        }
        
        if (correlationId != null) {
            logMessage.append(" | CorrelationId: ").append(correlationId);
        }
        
        logger.error(logMessage.toString(), throwable);
    }

    /**
     * Log business error (no exception) with structured context (Log4j2)
     * 
     * @param logger The Log4j2 logger instance
     * @param message Error message
     * @param context Additional context as key-value pairs
     */
    public static void logBusinessError(org.apache.logging.log4j.Logger logger, String message, Map<String, Object> context) {
        String correlationId = getCorrelationId();
        StringBuilder logMessage = new StringBuilder(message);
        
        if (context != null && !context.isEmpty()) {
            logMessage.append(" | Context: ");
            context.forEach((key, value) -> 
                logMessage.append(key).append("=").append(value).append(", ")
            );
            logMessage.setLength(logMessage.length() - 2);
        }
        
        if (correlationId != null) {
            logMessage.append(" | CorrelationId: ").append(correlationId);
        }
        
        logger.error(logMessage.toString());
    }
    
    /**
     * Log business error (no exception) with structured context (SLF4J)
     * 
     * @param logger The SLF4J logger instance
     * @param message Error message
     * @param context Additional context as key-value pairs
     */
    public static void logBusinessError(org.slf4j.Logger logger, String message, Map<String, Object> context) {
        String correlationId = getCorrelationId();
        StringBuilder logMessage = new StringBuilder(message);
        
        if (context != null && !context.isEmpty()) {
            logMessage.append(" | Context: ");
            context.forEach((key, value) -> 
                logMessage.append(key).append("=").append(value).append(", ")
            );
            logMessage.setLength(logMessage.length() - 2);
        }
        
        if (correlationId != null) {
            logMessage.append(" | CorrelationId: ").append(correlationId);
        }
        
        logger.error(logMessage.toString());
    }

    /**
     * Log external API error with status code and response (Log4j2)
     * 
     * @param logger The Log4j2 logger instance
     * @param apiName Name of the external API
     * @param statusCode HTTP status code
     * @param responseBody Response body (can be null)
     */
    public static void logExternalApiError(org.apache.logging.log4j.Logger logger, String apiName, int statusCode, String responseBody) {
        Map<String, Object> context = new HashMap<>();
        context.put("apiName", apiName);
        context.put("statusCode", statusCode);
        if (responseBody != null && !responseBody.isEmpty()) {
            context.put("responseBody", responseBody.length() > 500 ? 
                responseBody.substring(0, 500) + "..." : responseBody);
        }
        
        logBusinessError(logger, "External API call failed", context);
    }
    
    /**
     * Log external API error with status code and response (SLF4J)
     * 
     * @param logger The SLF4J logger instance
     * @param apiName Name of the external API
     * @param statusCode HTTP status code
     * @param responseBody Response body (can be null)
     */
    public static void logExternalApiError(org.slf4j.Logger logger, String apiName, int statusCode, String responseBody) {
        Map<String, Object> context = new HashMap<>();
        context.put("apiName", apiName);
        context.put("statusCode", statusCode);
        if (responseBody != null && !responseBody.isEmpty()) {
            context.put("responseBody", responseBody.length() > 500 ? 
                responseBody.substring(0, 500) + "..." : responseBody);
        }
        
        logBusinessError(logger, "External API call failed", context);
    }

    /**
     * Create a context map for trading-related operations
     * 
     * @param symbol Trading symbol
     * @param interval Kline interval
     * @return Context map
     */
    public static Map<String, Object> createTradingContext(String symbol, String interval) {
        Map<String, Object> context = new HashMap<>();
        if (symbol != null) {
            context.put("symbol", symbol);
        }
        if (interval != null) {
            context.put("interval", interval);
        }
        return context;
    }

    /**
     * Create a context map for order-related operations
     * 
     * @param symbol Trading symbol
     * @param orderId Order ID
     * @param orderType Order type
     * @return Context map
     */
    public static Map<String, Object> createOrderContext(String symbol, Long orderId, String orderType) {
        Map<String, Object> context = new HashMap<>();
        if (symbol != null) {
            context.put("symbol", symbol);
        }
        if (orderId != null) {
            context.put("orderId", orderId);
        }
        if (orderType != null) {
            context.put("orderType", orderType);
        }
        return context;
    }

    /**
     * Create a context map for Kafka-related operations
     * 
     * @param topic Kafka topic
     * @param key Message key
     * @return Context map
     */
    public static Map<String, Object> createKafkaContext(String topic, String key) {
        Map<String, Object> context = new HashMap<>();
        if (topic != null) {
            context.put("topic", topic);
        }
        if (key != null) {
            context.put("key", key);
        }
        return context;
    }
}

