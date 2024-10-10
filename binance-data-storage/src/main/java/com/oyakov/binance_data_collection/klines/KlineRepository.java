package com.oyakov.binance_data_collection.klines;

import com.oyakov.binance_data_collection.model.BinanceWebsocketEventData;
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;

//@Repository
public interface KlineRepository extends ElasticsearchRepository<BinanceWebsocketEventData, String> {

}
