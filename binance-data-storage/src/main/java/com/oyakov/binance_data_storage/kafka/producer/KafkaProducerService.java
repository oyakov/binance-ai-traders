package com.oyakov.binance_data_storage.kafka.producer;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.log4j.Log4j2;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;

import java.util.concurrent.CompletableFuture;

@Service
@Log4j2
public class KafkaProducerService {

    private final KafkaTemplate<String, String> kafkaTemplate;
    private final ObjectMapper objectMapper;

    public KafkaProducerService(KafkaTemplate<String, String> kafkaTemplate, ObjectMapper objectMapper) {
        this.kafkaTemplate = kafkaTemplate;
        this.objectMapper = objectMapper;
    }

    public void sendCommand(String topic, Object command) {
        try {
            String message = objectMapper.writeValueAsString(command);
            CompletableFuture<SendResult<String, String>> future =
                    kafkaTemplate.send(topic, message);
            future.thenAccept(result -> {
                log.debug("Sent message: {}\n" +
                        "Record metadata: {}", message, result.getRecordMetadata());

            }).exceptionally(throwable -> {
                log.error("Failed to send message: {}", message, throwable);
                return null;
            });
        } catch (JsonProcessingException e) {
            log.error("Failed to serialize command: {}", command, e);
        }
    }
}
