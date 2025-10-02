package com.oyakov.binance_trader_macd.testnet;

import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.Instant;

import static org.assertj.core.api.Assertions.assertThat;

class TestnetPerformanceTrackerTest {

    @Test
    void shouldCalculateWinRateAndProfit() {
        StrategyConfig config = StrategyConfig.builder()
                .id("instance-1")
                .name("Test Strategy")
                .symbol("BTCUSDT")
                .timeframe("1h")
                .macdParams(StrategyConfig.MacdParameters.builder()
                        .fastPeriod(12)
                        .slowPeriod(26)
                        .signalPeriod(9)
                        .build())
                .riskLevel(StrategyConfig.RiskLevel.MEDIUM)
                .positionSize(BigDecimal.valueOf(0.01))
                .stopLossPercent(BigDecimal.ONE)
                .takeProfitPercent(BigDecimal.TWO)
                .enabled(true)
                .build();

        TestnetPerformanceTracker tracker = new TestnetPerformanceTracker("instance-1", config, BigDecimal.valueOf(10_000));
        tracker.startTracking();

        tracker.recordTrade(TestnetTrade.builder()
                .symbol("BTCUSDT")
                .profit(BigDecimal.valueOf(250))
                .win(true)
                .executedAt(Instant.now())
                .build());

        tracker.recordTrade(TestnetTrade.builder()
                .symbol("BTCUSDT")
                .profit(BigDecimal.valueOf(-100))
                .win(false)
                .executedAt(Instant.now())
                .build());

        InstancePerformance performance = tracker.getPerformance(true);

        assertThat(performance.getTotalTrades()).isEqualTo(2);
        assertThat(performance.getWinningTrades()).isEqualTo(1);
        assertThat(performance.getWinRate()).isEqualByComparingTo("0.5");
        assertThat(performance.getTotalProfit()).isEqualByComparingTo("150.0000");
        assertThat(performance.getCurrentBalance()).isEqualByComparingTo("10150.0000");
        assertThat(performance.isActive()).isTrue();
    }
}
