package com.oyakov.binance_data_storage.kafka.producer;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_shared_model.logging.CorrelationIdConstants;
import com.oyakov.binance_shared_model.logging.LoggingUtils;
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
public class KafkaProducerService {

    private final KafkaTemplate<String, KlineEvent> kafkaTemplate;

    public KafkaProducerService(KafkaTemplate<String, KlineEvent> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    public void sendCommand(String topic, KlineEvent command) {
        // Get or generate correlation ID
        String correlationId = LoggingUtils.getOrGenerateCorrelationId();
        
        // Create producer record with headers
        ProducerRecord<String, KlineEvent> record = new ProducerRecord<>(topic, command);
        Headers headers = record.headers();
        headers.add(CorrelationIdConstants.CORRELATION_ID_KAFKA_HEADER, 
                   correlationId.getBytes(StandardCharsets.UTF_8));
        
        CompletableFuture<SendResult<String, KlineEvent>> future =
                kafkaTemplate.send(record);
        future.thenAccept(result -> {
            log.debug("Sent message with correlationId={}: {}\nRecord metadata: {}", 
                     correlationId, command, result.getRecordMetadata());
        }).exceptionally(throwable -> {
            Map<String, Object> context = LoggingUtils.createKafkaContext(topic, command.getSymbol());
            LoggingUtils.logError(log, "Failed to send Kafka message", throwable, context);
            return null;
        });
    }
}
