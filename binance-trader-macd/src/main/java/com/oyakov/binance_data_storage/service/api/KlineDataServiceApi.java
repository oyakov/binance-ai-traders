package com.oyakov.binance_data_storage.service.api;

import com.oyakov.binance_data_storage.model.klines.binance.commands.KlineCollectedCommand;
import com.oyakov.binance_data_storage.model.klines.binance.notifications.DataItemWrittenNotification;
import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineItem;
import org.springframework.transaction.annotation.Transactional;

public interface KlineDataServiceApi {

    @Transactional
    public void saveKlineData(KlineCollectedCommand kline);

    public void compensateKlineData(DataItemWrittenNotification<KlineItem> kline);
}
