package com.oyakov.binance_trader_macd.testnet;

import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class StrategyComparatorTest {

    private final StrategyComparator comparator = new StrategyComparator();

    @Test
    void shouldRankStrategiesByAverageProfit() {
        InstancePerformance strategyAInstance = InstancePerformance.builder()
                .instanceId("a-1")
                .strategyName("Strategy A")
                .totalProfit(BigDecimal.valueOf(150))
                .winRate(BigDecimal.valueOf(0.6))
                .sharpeRatio(BigDecimal.valueOf(1.2))
                .build();
        InstancePerformance strategyBInstance = InstancePerformance.builder()
                .instanceId("b-1")
                .strategyName("Strategy B")
                .totalProfit(BigDecimal.valueOf(200))
                .winRate(BigDecimal.valueOf(0.7))
                .sharpeRatio(BigDecimal.valueOf(1.5))
                .build();

        StrategyRanking ranking = comparator.compareStrategies(List.of(strategyAInstance, strategyBInstance));

        assertThat(ranking.getRankings()).hasSize(2);
        assertThat(ranking.getRankings().getFirst().getStrategyName()).isEqualTo("Strategy B");
        assertThat(ranking.getRankings().getLast().getStrategyName()).isEqualTo("Strategy A");
    }
}
