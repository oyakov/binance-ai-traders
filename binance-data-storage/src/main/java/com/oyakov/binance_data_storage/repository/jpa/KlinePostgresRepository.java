package com.oyakov.binance_data_storage.repository.jpa;

import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineFingerprint;
import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public interface KlinePostgresRepository extends JpaRepository<KlineItem, Long> {

    @Modifying
    @Query(value = """
    INSERT INTO kline (symbol, interval, open_time, close_time, timestamp, display_time, open, high, low, close, volume)
    VALUES (:symbol, :interval, :openTime, :closeTime, :timestamp, :displayTime, :open, :high, :low, :close, :volume)
    ON CONFLICT (symbol, interval, open_time, close_time)
    DO UPDATE SET 
        timestamp = EXCLUDED.timestamp,
        display_time = EXCLUDED.display_time,
        open = EXCLUDED.open,
        high = EXCLUDED.high,
        low = EXCLUDED.low,
        close = EXCLUDED.close,
        volume = EXCLUDED.volume
    """, nativeQuery = true)
    void upsertKlineNative(@Param("symbol") String symbol,
                     @Param("interval") String interval,
                     @Param("openTime") long openTime,
                     @Param("closeTime") long closeTime,
                     @Param("timestamp") long timestamp,
                     @Param("displayTime") LocalDateTime displayTime,
                     @Param("open") double open,
                     @Param("high") double high,
                     @Param("low") double low,
                     @Param("close") double close,
                     @Param("volume") double volume);

    default void upsertKline(KlineItem klineItem) {
        KlineFingerprint f = klineItem.getFingerprint();
        upsertKlineNative(
                f.getSymbol(),
                f.getInterval(),
                f.getOpenTime(),
                klineItem.getCloseTime(),
                klineItem.getTimestamp(),
                klineItem.getDisplayTime(),
                klineItem.getOpen(),
                klineItem.getHigh(),
                klineItem.getLow(),
                klineItem.getClose(),
                klineItem.getVolume()
        );
    }

    Optional<KlineItem> findByFingerprint(KlineFingerprint fingerprint);

    void deleteByFingerprint(KlineFingerprint fingerprint);
}
