package com.oyakov.binance_trader_macd.integration;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_trader_macd.domain.TradeSignal;
import com.oyakov.binance_trader_macd.domain.signal.MACDSignalAnalyzer;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class MacdBacktestIntegrationTest {

    private final MACDSignalAnalyzer analyzer = new MACDSignalAnalyzer();

    @Test
    void shouldEmitExpectedSignalSequenceDuringBacktestReplay() {
        List<KlineEvent> dataset = buildSinusoidalKlines(120);
        List<TradeSignal> signals = new ArrayList<>();

        for (int end = 0; end < dataset.size(); end++) {
            List<KlineEvent> window = dataset.subList(0, end + 1);
            analyzer.tryExtractSignal(window).ifPresent(signals::add);
        }

        assertThat(signals)
                .containsExactly(
                        TradeSignal.SELL,
                        TradeSignal.BUY,
                        TradeSignal.SELL,
                        TradeSignal.BUY,
                        TradeSignal.SELL
                );
    }

    private List<KlineEvent> buildSinusoidalKlines(int length) {
        List<KlineEvent> klines = new ArrayList<>(length);
        for (int i = 0; i < length; i++) {
            BigDecimal price = BigDecimal.valueOf(100 + 10 * Math.sin(i / 5.0))
                    .setScale(8, RoundingMode.HALF_UP);
            klines.add(new KlineEvent(
                    "kline",
                    (long) i,
                    "BTCUSDT",
                    "1m",
                    (long) i,
                    (long) i,
                    price,
                    price,
                    price,
                    price,
                    BigDecimal.ONE
            ));
        }
        return klines;
    }
}
