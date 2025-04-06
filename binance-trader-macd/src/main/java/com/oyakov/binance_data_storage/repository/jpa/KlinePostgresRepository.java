package com.oyakov.binance_data_storage.repository.jpa;

import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface KlinePostgresRepository extends JpaRepository<KlineItem, Long> {

    public KlineItem findBySymbolAndIntervalAndTimestamp(String symbol, String interval, long timestamp);
}
