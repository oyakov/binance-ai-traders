package com.oyakov.binance_trader_macd.domain.signal;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_trader_macd.domain.TradeSignal;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

class MACDSignalAnalyzerTest {

    private MACDSignalAnalyzer analyzer;

    @BeforeEach
    void setUp() {
        analyzer = new MACDSignalAnalyzer();
    }

    @Test
    void shouldRequireMinimumDataPointsBeforeProducingSignal() {
        List<KlineEvent> klines = buildSinusoidalKlines(analyzer.getMinDataPointCount() - 1);

        Optional<TradeSignal> signal = analyzer.tryExtractSignal(klines);

        assertThat(signal).isEmpty();
    }

    @Test
    void shouldGenerateBuySignalWhenMacdCrossesAboveSignalLine() {
        List<KlineEvent> klines = buildSinusoidalKlines(48);

        Optional<TradeSignal> signal = analyzer.tryExtractSignal(klines);

        assertThat(signal).contains(TradeSignal.BUY);
    }

    @Test
    void shouldGenerateSellSignalWhenMacdCrossesBelowSignalLine() {
        List<KlineEvent> klines = buildSinusoidalKlines(63);

        Optional<TradeSignal> signal = analyzer.tryExtractSignal(klines);

        assertThat(signal).contains(TradeSignal.SELL);
    }

    @Test
    void shouldReturnEmptyWhenMacdRemainsOnSameSideOfSignalLine() {
        List<KlineEvent> klines = buildSinusoidalKlines(60);

        Optional<TradeSignal> signal = analyzer.tryExtractSignal(klines);

        assertThat(signal).isEmpty();
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
