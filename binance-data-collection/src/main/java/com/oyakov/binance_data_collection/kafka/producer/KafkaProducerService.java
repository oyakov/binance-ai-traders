package com.oyakov.binance_data_collection.kafka.producer;

import com.oyakov.binance_data_collection.config.BinanceDataCollectionConfig;
import com.oyakov.binance_data_collection.metrics.DataCollectionMetrics;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import io.micrometer.core.instrument.Timer;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;

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
        log.debug("Sending kline event to topic {}: {}", topic, event);
        
        Timer.Sample sample = metrics.startKafkaSend();
        try {
            CompletableFuture<SendResult<String, KlineEvent>> future = kafkaTemplate.send(topic, event.getSymbol(), event);
            future.whenComplete((result, throwable) -> {
                String status = throwable == null ? "success" : "failure";
                metrics.recordKafkaSendTime(sample, event.getSymbol(), event.getInterval(), status);
                if (throwable != null) {
                    log.error("Failed to send kline event to Kafka", throwable);
                    metrics.incrementKlineEventsFailedToSend(event.getSymbol(), event.getInterval(), throwable.getClass().getSimpleName());
                } else {
                    log.debug("Successfully sent kline event to Kafka: {}", result.getRecordMetadata());
                    metrics.incrementKlineEventsSentToKafka(event.getSymbol(), event.getInterval());
                }
            });
        } catch (Exception e) {
            metrics.recordKafkaSendTime(sample, event.getSymbol(), event.getInterval(), "failure");
            log.error("Failed to send kline event to Kafka", e);
            metrics.incrementKlineEventsFailedToSend(event.getSymbol(), event.getInterval(), e.getClass().getSimpleName());
            throw e;
        }
    }

    public void sendKlineEvents(String topic, Iterable<KlineEvent> events) {
        events.forEach(this::sendKlineEvent);
    }
}
