package com.oyakov.binance_data_collection.logging;

import com.oyakov.binance_shared_model.logging.CorrelationIdConstants;
import com.oyakov.binance_shared_model.logging.LoggingUtils;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.log4j.Log4j2;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.io.IOException;

/**
 * Filter to handle correlation IDs for distributed tracing
 * Extracts correlation ID from request header or generates a new one
 * Adds correlation ID to MDC for logging and to response header
 */
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
@Log4j2
public class CorrelationIdFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        try {
            // Extract correlation ID from request header or generate new one
            String correlationId = httpRequest.getHeader(CorrelationIdConstants.CORRELATION_ID_HEADER);
            
            if (correlationId == null || correlationId.isEmpty()) {
                correlationId = LoggingUtils.generateCorrelationId();
                log.debug("Generated new correlation ID: {}", correlationId);
            } else {
                log.debug("Extracted correlation ID from header: {}", correlationId);
            }
            
            // Set correlation ID in MDC
            LoggingUtils.setCorrelationId(correlationId);
            
            // Add correlation ID to response header
            httpResponse.setHeader(CorrelationIdConstants.CORRELATION_ID_HEADER, correlationId);
            
            // Continue filter chain
            chain.doFilter(request, response);
            
        } finally {
            // Always clear MDC after request completes to prevent memory leaks
            LoggingUtils.clearCorrelationId();
        }
    }
}

