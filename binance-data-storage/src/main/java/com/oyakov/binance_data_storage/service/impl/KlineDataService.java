package com.oyakov.binance_data_storage.service.impl;

import com.oyakov.binance_data_storage.model.klines.binance.notifications.KlineWrittenNotification;
import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineItem;
import com.oyakov.binance_data_storage.repository.KlineRepository;
import com.oyakov.binance_data_storage.service.api.KlineDataServiceApi;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;

import java.util.concurrent.CompletableFuture;

/**
 * Service for writing collected kline data to elasticsearch
 */
@Service
@Log4j2
public class KlineDataService implements KlineDataServiceApi {

    private final KlineRepository klineRepository;

    public KlineDataService(KlineRepository klineRepository) {
        this.klineRepository = klineRepository;
    }

    @Override
    public CompletableFuture<KlineWrittenNotification> saveKlineData(KlineItem kline) {
        try {
            // save kline data to elasticsearch
            klineRepository.save(kline);

            // save kline data to database


            log.info("Kline data saved: {}", kline);
        } catch (Exception e) {
            log.error("Failed to save kline data: {}", kline, e);
        }

        return CompletableFuture.completedFuture(KlineWrittenNotification.builder()
                .eventType("KlineWritten")
                .eventTime(System.currentTimeMillis())
                .symbol(kline.getSymbol())
                .interval(kline.getInterval())
                .build());
    }
}
