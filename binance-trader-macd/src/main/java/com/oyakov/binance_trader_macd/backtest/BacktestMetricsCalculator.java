package com.oyakov.binance_trader_macd.backtest;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;
import java.time.Duration;
import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

@Component
@Log4j2
public class BacktestMetricsCalculator {

    private static final MathContext MATH_CONTEXT = MathContext.DECIMAL64;
    private static final int MONEY_SCALE = 2;
    private static final int PERCENT_SCALE = 4;
    private static final BigDecimal RISK_FREE_RATE = BigDecimal.valueOf(0.02); // 2% annual risk-free rate

    public BacktestMetrics calculate(String datasetName, List<SimulatedTrade> trades) {
        return calculate(datasetName, null, null, null, trades, null);
    }

    public BacktestMetrics calculate(String datasetName, String symbol, String interval, 
                                   List<KlineEvent> klines, List<SimulatedTrade> trades, 
                                   BigDecimal initialCapital) {
        if (trades.isEmpty()) {
            return createEmptyMetrics(datasetName, symbol, interval, klines);
        }

        // Basic trade statistics
        int total = trades.size();
        int winning = (int) trades.stream().filter(trade -> trade.getProfit().compareTo(BigDecimal.ZERO) > 0).count();
        int losing = (int) trades.stream().filter(trade -> trade.getProfit().compareTo(BigDecimal.ZERO) < 0).count();
        int breakEven = total - winning - losing;

        // Profitability metrics
        BigDecimal netProfit = trades.stream()
                .map(SimulatedTrade::getProfit)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal netProfitRounded = scaleMoney(netProfit);

        BigDecimal winRate = total == 0 ? BigDecimal.ZERO : BigDecimal.valueOf(winning)
                .divide(BigDecimal.valueOf(total), 4, RoundingMode.HALF_UP);
        BigDecimal lossRate = total == 0 ? BigDecimal.ZERO : BigDecimal.valueOf(losing)
                .divide(BigDecimal.valueOf(total), 4, RoundingMode.HALF_UP);
        BigDecimal winRateRounded = scalePercent(winRate);
        BigDecimal lossRateRounded = scalePercent(lossRate);

        // Trade analysis
        List<BigDecimal> profits = trades.stream().map(SimulatedTrade::getProfit).collect(Collectors.toList());
        List<BigDecimal> returns = trades.stream().map(SimulatedTrade::getReturnPercentage).collect(Collectors.toList());
        
        BigDecimal bestTrade = profits.stream().max(Comparator.naturalOrder()).orElse(BigDecimal.ZERO);
        BigDecimal worstTrade = profits.stream().min(Comparator.naturalOrder()).orElse(BigDecimal.ZERO);
        BigDecimal bestTradeRounded = scaleMoney(bestTrade);
        BigDecimal worstTradeRounded = scaleMoney(worstTrade);

        BigDecimal averageWin = winning == 0 ? BigDecimal.ZERO :
                profits.stream().filter(p -> p.compareTo(BigDecimal.ZERO) > 0)
                        .reduce(BigDecimal.ZERO, BigDecimal::add)
                        .divide(BigDecimal.valueOf(winning), MATH_CONTEXT);

        BigDecimal averageLoss = losing == 0 ? BigDecimal.ZERO :
                profits.stream().filter(p -> p.compareTo(BigDecimal.ZERO) < 0)
                        .reduce(BigDecimal.ZERO, BigDecimal::add)
                        .divide(BigDecimal.valueOf(losing), MATH_CONTEXT);

        BigDecimal averageWinRounded = scaleMoney(averageWin);
        BigDecimal averageLossRounded = scaleMoney(averageLoss);

        BigDecimal averageReturn = total == 0 ? BigDecimal.ZERO :
                returns.stream().reduce(BigDecimal.ZERO, BigDecimal::add)
                        .divide(BigDecimal.valueOf(total), MATH_CONTEXT);
        BigDecimal averageReturnRounded = scalePercent(averageReturn);

        // Risk metrics
        Drawdown drawdown = calculateDrawdown(trades);
        BigDecimal sharpeRatio = calculateSharpeRatio(returns);
        BigDecimal sortinoRatio = calculateSortinoRatio(returns);
        BigDecimal profitFactor = calculateProfitFactor(trades);
        BigDecimal maxDrawdown = scaleMoney(drawdown.absolute());
        BigDecimal maxDrawdownPercent = scalePercent(drawdown.relative());
        BigDecimal sharpeRatioRounded = scaleMetric(sharpeRatio);
        BigDecimal sortinoRatioRounded = scaleMetric(sortinoRatio);
        BigDecimal profitFactorRounded = scaleMetric(profitFactor);

        // Consecutive trades analysis
        ConsecutiveTrades consecutiveTrades = calculateConsecutiveTrades(trades);

        // Time analysis
        TimeAnalysis timeAnalysis = calculateTimeAnalysis(trades, klines);

        // Market analysis
        MarketAnalysis marketAnalysis = calculateMarketAnalysis(klines, initialCapital, netProfit);

        // Additional metrics
        BigDecimal recoveryFactor = drawdown.absolute().compareTo(BigDecimal.ZERO) > 0 ?
                netProfit.divide(drawdown.absolute(), MATH_CONTEXT) : BigDecimal.ZERO;

        BigDecimal calmarRatio = drawdown.relative().compareTo(BigDecimal.ZERO) > 0 ?
                averageReturn.multiply(BigDecimal.valueOf(252)).divide(drawdown.relative(), MATH_CONTEXT) : BigDecimal.ZERO;

        BigDecimal expectancy = calculateExpectancy(trades);
        BigDecimal kellyPercentage = calculateKellyPercentage(winRate, averageWin, averageLoss);

        BigDecimal recoveryFactorRounded = scaleMetric(recoveryFactor);
        BigDecimal calmarRatioRounded = scaleMetric(calmarRatio);
        BigDecimal expectancyRounded = scaleMoney(expectancy);
        BigDecimal kellyPercentageRounded = scalePercent(kellyPercentage);

        return BacktestMetrics.builder()
                .datasetName(datasetName)
                .symbol(symbol)
                .interval(interval)
                .startTime(timeAnalysis.startTime)
                .endTime(timeAnalysis.endTime)
                .duration(timeAnalysis.duration)
                .totalTrades(total)
                .winningTrades(winning)
                .losingTrades(losing)
                .breakEvenTrades(breakEven)
                .netProfit(netProfitRounded)
                .netProfitPercent(scalePercent(marketAnalysis.netProfitPercent))
                .averageReturn(averageReturnRounded)
                .winRate(winRateRounded)
                .lossRate(lossRateRounded)
                .maxDrawdown(maxDrawdown)
                .maxDrawdownPercent(maxDrawdownPercent)
                .sharpeRatio(sharpeRatioRounded)
                .sortinoRatio(sortinoRatioRounded)
                .profitFactor(profitFactorRounded)
                .bestTrade(bestTradeRounded)
                .worstTrade(worstTradeRounded)
                .averageWin(averageWinRounded)
                .averageLoss(averageLossRounded)
                .largestWin(bestTradeRounded)
                .largestLoss(worstTradeRounded)
                .maxConsecutiveWins(consecutiveTrades.maxWins)
                .maxConsecutiveLosses(consecutiveTrades.maxLosses)
                .currentConsecutiveWins(consecutiveTrades.currentWins)
                .currentConsecutiveLosses(consecutiveTrades.currentLosses)
                .averageTradeDurationHours(scale(timeAnalysis.averageTradeDurationHours, MONEY_SCALE))
                .totalTradingTimeHours(scale(timeAnalysis.totalTradingTimeHours, MONEY_SCALE))
                .tradingFrequency(scaleMetric(timeAnalysis.tradingFrequency))
                .initialPrice(scaleMoney(marketAnalysis.initialPrice))
                .finalPrice(scaleMoney(marketAnalysis.finalPrice))
                .marketReturn(scalePercent(marketAnalysis.marketReturn))
                .strategyOutperformance(scalePercent(marketAnalysis.strategyOutperformance))
                .recoveryFactor(recoveryFactorRounded)
                .calmarRatio(calmarRatioRounded)
                .expectancy(expectancyRounded)
                .kellyPercentage(kellyPercentageRounded)
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

    private BigDecimal calculateSharpeRatio(List<BigDecimal> returns) {
        if (returns.isEmpty()) return BigDecimal.ZERO;
        
        BigDecimal mean = returns.stream().reduce(BigDecimal.ZERO, BigDecimal::add)
                .divide(BigDecimal.valueOf(returns.size()), MATH_CONTEXT);
        
        BigDecimal variance = returns.stream()
                .map(r -> r.subtract(mean).pow(2))
                .reduce(BigDecimal.ZERO, BigDecimal::add)
                .divide(BigDecimal.valueOf(returns.size()), MATH_CONTEXT);
        
        BigDecimal stdDev = sqrt(variance);
        if (stdDev.compareTo(BigDecimal.ZERO) == 0) return BigDecimal.ZERO;
        
        return mean.subtract(RISK_FREE_RATE.divide(BigDecimal.valueOf(252), MATH_CONTEXT))
                .divide(stdDev, MATH_CONTEXT);
    }

    private BigDecimal calculateSortinoRatio(List<BigDecimal> returns) {
        if (returns.isEmpty()) return BigDecimal.ZERO;
        
        BigDecimal mean = returns.stream().reduce(BigDecimal.ZERO, BigDecimal::add)
                .divide(BigDecimal.valueOf(returns.size()), MATH_CONTEXT);
        
        BigDecimal downsideVariance = returns.stream()
                .filter(r -> r.compareTo(BigDecimal.ZERO) < 0)
                .map(r -> r.pow(2))
                .reduce(BigDecimal.ZERO, BigDecimal::add)
                .divide(BigDecimal.valueOf(returns.size()), MATH_CONTEXT);
        
        BigDecimal downsideStdDev = sqrt(downsideVariance);
        if (downsideStdDev.compareTo(BigDecimal.ZERO) == 0) return BigDecimal.ZERO;
        
        return mean.subtract(RISK_FREE_RATE.divide(BigDecimal.valueOf(252), MATH_CONTEXT))
                .divide(downsideStdDev, MATH_CONTEXT);
    }

    private BigDecimal calculateProfitFactor(List<SimulatedTrade> trades) {
        BigDecimal grossProfit = trades.stream()
                .filter(t -> t.getProfit().compareTo(BigDecimal.ZERO) > 0)
                .map(SimulatedTrade::getProfit)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        BigDecimal grossLoss = trades.stream()
                .filter(t -> t.getProfit().compareTo(BigDecimal.ZERO) < 0)
                .map(SimulatedTrade::getProfit)
                .map(BigDecimal::abs)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        if (grossLoss.compareTo(BigDecimal.ZERO) == 0) return BigDecimal.ZERO;
        return grossProfit.divide(grossLoss, MATH_CONTEXT);
    }

    private ConsecutiveTrades calculateConsecutiveTrades(List<SimulatedTrade> trades) {
        int maxWins = 0, maxLosses = 0;
        int currentWins = 0, currentLosses = 0;
        int currentConsecutiveWins = 0, currentConsecutiveLosses = 0;
        
        for (SimulatedTrade trade : trades) {
            if (trade.getProfit().compareTo(BigDecimal.ZERO) > 0) {
                currentWins++;
                currentLosses = 0;
                currentConsecutiveWins = currentWins;
                currentConsecutiveLosses = 0;
                maxWins = Math.max(maxWins, currentWins);
            } else if (trade.getProfit().compareTo(BigDecimal.ZERO) < 0) {
                currentLosses++;
                currentWins = 0;
                currentConsecutiveWins = 0;
                currentConsecutiveLosses = currentLosses;
                maxLosses = Math.max(maxLosses, currentLosses);
            } else {
                currentWins = 0;
                currentLosses = 0;
                currentConsecutiveWins = 0;
                currentConsecutiveLosses = 0;
            }
        }
        
        return new ConsecutiveTrades(maxWins, maxLosses, currentConsecutiveWins, currentConsecutiveLosses);
    }

    private TimeAnalysis calculateTimeAnalysis(List<SimulatedTrade> trades, List<KlineEvent> klines) {
        if (trades.isEmpty()) {
            return new TimeAnalysis(null, null, null, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO);
        }
        
        Instant startTime = trades.stream()
                .map(SimulatedTrade::getEntryTime)
                .min(Comparator.naturalOrder())
                .orElse(Instant.now());
        
        Instant endTime = trades.stream()
                .map(SimulatedTrade::getExitTime)
                .max(Comparator.naturalOrder())
                .orElse(Instant.now());
        
        Duration duration = Duration.between(startTime, endTime);
        
        BigDecimal totalTradeDurationMinutes = trades.stream()
                .map(trade -> BigDecimal.valueOf(Duration.between(trade.getEntryTime(), trade.getExitTime()).toMinutes()))
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal averageTradeDurationHours = trades.isEmpty() ? BigDecimal.ZERO :
                totalTradeDurationMinutes
                        .divide(BigDecimal.valueOf(trades.size()), MATH_CONTEXT)
                        .divide(BigDecimal.valueOf(60), MATH_CONTEXT);

        BigDecimal totalTradingTimeHours = BigDecimal.valueOf(duration.toMinutes())
                .divide(BigDecimal.valueOf(60), MATH_CONTEXT);

        BigDecimal totalTradingTimeDays = totalTradingTimeHours
                .divide(BigDecimal.valueOf(24), MATH_CONTEXT);

        BigDecimal tradingFrequency = totalTradingTimeDays.compareTo(BigDecimal.ZERO) > 0 ?
                BigDecimal.valueOf(trades.size()).divide(totalTradingTimeDays, MATH_CONTEXT) :
                BigDecimal.ZERO;

        return new TimeAnalysis(startTime, endTime, duration, averageTradeDurationHours, totalTradingTimeHours, tradingFrequency);
    }

    private MarketAnalysis calculateMarketAnalysis(List<KlineEvent> klines, BigDecimal initialCapital, BigDecimal netProfit) {
        if (klines == null || klines.isEmpty()) {
            return new MarketAnalysis(BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO);
        }

        BigDecimal rawInitialPrice = klines.get(0).getClose();
        BigDecimal rawFinalPrice = klines.get(klines.size() - 1).getClose();
        BigDecimal marketReturn = rawFinalPrice.subtract(rawInitialPrice).divide(rawInitialPrice, MATH_CONTEXT);

        BigDecimal netProfitPercent;
        BigDecimal strategyOutperformance;

        if (initialCapital != null && initialCapital.compareTo(BigDecimal.ZERO) > 0) {
            netProfitPercent = netProfit.divide(initialCapital, MATH_CONTEXT);
            strategyOutperformance = netProfitPercent.subtract(marketReturn);
        } else {
            netProfitPercent = marketReturn;
            strategyOutperformance = BigDecimal.ZERO;
        }

        return new MarketAnalysis(rawInitialPrice, rawFinalPrice, marketReturn, netProfitPercent, strategyOutperformance);
    }

    private BigDecimal calculateExpectancy(List<SimulatedTrade> trades) {
        if (trades.isEmpty()) return BigDecimal.ZERO;
        
        BigDecimal totalProfit = trades.stream()
                .map(SimulatedTrade::getProfit)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        return totalProfit.divide(BigDecimal.valueOf(trades.size()), MATH_CONTEXT);
    }

    private BigDecimal calculateKellyPercentage(BigDecimal winRate, BigDecimal averageWin, BigDecimal averageLoss) {
        if (averageLoss.compareTo(BigDecimal.ZERO) == 0) return BigDecimal.ZERO;
        
        BigDecimal winLossRatio = averageWin.divide(averageLoss.abs(), MATH_CONTEXT);
        BigDecimal kelly = winRate.multiply(winLossRatio).subtract(BigDecimal.ONE.subtract(winRate));
        
        return kelly.max(BigDecimal.ZERO).min(BigDecimal.ONE);
    }

    private BacktestMetrics createEmptyMetrics(String datasetName, String symbol, String interval, List<KlineEvent> klines) {
        return BacktestMetrics.builder()
                .datasetName(datasetName)
                .symbol(symbol)
                .interval(interval)
                .totalTrades(0)
                .winningTrades(0)
                .losingTrades(0)
                .breakEvenTrades(0)
                .netProfit(BigDecimal.ZERO)
                .netProfitPercent(BigDecimal.ZERO)
                .averageReturn(BigDecimal.ZERO)
                .winRate(BigDecimal.ZERO)
                .lossRate(BigDecimal.ZERO)
                .maxDrawdown(BigDecimal.ZERO)
                .maxDrawdownPercent(BigDecimal.ZERO)
                .sharpeRatio(BigDecimal.ZERO)
                .sortinoRatio(BigDecimal.ZERO)
                .profitFactor(BigDecimal.ZERO)
                .bestTrade(BigDecimal.ZERO)
                .worstTrade(BigDecimal.ZERO)
                .averageWin(BigDecimal.ZERO)
                .averageLoss(BigDecimal.ZERO)
                .largestWin(BigDecimal.ZERO)
                .largestLoss(BigDecimal.ZERO)
                .maxConsecutiveWins(0)
                .maxConsecutiveLosses(0)
                .currentConsecutiveWins(0)
                .currentConsecutiveLosses(0)
                .averageTradeDurationHours(BigDecimal.ZERO)
                .totalTradingTimeHours(BigDecimal.ZERO)
                .tradingFrequency(BigDecimal.ZERO)
                .initialPrice(klines != null && !klines.isEmpty() ? klines.get(0).getClose() : BigDecimal.ZERO)
                .finalPrice(klines != null && !klines.isEmpty() ? klines.get(klines.size() - 1).getClose() : BigDecimal.ZERO)
                .marketReturn(BigDecimal.ZERO)
                .strategyOutperformance(BigDecimal.ZERO)
                .recoveryFactor(BigDecimal.ZERO)
                .calmarRatio(BigDecimal.ZERO)
                .expectancy(BigDecimal.ZERO)
                .kellyPercentage(BigDecimal.ZERO)
                .build();
    }

    private BigDecimal sqrt(BigDecimal value) {
        if (value.compareTo(BigDecimal.ZERO) < 0) return BigDecimal.ZERO;
        if (value.compareTo(BigDecimal.ZERO) == 0) return BigDecimal.ZERO;
        
        BigDecimal x = value;
        BigDecimal y = value.add(BigDecimal.ONE).divide(BigDecimal.valueOf(2), MATH_CONTEXT);
        
        while (y.subtract(x).abs().compareTo(BigDecimal.valueOf(0.0001)) > 0) {
            x = y;
            y = value.divide(x, MATH_CONTEXT).add(x).divide(BigDecimal.valueOf(2), MATH_CONTEXT);
        }
        
        return x;
    }

    private record Drawdown(BigDecimal absolute, BigDecimal relative) { }
    private record ConsecutiveTrades(int maxWins, int maxLosses, int currentWins, int currentLosses) { }
    private record TimeAnalysis(Instant startTime, Instant endTime, Duration duration, 
                              BigDecimal averageTradeDurationHours, BigDecimal totalTradingTimeHours, 
                              BigDecimal tradingFrequency) { }
    private record MarketAnalysis(BigDecimal initialPrice, BigDecimal finalPrice, BigDecimal marketReturn,
                                BigDecimal netProfitPercent, BigDecimal strategyOutperformance) { }

    private BigDecimal scaleMoney(BigDecimal value) {
        return scale(value, MONEY_SCALE);
    }

    private BigDecimal scalePercent(BigDecimal value) {
        return scale(value, PERCENT_SCALE);
    }

    private BigDecimal scaleMetric(BigDecimal value) {
        return scale(value, PERCENT_SCALE);
    }

    private BigDecimal scale(BigDecimal value, int scale) {
        return value.setScale(scale, RoundingMode.HALF_UP);
    }
}
