package com.oyakov.binance_trader_macd.service.api;

import com.oyakov.binance_trader_macd.model.klines.binance.commands.KlineCollectedCommand;
import com.oyakov.binance_trader_macd.model.klines.binance.notifications.DataItemWrittenNotification;
import com.oyakov.binance_trader_macd.model.klines.binance.storage.OrderItem;
import org.springframework.transaction.annotation.Transactional;

public interface KlineDataServiceApi {

    @Transactional
    public void saveKlineData(KlineCollectedCommand kline);

    public void compensateKlineData(DataItemWrittenNotification<OrderItem> kline);
}
