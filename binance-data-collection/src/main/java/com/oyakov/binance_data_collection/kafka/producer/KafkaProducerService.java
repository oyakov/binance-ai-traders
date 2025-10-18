package com.oyakov.binance_data_collection.kafka.producer;

import com.oyakov.binance_data_collection.config.BinanceDataCollectionConfig;
import com.oyakov.binance_data_collection.metrics.DataCollectionMetrics;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_shared_model.logging.CorrelationIdConstants;
import com.oyakov.binance_shared_model.logging.LoggingUtils;
import io.micrometer.core.instrument.Timer;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.header.Headers;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

@Service
@Log4j2
@RequiredArgsConstructor
public class KafkaProducerService {

    private final BinanceDataCollectionConfig config;
    private final KafkaTemplate<String, KlineEvent> kafkaTemplate;
    private final DataCollectionMetrics metrics;

    public void sendKlineEvent(KlineEvent event) {
        String topic = config.getData().getKline().getKafkaTopic();
        
        // Get or generate correlation ID
        String correlationId = LoggingUtils.getOrGenerateCorrelationId();
        log.debug("Sending kline event to topic {} with correlationId={}: {}", topic, correlationId, event);
        
        Timer.Sample sample = metrics.startKafkaSend();
        try {
            // Create producer record with correlation ID in headers
            ProducerRecord<String, KlineEvent> record = new ProducerRecord<>(topic, event.getSymbol(), event);
            Headers headers = record.headers();
            headers.add(CorrelationIdConstants.CORRELATION_ID_KAFKA_HEADER, 
                       correlationId.getBytes(StandardCharsets.UTF_8));
            
            CompletableFuture<SendResult<String, KlineEvent>> future = kafkaTemplate.send(record);
            future.whenComplete((result, throwable) -> {
                String status = throwable == null ? "success" : "failure";
                metrics.recordKafkaSendTime(sample, event.getSymbol(), event.getInterval(), status);
                if (throwable != null) {
                    Map<String, Object> context = LoggingUtils.createKafkaContext(topic, event.getSymbol());
                    context.put("interval", event.getInterval());
                    LoggingUtils.logError(log, "Failed to send kline event to Kafka", throwable, context);
                    metrics.incrementKlineEventsFailedToSend(event.getSymbol(), event.getInterval(), throwable.getClass().getSimpleName());
                } else {
                    log.debug("Successfully sent kline event to Kafka with correlationId={}: {}", correlationId, result.getRecordMetadata());
                    metrics.incrementKlineEventsSentToKafka(event.getSymbol(), event.getInterval());
                }
            });
        } catch (Exception e) {
            metrics.recordKafkaSendTime(sample, event.getSymbol(), event.getInterval(), "failure");
            Map<String, Object> context = LoggingUtils.createKafkaContext(topic, event.getSymbol());
            context.put("interval", event.getInterval());
            LoggingUtils.logError(log, "Failed to send kline event to Kafka", e, context);
            metrics.incrementKlineEventsFailedToSend(event.getSymbol(), event.getInterval(), e.getClass().getSimpleName());
            throw e;
        }
    }

    public void sendKlineEvents(String topic, Iterable<KlineEvent> events) {
        events.forEach(this::sendKlineEvent);
    }
}
