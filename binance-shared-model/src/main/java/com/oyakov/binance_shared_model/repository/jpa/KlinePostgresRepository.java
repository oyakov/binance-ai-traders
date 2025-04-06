package com.oyakov.binance_shared_model.repository.jpa;

import com.oyakov.binance_shared_model.model.klines.binance.storage.KlineItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface KlinePostgresRepository extends JpaRepository<KlineItem, Long> {

    public KlineItem findBySymbolAndIntervalAndTimestamp(String symbol, String interval, long timestamp);
}
