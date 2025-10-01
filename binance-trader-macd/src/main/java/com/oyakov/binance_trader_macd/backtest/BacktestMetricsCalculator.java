package com.oyakov.binance_trader_macd.backtest;

import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;
import java.util.Comparator;
import java.util.List;

@Component
@Log4j2
public class BacktestMetricsCalculator {

    private static final MathContext MATH_CONTEXT = MathContext.DECIMAL64;

    public BacktestMetrics calculate(String datasetName, List<SimulatedTrade> trades) {
        BigDecimal netProfit = trades.stream()
                .map(SimulatedTrade::getProfit)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        int total = trades.size();
        int winning = (int) trades.stream().filter(trade -> trade.getProfit().compareTo(BigDecimal.ZERO) > 0).count();
        int losing = (int) trades.stream().filter(trade -> trade.getProfit().compareTo(BigDecimal.ZERO) < 0).count();
        int breakEven = total - winning - losing;

        BigDecimal averageReturn = total == 0 ? BigDecimal.ZERO : trades.stream()
                .map(SimulatedTrade::getReturnPercentage)
                .reduce(BigDecimal.ZERO, BigDecimal::add)
                .divide(BigDecimal.valueOf(total), MATH_CONTEXT);

        BigDecimal winRate = total == 0 ? BigDecimal.ZERO : BigDecimal.valueOf(winning)
                .divide(BigDecimal.valueOf(total), 4, RoundingMode.HALF_UP);

        BigDecimal bestTrade = trades.stream()
                .map(SimulatedTrade::getProfit)
                .max(Comparator.naturalOrder())
                .orElse(BigDecimal.ZERO);
        BigDecimal worstTrade = trades.stream()
                .map(SimulatedTrade::getProfit)
                .min(Comparator.naturalOrder())
                .orElse(BigDecimal.ZERO);

        Drawdown drawdown = calculateDrawdown(trades);

        return BacktestMetrics.builder()
                .datasetName(datasetName)
                .totalTrades(total)
                .winningTrades(winning)
                .losingTrades(losing)
                .breakEvenTrades(breakEven)
                .netProfit(netProfit)
                .averageReturn(averageReturn)
                .winRate(winRate)
                .maxDrawdown(drawdown.absolute())
                .maxDrawdownPercent(drawdown.relative())
                .bestTrade(bestTrade)
                .worstTrade(worstTrade)
                .build();
    }

    private Drawdown calculateDrawdown(List<SimulatedTrade> trades) {
        BigDecimal equityPeak = BigDecimal.ZERO;
        BigDecimal equity = BigDecimal.ZERO;
        BigDecimal maxDrawdown = BigDecimal.ZERO;
        BigDecimal maxDrawdownPct = BigDecimal.ZERO;

        for (SimulatedTrade trade : trades) {
            equity = equity.add(trade.getProfit());
            if (equity.compareTo(equityPeak) > 0) {
                equityPeak = equity;
            }
            BigDecimal drawdown = equityPeak.subtract(equity);
            if (drawdown.compareTo(maxDrawdown) > 0 && equityPeak.compareTo(BigDecimal.ZERO) > 0) {
                maxDrawdown = drawdown;
                maxDrawdownPct = drawdown.divide(equityPeak, 6, RoundingMode.HALF_UP);
            }
        }
        return new Drawdown(maxDrawdown, maxDrawdownPct);
    }

    private record Drawdown(BigDecimal absolute, BigDecimal relative) { }
}
