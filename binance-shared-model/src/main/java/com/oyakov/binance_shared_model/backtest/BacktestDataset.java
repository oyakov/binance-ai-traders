package com.oyakov.binance_shared_model.backtest;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.List;

/**
 * Represents a serialisable collection of kline samples that can be used to replay
 * historical market behaviour inside the trading services.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BacktestDataset {

    private String name;
    private String symbol;
    private String interval;
    private Instant collectedAt;
    private List<KlineEvent> klines;
}
