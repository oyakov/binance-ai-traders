package com.oyakov.binance_trader_macd.broker.kafka.consumer;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import lombok.extern.log4j.Log4j2;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
@Log4j2
public class KafkaConsumerService {

    private final ApplicationEventPublisher eventPublisher;

    public KafkaConsumerService(ApplicationEventPublisher eventPublisher) {
        this.eventPublisher = eventPublisher;
    }

    @KafkaListener(topics = "${binance.data.kline.kafka-topic}", groupId = "${binance.data.kline.kafka-consumer-group}")
    public void listen(KlineEvent command) {
        log.debug("Received kline command: {}", command);
        eventPublisher.publishEvent(command);
    }
}