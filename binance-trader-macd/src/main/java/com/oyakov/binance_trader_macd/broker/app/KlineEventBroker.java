package com.oyakov.binance_trader_macd.broker.app;

import com.oyakov.binance_trader_macd.broker.kafka.producer.KafkaProducerService;
import com.oyakov.binance_trader_macd.model.klines.binance.commands.KlineCollectedCommand;
import com.oyakov.binance_trader_macd.model.klines.binance.notifications.DataItemWrittenNotification;
import com.oyakov.binance_trader_macd.model.klines.binance.storage.OrderItem;
import com.oyakov.binance_trader_macd.service.api.KlineDataServiceApi;
import lombok.extern.log4j.Log4j2;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

@Component
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
    public void handleKlineCollectedEvent(KlineCollectedCommand event) {
        log.info("Processing kline collected command: {}", event);
        klineDataServiceApi.saveKlineData(event);
    }

    @EventListener
    public void handleKlineWrittenEvent(DataItemWrittenNotification<OrderItem> event) {
        log.info("Processing kline written event: {}", event);
        if (event.getErrorMessage() != null) {
            log.debug("Compensating kline data for event: {}", event);
            klineDataServiceApi.compensateKlineData(event);
        }
        kafkaProducerService.sendCommand("binance-notification", event);
    }
}
