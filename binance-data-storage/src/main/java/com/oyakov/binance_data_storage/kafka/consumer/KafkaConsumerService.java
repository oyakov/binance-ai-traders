package com.oyakov.binance_data_storage.kafka.consumer;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.oyakov.binance_data_storage.commands.KlineCollectedCommand;
import lombok.extern.log4j.Log4j2;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
@Log4j2
public class    KafkaConsumerService {

    @KafkaListener(topics = "${binance.data.kline.kafka-topic}", groupId = "${binance.data.kline.kafka-consumer-group}")
    public void listen(String message) {
        log.info("Received message: {}", message);
        // Deserialize message
        ObjectMapper objectMapper = new ObjectMapper();
        try {
            KlineCollectedCommand command = objectMapper.readValue(message, KlineCollectedCommand.class);
            log.info("Deserialized message: {}", command);
        } catch (Exception e) {
            log.error("Failed to deserialize message: {}", message, e);
        }


        // Save message to database
    }
}