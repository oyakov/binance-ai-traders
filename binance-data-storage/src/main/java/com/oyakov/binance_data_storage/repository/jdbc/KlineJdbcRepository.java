package com.oyakov.binance_data_storage.repository.jdbc;

import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineItem;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class KlineJdbcRepository {

    private final JdbcTemplate jdbcTemplate;

    public KlineJdbcRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void save(KlineItem kline) {
        String sql = "INSERT INTO kline " +
                "(id, symbol, interval, timestamp, display_time, open_time, open, high, low, close, volume, close_time) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        jdbcTemplate.update(sql,
                kline.getSymbol(),
                kline.getInterval(),
                kline.getTimestamp(),
                kline.getDisplayTime(),
                kline.getOpenTime(),
                kline.getOpen(),
                kline.getHigh(),
                kline.getLow(),
                kline.getClose(),
                kline.getVolume(),
                kline.getCloseTime()
        );
    }

    public void upsertKline(KlineItem kline) {
        String sql = """ 
                    INSERT INTO kline
                    (symbol, interval, timestamp, display_time, open_time, open, high, low, close, volume, close_time)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    ON CONFLICT (symbol, interval, open_time)
                    SET ()
                """;

        jdbcTemplate.update(sql,
                kline.getSymbol(),
                kline.getInterval(),
                kline.getTimestamp(),
                kline.getDisplayTime(),
                kline.getOpenTime(),
                kline.getOpen(),
                kline.getHigh(),
                kline.getLow(),
                kline.getClose(),
                kline.getVolume(),
                kline.getCloseTime()
        );
    }
}

