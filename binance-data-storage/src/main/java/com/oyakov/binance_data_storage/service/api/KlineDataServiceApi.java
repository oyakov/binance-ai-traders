package com.oyakov.binance_data_storage.service.api;

import com.oyakov.binance_data_storage.model.klines.binance.notifications.DataItemWrittenNotification;
import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineItem;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import org.springframework.transaction.annotation.Transactional;

public interface KlineDataServiceApi {

    @Transactional
    public void saveKlineData(KlineEvent kline);

    public void compensateKlineData(DataItemWrittenNotification<KlineEvent> kline);
}
