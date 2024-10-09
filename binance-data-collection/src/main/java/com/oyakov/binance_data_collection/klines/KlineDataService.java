package com.oyakov.binance_data_collection.klines;

import com.oyakov.binance_data_collection.model.BinanceWebsocketEventData;

/**
 * Service for writing collected kline data to elasticsearch
 */
//@Service
public class KlineDataService {

    private final KlineRepository klineRepository;

    public KlineDataService(KlineRepository klineRepository) {
        this.klineRepository = klineRepository;
    }

    public void saveKlineData(BinanceWebsocketEventData binanceWebsocketEventData) {
        klineRepository.save(binanceWebsocketEventData);
    }
}
