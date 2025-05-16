package com.oyakov.binance_data_storage.kafka.consumer;

import lombok.RequiredArgsConstructor;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_data_storage.mapper.KlineMapper;
import com.oyakov.binance_data_storage.service.api.KlineDataServiceApi;
import lombok.extern.log4j.Log4j2;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
@Log4j2
@RequiredArgsConstructor
public class KafkaConsumerService {

    private final KlineDataServiceApi klineDataService;

    @KafkaListener(topics = "${binance.data.kline.kafka-topic}", groupId = "${binance.data.kline.kafka-consumer-group}")
    public void listen(KlineEvent event) {
        log.info("Received kline event: {}", event);
        try {
            klineDataService.saveKlineData(event);
        } catch (Exception e) {
            log.error("Failed to process kline event", e);
        }
    }
}