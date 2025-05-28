package com.oyakov.binance_data_collection.kafka.consumer;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

/*
    This listener is implemented for debugging purposes
 */
@Service
@Log4j2
@RequiredArgsConstructor
public class KafkaConsumerService {

    @KafkaListener(topics = "${binance.data.kline.kafka-topic}", 
                  groupId = "${binance.data.kline.kafka-consumer-group}")
    public void listen(KlineEvent message) {
        log.debug("Kline event: {}", message);
    }
}