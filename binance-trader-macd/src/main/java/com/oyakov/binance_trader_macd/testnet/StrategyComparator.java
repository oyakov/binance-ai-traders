package com.oyakov.binance_trader_macd.testnet;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StrategyComparator {

    private static final MathContext MATH_CONTEXT = new MathContext(6, RoundingMode.HALF_UP);

    public StrategyRanking compareStrategies(List<InstancePerformance> performances) {
        Map<String, List<InstancePerformance>> byStrategy = performances.stream()
                .collect(Collectors.groupingBy(InstancePerformance::getStrategyName));

        List<StrategyPerformance> rankings = byStrategy.entrySet().stream()
                .map(entry -> StrategyPerformance.builder()
                        .strategyName(entry.getKey())
                        .averageProfit(calculateAverage(entry.getValue(), InstancePerformance::getTotalProfit))
                        .averageSharpeRatio(calculateAverage(entry.getValue(), InstancePerformance::getSharpeRatio))
                        .averageWinRate(calculateAverage(entry.getValue(), InstancePerformance::getWinRate))
                        .consistency(calculateConsistency(entry.getValue()))
                        .build())
                .sorted(Comparator.comparing(StrategyPerformance::getAverageProfit).reversed())
                .collect(Collectors.toList());

        return StrategyRanking.builder()
                .rankings(rankings)
                .build();
    }

    private BigDecimal calculateAverage(List<InstancePerformance> performances,
                                         Function<InstancePerformance, BigDecimal> extractor) {
        List<BigDecimal> values = performances.stream()
                .map(extractor)
                .filter(value -> value != null)
                .collect(Collectors.toList());
        if (values.isEmpty()) {
            return BigDecimal.ZERO;
        }
        BigDecimal sum = values.stream().reduce(BigDecimal.ZERO, BigDecimal::add);
        return sum.divide(BigDecimal.valueOf(values.size()), MATH_CONTEXT);
    }

    private BigDecimal calculateConsistency(List<InstancePerformance> performances) {
        if (performances.isEmpty()) {
            return BigDecimal.ZERO;
        }
        long profitable = performances.stream()
                .filter(performance -> performance.getTotalProfit() != null
                        && performance.getTotalProfit().compareTo(BigDecimal.ZERO) > 0)
                .count();
        return BigDecimal.valueOf(profitable)
                .divide(BigDecimal.valueOf(performances.size()), MATH_CONTEXT);
    }
}
