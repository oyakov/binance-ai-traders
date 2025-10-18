package com.oyakov.binance_trader_macd.broker.kafka.consumer;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_shared_model.logging.CorrelationIdConstants;
import com.oyakov.binance_shared_model.logging.LoggingUtils;
import lombok.extern.log4j.Log4j2;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Service;

@Service
@Log4j2
public class KafkaConsumerService {

    private final ApplicationEventPublisher eventPublisher;

    public KafkaConsumerService(ApplicationEventPublisher eventPublisher) {
        this.eventPublisher = eventPublisher;
    }

    @KafkaListener(topics = "${binance.data.kline.kafka-topic}", groupId = "${binance.data.kline.kafka-consumer-group}")
    public void listen(@Payload KlineEvent command,
                      @Header(value = CorrelationIdConstants.CORRELATION_ID_KAFKA_HEADER, required = false) String correlationId) {
        try {
            // Set correlation ID in MDC for this thread
            if (correlationId != null && !correlationId.isEmpty()) {
                LoggingUtils.setCorrelationId(correlationId);
                log.debug("Extracted correlation ID from Kafka message: {}", correlationId);
            } else {
                // Generate new correlation ID if not present
                correlationId = LoggingUtils.generateCorrelationId();
                LoggingUtils.setCorrelationId(correlationId);
                log.debug("Generated new correlation ID for Kafka message: {}", correlationId);
            }
            
            log.debug("Received kline command: {}", command);
            eventPublisher.publishEvent(command);
        } finally {
            // Clear correlation ID from MDC
            LoggingUtils.clearCorrelationId();
        }
    }
}