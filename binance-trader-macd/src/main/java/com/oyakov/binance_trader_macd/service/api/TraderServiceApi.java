package com.oyakov.binance_trader_macd.service.api;

import com.oyakov.binance_shared_model.avro.KlineEvent;

public interface TraderServiceApi {
    public void onNewKline(KlineEvent klineEvent);
}
