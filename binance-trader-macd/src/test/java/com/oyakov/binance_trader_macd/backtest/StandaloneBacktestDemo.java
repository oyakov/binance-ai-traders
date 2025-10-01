package com.oyakov.binance_trader_macd.backtest;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_shared_model.backtest.BacktestDataset;
import com.oyakov.binance_trader_macd.config.MACDTraderConfig;
import com.oyakov.binance_trader_macd.domain.signal.MACDSignalAnalyzer;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Standalone demonstration of the comprehensive backtesting system.
 * This test shows how to use the backtesting components without Spring Boot context.
 */
class StandaloneBacktestDemo {

    @Test
    void demonstrateComprehensiveBacktesting() {
        System.out.println("=== COMPREHENSIVE BACKTESTING DEMONSTRATION ===");
        
        // 1. Create synthetic dataset
        BacktestDataset dataset = createSyntheticDataset("BTCUSDT", "1h", 500);
        System.out.println("Created synthetic dataset with " + dataset.getKlines().size() + " klines");
        
        // 2. Initialize backtesting components
        MACDSignalAnalyzer signalAnalyzer = new MACDSignalAnalyzer();
        BacktestOrderService orderService = new BacktestOrderService();
        
        // Create a simple trader config
        MACDTraderConfig.Trader traderConfig = new MACDTraderConfig.Trader();
        traderConfig.setSlidingWindowSize(35);
        traderConfig.setOrderQuantity(BigDecimal.valueOf(0.01));
        
        BacktestTraderEngine traderEngine = new BacktestTraderEngine(
                signalAnalyzer,
                orderService,
                traderConfig
        );
        
        // 3. Run the backtest
        System.out.println("Running backtest...");
        for (KlineEvent kline : dataset.getKlines()) {
            traderEngine.onNewKline(kline);
        }
        
        // 4. Get results
        List<SimulatedTrade> trades = orderService.getClosedTrades();
        System.out.println("Backtest completed with " + trades.size() + " trades");
        
        // 5. Calculate comprehensive metrics
        BacktestMetricsCalculator metricsCalculator = new BacktestMetricsCalculator();
        BacktestMetrics metrics = metricsCalculator.calculate(
                dataset.getName(),
                dataset.getSymbol(),
                dataset.getInterval(),
                dataset.getKlines(),
                trades,
                BigDecimal.valueOf(10000)
        );
        
        // 6. Display results
        displayComprehensiveResults(metrics, trades);
        
        // 7. Verify basic functionality
        assertThat(trades).isNotNull();
        assertThat(metrics).isNotNull();
        assertThat(metrics.getTotalTrades()).isGreaterThanOrEqualTo(0);
        assertThat(metrics.getDatasetName()).isEqualTo("Synthetic_BTCUSDT_1h");
        assertThat(metrics.getSymbol()).isEqualTo("BTCUSDT");
        assertThat(metrics.getInterval()).isEqualTo("1h");
        
        System.out.println("=== DEMONSTRATION COMPLETED SUCCESSFULLY ===");
    }

    private BacktestDataset createSyntheticDataset(String symbol, String interval, int dataPoints) {
        List<KlineEvent> klines = new ArrayList<>();
        long currentTime = System.currentTimeMillis() - (dataPoints * 60 * 60 * 1000L);
        BigDecimal basePrice = BigDecimal.valueOf(50000);
        final BigDecimal anchorPrice = basePrice;
        
        for (int i = 0; i < dataPoints; i++) {
            // Generate realistic price movement
            double trend = Math.sin(i / 30.0) * 0.02; // Long-term trend limited to ±2%
            double noise = (Math.random() - 0.5) * 0.01; // Random noise capped at ±1%
            double volatility = Math.sin(i / 7.5) * 0.015; // Volatility cycles limited to ±1.5%
            double reversion = anchorPrice.subtract(basePrice)
                    .divide(anchorPrice, 10, RoundingMode.HALF_UP)
                    .doubleValue() * 0.01; // Gentle pull towards anchor price
            double rawPriceChange = trend + noise + volatility + reversion;
            double priceChange = Math.max(-0.025, Math.min(0.025, rawPriceChange));

            BigDecimal price = basePrice.multiply(BigDecimal.ONE.add(BigDecimal.valueOf(priceChange)));
            
            // Ensure price doesn't go negative
            if (price.compareTo(BigDecimal.ZERO) <= 0) {
                price = basePrice;
            }
            
            // Create realistic OHLC data
            BigDecimal high = price.multiply(BigDecimal.ONE.add(BigDecimal.valueOf(0.02 + Math.random() * 0.03)));
            BigDecimal low = price.multiply(BigDecimal.ONE.subtract(BigDecimal.valueOf(0.02 + Math.random() * 0.03)));
            BigDecimal open = i == 0 ? price : klines.get(i - 1).getClose();
            BigDecimal close = price;
            BigDecimal volume = BigDecimal.valueOf(1000 + Math.random() * 5000);
            
            klines.add(new KlineEvent(
                    "kline",
                    currentTime,
                    symbol,
                    interval,
                    currentTime,
                    currentTime + 3600000, // 1 hour later
                    open,
                    high,
                    low,
                    close,
                    volume
            ));
            
            currentTime += 3600000; // Move forward 1 hour
            basePrice = close; // Update base price for next iteration
        }
        
        return BacktestDataset.builder()
                .name("Synthetic_" + symbol + "_" + interval)
                .symbol(symbol)
                .interval(interval)
                .collectedAt(Instant.now())
                .klines(klines)
                .build();
    }

