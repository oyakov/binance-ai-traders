package com.oyakov.binance_data_storage.service.api;

import com.oyakov.binance_data_storage.model.klines.binance.notifications.KlineWrittenNotification;
import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineItem;
import org.springframework.transaction.annotation.Transactional;

import java.util.concurrent.CompletableFuture;

public interface KlineDataServiceApi {

    @Transactional
    public CompletableFuture<KlineWrittenNotification> saveKlineData(KlineItem kline);
}
