package com.oyakov.binance_data_storage.repository.elastic;

import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineFingerprint;
import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineItem;
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface KlineElasticRepository extends ElasticsearchRepository<KlineItem, String> {
    Optional<KlineItem> findByFingerprint(KlineFingerprint fingerprint);
    void deleteByFingerprint(KlineFingerprint fingerprint);
}
