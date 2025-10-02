package com.oyakov.binance_trader_macd.testnet;

import lombok.Getter;
import lombok.extern.slf4j.Slf4j;

import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;

@Slf4j
public class TestnetPerformanceTracker {

    private static final MathContext MATH_CONTEXT = new MathContext(8, RoundingMode.HALF_UP);
    private static final BigDecimal ZERO = BigDecimal.ZERO.setScale(4, RoundingMode.HALF_UP);

    private final String instanceId;
    @Getter
    private final StrategyConfig strategyConfig;
    private final List<TestnetTrade> trades = new CopyOnWriteArrayList<>();
    private final AtomicInteger totalTrades = new AtomicInteger();
    private final AtomicInteger winningTrades = new AtomicInteger();
    private final AtomicReference<BigDecimal> currentBalance;
    private final AtomicReference<BigDecimal> peakBalance;
    private final AtomicReference<BigDecimal> maxDrawdown = new AtomicReference<>(ZERO);
    private final AtomicReference<BigDecimal> sharpeRatio = new AtomicReference<>(ZERO);
    private final AtomicBoolean tracking = new AtomicBoolean(false);
    private volatile Instant lastUpdated;

    public TestnetPerformanceTracker(String instanceId, StrategyConfig strategyConfig, BigDecimal startingBalance) {
        this.instanceId = instanceId;
        this.strategyConfig = strategyConfig;
        BigDecimal initialBalance = startingBalance == null ? BigDecimal.ZERO : startingBalance;
        if (initialBalance.scale() < 4) {
            initialBalance = initialBalance.setScale(4, RoundingMode.HALF_UP);
        }
        this.currentBalance = new AtomicReference<>(initialBalance);
        this.peakBalance = new AtomicReference<>(initialBalance);
        this.lastUpdated = Instant.now();
    }

    public void startTracking() {
        tracking.set(true);
        log.info("Started performance tracking for instance {}", instanceId);
    }

    public void stopTracking() {
        tracking.set(false);
        log.info("Stopped performance tracking for instance {}", instanceId);
    }

    public boolean isTracking() {
        return tracking.get();
    }

    public void recordTrade(TestnetTrade trade) {
        trades.add(trade);
        totalTrades.incrementAndGet();
        if (trade.isWin()) {
            winningTrades.incrementAndGet();
        }

        BigDecimal profit = trade.getProfit() == null ? BigDecimal.ZERO : trade.getProfit();
        BigDecimal updatedBalance = currentBalance.updateAndGet(balance -> balance.add(profit));
        peakBalance.updateAndGet(peak -> peak.max(updatedBalance));
        BigDecimal drawdown = peakBalance.get().subtract(updatedBalance).max(ZERO);
        maxDrawdown.updateAndGet(current -> current.max(drawdown));
        lastUpdated = trade.getExecutedAt() != null ? trade.getExecutedAt() : Instant.now();
        recalculateSharpeRatio();
    }

    public void collectMetrics() {
        // Placeholder for future integration with live metrics.
        // We still update Sharpe ratio so that periodic collection captures volatility changes.
        recalculateSharpeRatio();
    }

    public InstancePerformance getPerformance(boolean active) {
        return InstancePerformance.builder()
                .instanceId(instanceId)
                .strategyName(strategyConfig.getName())
                .symbol(strategyConfig.getSymbol())
                .timeframe(strategyConfig.getTimeframe())
                .totalTrades(totalTrades.get())
                .winningTrades(winningTrades.get())
                .winRate(calculateWinRate())
                .totalProfit(calculateTotalProfit())
                .maxDrawdown(maxDrawdown.get())
                .sharpeRatio(sharpeRatio.get())
                .currentBalance(currentBalance.get())
                .active(active)
                .lastUpdated(lastUpdated)
                .build();
    }

    private BigDecimal calculateWinRate() {
        int total = totalTrades.get();
        if (total == 0) {
            return ZERO;
        }
        return BigDecimal.valueOf(winningTrades.get())
                .divide(BigDecimal.valueOf(total), MATH_CONTEXT)
                .setScale(4, RoundingMode.HALF_UP);
    }

    private BigDecimal calculateTotalProfit() {
        return trades.stream()
                .map(TestnetTrade::getProfit)
                .filter(profit -> profit != null)
                .reduce(BigDecimal.ZERO, BigDecimal::add)
                .setScale(4, RoundingMode.HALF_UP);
    }

    private void recalculateSharpeRatio() {
        if (trades.isEmpty()) {
            sharpeRatio.set(ZERO);
            return;
        }

        BigDecimal averageReturn = calculateAverageReturn();
        BigDecimal standardDeviation = calculateStandardDeviation(averageReturn);
        if (standardDeviation.compareTo(BigDecimal.ZERO) == 0) {
            sharpeRatio.set(ZERO);
            return;
        }
        sharpeRatio.set(averageReturn.divide(standardDeviation, MATH_CONTEXT).setScale(4, RoundingMode.HALF_UP));
    }

    private BigDecimal calculateAverageReturn() {
        BigDecimal total = trades.stream()
                .map(TestnetTrade::getProfit)
                .filter(profit -> profit != null)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        return total.divide(BigDecimal.valueOf(trades.size()), MATH_CONTEXT);
    }

    private BigDecimal calculateStandardDeviation(BigDecimal mean) {
        BigDecimal varianceSum = trades.stream()
                .map(TestnetTrade::getProfit)
                .filter(profit -> profit != null)
                .map(profit -> profit.subtract(mean).pow(2, MATH_CONTEXT))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal variance = varianceSum.divide(BigDecimal.valueOf(trades.size()), MATH_CONTEXT);
        double sqrt = Math.sqrt(variance.doubleValue());
        return BigDecimal.valueOf(sqrt).setScale(4, RoundingMode.HALF_UP);
    }
}
