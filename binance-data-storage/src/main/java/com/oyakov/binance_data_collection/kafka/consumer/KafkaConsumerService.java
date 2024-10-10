package com.oyakov.binance_data_collection.kafka.consumer;

import lombok.extern.log4j.Log4j2;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
@Log4j2
public class KafkaConsumerService {

    @KafkaListener(topics = "your-kafka-topic", groupId = "test-group")
    public void listen(String message) {
        log.info("Received message: {}", message);
    }
}