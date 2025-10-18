package com.oyakov.binance_shared_model.logging;

/**
 * Constants for correlation ID handling across all services
 */
public final class CorrelationIdConstants {
    
    /**
     * HTTP header name for correlation ID
     */
    public static final String CORRELATION_ID_HEADER = "X-Correlation-ID";
    
    /**
     * MDC key for correlation ID
     */
    public static final String CORRELATION_ID_MDC_KEY = "correlationId";
    
    /**
     * Kafka header name for correlation ID
     */
    public static final String CORRELATION_ID_KAFKA_HEADER = "correlationId";
    
    /**
     * Default value when correlation ID is not present
     */
    public static final String NO_CORRELATION_ID = "NO-CORRELATION-ID";
    
    private CorrelationIdConstants() {
        // Utility class - prevent instantiation
    }
}

