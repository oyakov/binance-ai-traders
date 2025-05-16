package com.oyakov.binance_data_collection.kafka.producer;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
@Log4j2
@RequiredArgsConstructor
public class KafkaProducerService {

    private final KafkaTemplate<String, KlineEvent> kafkaTemplate;

    public void sendKlineEvent(String topic, KlineEvent event) {
        log.debug("Sending kline event to topic {}: {}", topic, event);
        kafkaTemplate.send(topic, event.getSymbol(), event);
    }
}
