package com.oyakov.binance_data_storage.klines;

import com.oyakov.binance_data_storage.model.BinanceWebsocketEventData;
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;

//@Repository
public interface KlineRepository extends ElasticsearchRepository<BinanceWebsocketEventData, String> {

}
