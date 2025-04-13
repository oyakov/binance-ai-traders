package com.oyakov.binance_data_storage.kafka.consumer;

import com.oyakov.binance_data_storage.model.klines.binance.commands.KlineCollectedCommand;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
@Log4j2
@RequiredArgsConstructor
public class KafkaConsumerService {

    private final ApplicationEventPublisher eventPublisher;

    @KafkaListener(topics = "${binance.data.kline.kafka-topic}", groupId = "${binance.data.kline.kafka-consumer-group}")
    public void listen(KlineCollectedCommand command) {
        log.info("Received kline command: {}", command);
        try {
            eventPublisher.publishEvent(command);
        } catch (Exception e) {
            log.error("Failed to publish application event", e);
        }

    }
}