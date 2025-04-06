package com.oyakov.binance_shared_model.repository.elastic;

import com.oyakov.binance_shared_model.model.klines.binance.storage.KlineItem;
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface KlineElasticRepository extends ElasticsearchRepository<KlineItem, Long> {

}
