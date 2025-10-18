package com.oyakov.binance_data_storage.kafka.consumer;

import com.oyakov.binance_data_storage.metrics.DataStorageMetrics;
import com.oyakov.binance_data_storage.service.api.KlineDataServiceApi;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_shared_model.logging.CorrelationIdConstants;
import com.oyakov.binance_shared_model.logging.LoggingUtils;
import io.micrometer.core.instrument.Timer;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.common.header.Header;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.util.Map;

@Service
@Log4j2
@RequiredArgsConstructor
public class KafkaConsumerService {

    private final KlineDataServiceApi klineDataService;
    private final DataStorageMetrics metrics;

    @KafkaListener(topics = "${binance.data.kline.kafka-topic}", groupId = "${binance.data.kline.kafka-consumer-group}")
    public void listen(@Payload KlineEvent event,
                      @Header(value = KafkaHeaders.RECEIVED_MESSAGE_KEY, required = false) String key,
                      @Header(value = CorrelationIdConstants.CORRELATION_ID_KAFKA_HEADER, required = false) String correlationId) {
        Timer.Sample sample = metrics.startKafkaConsumerProcessing();
        boolean success = false;
        
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
            
            log.info("Received kline event: {}", event);
            metrics.incrementKlineEventsReceived(event.getSymbol(), event.getInterval());

            klineDataService.saveKlineData(event);
            success = true;
        } catch (Exception e) {
            Map<String, Object> context = LoggingUtils.createTradingContext(event.getSymbol(), event.getInterval());
            LoggingUtils.logError(log, "Failed to process kline event", e, context);
            metrics.incrementKafkaConsumerErrors();
            metrics.incrementKlineEventsFailed(event.getSymbol(), event.getInterval(), e.getClass().getSimpleName());
            throw e; // Re-throw to trigger Kafka retry mechanism
        } finally {
            metrics.recordKafkaConsumerProcessingTime(sample, event.getSymbol(), event.getInterval(), success ? "success" : "failure");
            // Clear correlation ID from MDC
            LoggingUtils.clearCorrelationId();
        }
    }
}