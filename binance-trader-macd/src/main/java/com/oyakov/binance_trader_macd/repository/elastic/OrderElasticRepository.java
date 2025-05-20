package com.oyakov.binance_trader_macd.repository.elastic;

import com.oyakov.binance_trader_macd.model.order.binance.storage.OrderItem;
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface OrderElasticRepository extends ElasticsearchRepository<OrderItem, Long> {

}
