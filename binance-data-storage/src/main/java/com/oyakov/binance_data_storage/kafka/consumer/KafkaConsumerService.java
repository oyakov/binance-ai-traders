package com.oyakov.binance_data_storage.kafka.consumer;

import com.oyakov.binance_data_storage.metrics.DataStorageMetrics;
import com.oyakov.binance_data_storage.service.api.KlineDataServiceApi;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import io.micrometer.core.instrument.Timer;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
@Log4j2
@RequiredArgsConstructor
public class KafkaConsumerService {

    private final KlineDataServiceApi klineDataService;
    private final DataStorageMetrics metrics;

    @KafkaListener(topics = "${binance.data.kline.kafka-topic}", groupId = "${binance.data.kline.kafka-consumer-group}")
    public void listen(KlineEvent event) {
        Timer.Sample sample = metrics.startKafkaConsumerProcessing();
        boolean success = false;
        try {
            log.info("Received kline event: {}", event);
            metrics.incrementKlineEventsReceived(event.getSymbol(), event.getInterval());

            klineDataService.saveKlineData(event);
            success = true;
        } catch (Exception e) {
            log.error("Failed to process kline event", e);
            metrics.incrementKafkaConsumerErrors();
            metrics.incrementKlineEventsFailed(event.getSymbol(), event.getInterval(), e.getClass().getSimpleName());
            throw e; // Re-throw to trigger Kafka retry mechanism
        } finally {
            metrics.recordKafkaConsumerProcessingTime(sample, event.getSymbol(), event.getInterval(), success ? "success" : "failure");
        }
    }
}