package com.oyakov.binance_data_storage.kafka.consumer;

import com.oyakov.binance_data_storage.model.klines.binance.commands.KlineCollectedCommand;
import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineItem;
import com.oyakov.binance_data_storage.service.impl.KlineDataService;
import lombok.extern.log4j.Log4j2;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
@Log4j2
public class KafkaConsumerService {

    private final KlineDataService klineDataService;

    public KafkaConsumerService(KlineDataService klineDataService) {
        this.klineDataService = klineDataService;
    }

    @KafkaListener(topics = "${binance.data.kline.kafka-topic}", groupId = "${binance.data.kline.kafka-consumer-group}")
    public void listen(KlineCollectedCommand command) {
        log.info("Received kline command: {}", command);

        // write to elastic search
        KlineItem klineItem = KlineItem.builder()
                .symbol(command.getSymbol())
                .interval(command.getInterval())
                .openTime(command.getOpenTime())
                .open(command.getOpen())
                .high(command.getHigh())
                .low(command.getLow())
                .close(command.getClose())
                .volume(command.getVolume())
                .closeTime(command.getCloseTime())
                .build();

        klineDataService.saveKlineData(klineItem);
    }
}