    private void displayComprehensiveResults(BacktestMetrics metrics, List<SimulatedTrade> trades) {
        System.out.println("\n=== BACKTEST RESULTS ===");
        System.out.println("Dataset: " + metrics.getDatasetName());
        System.out.println("Symbol: " + metrics.getSymbol());
        System.out.println("Interval: " + metrics.getInterval());
        System.out.println("Duration: " + metrics.getDuration());

        System.out.println("\n=== TRADE STATISTICS ===");
        System.out.println("Total Trades: " + metrics.getTotalTrades());
        System.out.println("Winning Trades: " + metrics.getWinningTrades());
        System.out.println("Losing Trades: " + metrics.getLosingTrades());
        System.out.println("Break Even Trades: " + metrics.getBreakEvenTrades());
        System.out.println("Win Rate: " + formatPercent(metrics.getWinRate()) + "%");
        System.out.println("Loss Rate: " + formatPercent(metrics.getLossRate()) + "%");

        System.out.println("\n=== PROFITABILITY METRICS ===");
        System.out.println("Net Profit: $" + formatMoney(metrics.getNetProfit()));
        System.out.println("Net Profit %: " + formatPercent(metrics.getNetProfitPercent()) + "%");
        System.out.println("Average Return: " + formatPercent(metrics.getAverageReturn()) + "%");
        System.out.println("Best Trade: $" + formatMoney(metrics.getBestTrade()));
        System.out.println("Worst Trade: $" + formatMoney(metrics.getWorstTrade()));
        System.out.println("Average Win: $" + formatMoney(metrics.getAverageWin()));
        System.out.println("Average Loss: $" + formatMoney(metrics.getAverageLoss()));

        System.out.println("\n=== RISK METRICS ===");
        System.out.println("Max Drawdown: $" + formatMoney(metrics.getMaxDrawdown()));
        System.out.println("Max Drawdown %: " + formatPercent(metrics.getMaxDrawdownPercent()) + "%");
        System.out.println("Sharpe Ratio: " + formatMetric(metrics.getSharpeRatio()));
        System.out.println("Sortino Ratio: " + formatMetric(metrics.getSortinoRatio()));
        System.out.println("Profit Factor: " + formatMetric(metrics.getProfitFactor()));
        System.out.println("Recovery Factor: " + formatMetric(metrics.getRecoveryFactor()));
        System.out.println("Calmar Ratio: " + formatMetric(metrics.getCalmarRatio()));

        System.out.println("\n=== CONSECUTIVE TRADES ===");
        System.out.println("Max Consecutive Wins: " + metrics.getMaxConsecutiveWins());
        System.out.println("Max Consecutive Losses: " + metrics.getMaxConsecutiveLosses());
        System.out.println("Current Consecutive Wins: " + metrics.getCurrentConsecutiveWins());
        System.out.println("Current Consecutive Losses: " + metrics.getCurrentConsecutiveLosses());

        System.out.println("\n=== TIME ANALYSIS ===");
        System.out.println("Average Trade Duration: " + formatMetric(metrics.getAverageTradeDurationHours()) + " hours");
        System.out.println("Total Trading Time: " + formatMetric(metrics.getTotalTradingTimeHours()) + " hours");
        System.out.println("Trading Frequency: " + formatMetric(metrics.getTradingFrequency()) + " trades/day");

        System.out.println("\n=== MARKET ANALYSIS ===");
        System.out.println("Initial Price: $" + formatMoney(metrics.getInitialPrice()));
        System.out.println("Final Price: $" + formatMoney(metrics.getFinalPrice()));
        System.out.println("Market Return: " + formatPercent(metrics.getMarketReturn()) + "%");
        System.out.println("Strategy Outperformance: " + formatPercent(metrics.getStrategyOutperformance()) + "%");

        System.out.println("\n=== ADDITIONAL METRICS ===");
        System.out.println("Expectancy: $" + formatMoney(metrics.getExpectancy()));
        System.out.println("Kelly Percentage: " + formatPercent(metrics.getKellyPercentage()) + "%");

        System.out.println("\n=== TRADE DETAILS ===");
        if (trades.isEmpty()) {
            System.out.println("No trades executed.");
            return;
        }

        int tradesToShow = Math.min(trades.size(), 10);
        for (int i = 0; i < tradesToShow; i++) {
            SimulatedTrade trade = trades.get(i);
            System.out.println("Trade " + (i + 1) + ": " + trade.getSide() + " $" + formatMoney(trade.getProfit()) +
                    " (" + formatPercent(trade.getReturnPercentage()) + "%)");
        }

        if (trades.size() > tradesToShow) {
            System.out.println("... and " + (trades.size() - tradesToShow) + " more trades");
        }
    }

    private String formatMoney(BigDecimal value) {
        return value.setScale(2, RoundingMode.HALF_UP).toPlainString();
    }

    private String formatPercent(BigDecimal value) {
        return value.multiply(BigDecimal.valueOf(100)).setScale(2, RoundingMode.HALF_UP).toPlainString();
    }

    private String formatMetric(BigDecimal value) {
        return value.setScale(4, RoundingMode.HALF_UP).toPlainString();
    }
}
