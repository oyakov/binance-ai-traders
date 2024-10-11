package com.oyakov.binance_data_storage.repository.elastic;

import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineItem;
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface KlineElasticRepository extends ElasticsearchRepository<KlineItem, String> {

}
