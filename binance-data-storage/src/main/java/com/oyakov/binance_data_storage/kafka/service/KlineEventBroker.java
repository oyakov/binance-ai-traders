package com.oyakov.binance_data_storage.kafka.service;

import com.oyakov.binance_data_storage.kafka.producer.KafkaProducerService;
import com.oyakov.binance_data_storage.model.klines.binance.notifications.DataItemWrittenNotification;
import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineItem;
import com.oyakov.binance_data_storage.service.api.KlineDataServiceApi;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import lombok.extern.log4j.Log4j2;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;

@Service
@Log4j2
public class KlineEventBroker {

    private final KafkaProducerService kafkaProducerService;

    private final KlineDataServiceApi klineDataServiceApi;

    public KlineEventBroker(KlineDataServiceApi klineDataServiceApi,
                            KafkaProducerService kafkaProducerService) {
        this.klineDataServiceApi = klineDataServiceApi;
        this.kafkaProducerService = kafkaProducerService;
    }

    @EventListener
    public void handleKlineCollectedEvent(KlineEvent event) {
        log.info("Processing kline collected command: {}", event);
        klineDataServiceApi.saveKlineData(event);
    }

    @EventListener
    public void handleKlineWrittenEvent(DataItemWrittenNotification<KlineEvent> event) {
        log.info("Processing kline written event: {}", event);
        if (event.getErrorMessage() != null) {
            log.debug("Compensating kline data for event: {}", event);
            klineDataServiceApi.compensateKlineData(event);
        }
        kafkaProducerService.sendCommand("binance-notification", event.getDataItem());
    }
}
