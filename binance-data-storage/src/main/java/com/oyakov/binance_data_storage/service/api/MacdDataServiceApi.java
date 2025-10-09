package com.oyakov.binance_data_storage.service.api;

import com.oyakov.binance_data_storage.model.macd.MacdItem;

public interface MacdDataServiceApi {
    void upsert(MacdItem item);
}


