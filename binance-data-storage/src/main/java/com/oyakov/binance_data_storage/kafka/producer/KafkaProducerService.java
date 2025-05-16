package com.oyakov.binance_data_storage.kafka.producer;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import lombok.extern.log4j.Log4j2;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;

import java.util.concurrent.CompletableFuture;

@Service
@Log4j2
public class KafkaProducerService {

    private final KafkaTemplate<String, KlineEvent> kafkaTemplate;

    public KafkaProducerService(KafkaTemplate<String, KlineEvent> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    public void sendCommand(String topic, KlineEvent command) {
        CompletableFuture<SendResult<String, KlineEvent>> future =
                kafkaTemplate.send(topic, command);
        future.thenAccept(result -> {
            log.debug("Sent message: {}\n" +
                    "Record metadata: {}", command, result.getRecordMetadata());

        }).exceptionally(throwable -> {
            log.error("Failed to send message: {}", command, throwable);
            return null;
        });
    }
}
