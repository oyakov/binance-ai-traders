package com.oyakov.binance_data_storage.repository.jpa;

import com.oyakov.binance_data_storage.model.macd.MacdItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MacdPostgresRepository extends JpaRepository<MacdItem, Long> {

    @Modifying
    @Query(value = """
    INSERT INTO macd (symbol, "interval", "timestamp", collection_time, display_time,
                      ema_fast, ema_slow, macd, signal, histogram,
                      signal_buy, signal_sell, volume_signal, buy, sell)
    VALUES (:symbol, :interval, :timestamp, :collectionTime, :displayTime,
            :emaFast, :emaSlow, :macd, :signal, :histogram,
            :signalBuy, :signalSell, :volumeSignal, :buy, :sell)
    ON CONFLICT (symbol, "interval", "timestamp")
    DO UPDATE SET 
        collection_time = EXCLUDED.collection_time,
        display_time = EXCLUDED.display_time,
        ema_fast = EXCLUDED.ema_fast,
        ema_slow = EXCLUDED.ema_slow,
        macd = EXCLUDED.macd,
        signal = EXCLUDED.signal,
        histogram = EXCLUDED.histogram,
        signal_buy = EXCLUDED.signal_buy,
        signal_sell = EXCLUDED.signal_sell,
        volume_signal = EXCLUDED.volume_signal,
        buy = EXCLUDED.buy,
        sell = EXCLUDED.sell
    """, nativeQuery = true)
    void upsertMacd(
            @Param("symbol") String symbol,
            @Param("interval") String interval,
            @Param("timestamp") long timestamp,
            @Param("collectionTime") java.time.LocalDateTime collectionTime,
            @Param("displayTime") java.time.LocalDateTime displayTime,
            @Param("emaFast") Double emaFast,
            @Param("emaSlow") Double emaSlow,
            @Param("macd") Double macd,
            @Param("signal") Double signal,
            @Param("histogram") Double histogram,
            @Param("signalBuy") Double signalBuy,
            @Param("signalSell") Double signalSell,
            @Param("volumeSignal") Double volumeSignal,
            @Param("buy") Double buy,
            @Param("sell") Double sell
    );

    @Query(value = "SELECT * FROM macd WHERE symbol = :symbol AND \"interval\" = :interval ORDER BY \"timestamp\" DESC LIMIT :limit", nativeQuery = true)
    List<com.oyakov.binance_data_storage.model.macd.MacdItem> findRecentMacd(@Param("symbol") String symbol,
                                                                             @Param("interval") String interval,
                                                                             @Param("limit") int limit);
}


