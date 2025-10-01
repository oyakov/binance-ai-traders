package com.oyakov.binance_trader_macd.backtest;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_shared_model.backtest.BacktestDataset;
import com.oyakov.binance_trader_macd.config.MACDTraderConfig;
import com.oyakov.binance_trader_macd.domain.signal.MACDSignalAnalyzer;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * Integration test for the comprehensive backtesting system using a standalone setup.
 * Tests both synthetic and real data backtesting capabilities without requiring Spring context.
 */
class ComprehensiveBacktestIntegrationTest {

    private ComprehensiveBacktestService backtestService;

    @BeforeEach
    void setUp() {
        MACDSignalAnalyzer signalAnalyzer = new MACDSignalAnalyzer();
        MACDTraderConfig traderConfig = new MACDTraderConfig();
        traderConfig.getTrader().setSlidingWindowSize(35);
        traderConfig.getTrader().setOrderQuantity(BigDecimal.valueOf(0.01));

        BacktestMetricsCalculator metricsCalculator = new BacktestMetricsCalculator();
        StubBinanceHistoricalDataFetcher dataFetcher = new StubBinanceHistoricalDataFetcher();
        dataFetcher.register("BTCUSDT", "1h", 7, createDeterministicDataset("BTCUSDT", "1h", 7 * 24));
        dataFetcher.register("BTCUSDT", "1h", 3, createDeterministicDataset("BTCUSDT", "1h", 3 * 24));
        dataFetcher.register("BTCUSDT", "4h", 7, createDeterministicDataset("BTCUSDT", "4h", 7 * 6));
        dataFetcher.register("BTCUSDT", "4h", 3, createDeterministicDataset("BTCUSDT", "4h", 3 * 6));

        BacktestDatasetLoader datasetLoader = new BacktestDatasetLoader(new ObjectMapper());

        backtestService = new ComprehensiveBacktestService(
                signalAnalyzer,
                traderConfig,
                metricsCalculator,
                dataFetcher,
                datasetLoader
        );
    }

    @Test
    void shouldRunSyntheticBacktestSuccessfully() {
        // Given
        String symbol = "BTCUSDT";
        String interval = "1h";
        int dataPoints = 200; // 200 hours of data
        BigDecimal initialCapital = BigDecimal.valueOf(10000);

        // When
        BacktestResult result = backtestService.runSyntheticBacktest(symbol, interval, dataPoints, initialCapital);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.isSuccess()).isTrue();
        assertThat(result.getDataset()).isNotNull();
        assertThat(result.getDataset().getSymbol()).isEqualTo(symbol);
        assertThat(result.getDataset().getInterval()).isEqualTo(interval);
        assertThat(result.getDataset().getKlines()).hasSize(dataPoints);
        
        assertThat(result.getMetrics()).isNotNull();
        assertThat(result.getMetrics().getDatasetName()).contains("Synthetic");
        assertThat(result.getMetrics().getSymbol()).isEqualTo(symbol);
        assertThat(result.getMetrics().getInterval()).isEqualTo(interval);
        assertThat(result.getMetrics().getTotalTrades()).isGreaterThanOrEqualTo(0);
        
        assertThat(result.getAnalysis()).isNotNull();
        assertThat(result.getAnalysis().getSummary()).isNotBlank();
        assertThat(result.getAnalysis().getRecommendations()).isNotEmpty();
        assertThat(result.getAnalysis().getRiskAssessment()).isNotBlank();
        
        assertThat(result.getTrades()).isNotNull();
        
        // Log results for inspection
        System.out.println("=== SYNTHETIC BACKTEST RESULTS ===");
        System.out.println("Dataset: " + result.getDataset().getName());
        System.out.println("Total Trades: " + result.getMetrics().getTotalTrades());
        System.out.println("Win Rate: " + result.getMetrics().getWinRate());
        System.out.println("Net Profit: " + result.getMetrics().getNetProfit());
        System.out.println("Max Drawdown: " + result.getMetrics().getMaxDrawdown());
        System.out.println("Sharpe Ratio: " + result.getMetrics().getSharpeRatio());
        System.out.println("Summary: " + result.getAnalysis().getSummary());
        System.out.println("Risk Assessment: " + result.getAnalysis().getRiskAssessment());
    }

    @Test
    void shouldRunRealDataBacktestSuccessfully() {
        // Given
        String symbol = "BTCUSDT";
        String interval = "1h";
        int days = 7; // 7 days of data
        BigDecimal initialCapital = BigDecimal.valueOf(10000);

        // When
        BacktestResult result = backtestService.runRealDataBacktest(symbol, interval, days, initialCapital);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getDataset()).isNotNull();
        assertThat(result.getDataset().getSymbol()).isEqualTo(symbol);
        assertThat(result.getDataset().getInterval()).isEqualTo(interval);
        
        assertThat(result.getMetrics()).isNotNull();
        assertThat(result.getMetrics().getSymbol()).isEqualTo(symbol);
        assertThat(result.getMetrics().getInterval()).isEqualTo(interval);
        
        assertThat(result.getAnalysis()).isNotNull();
        assertThat(result.getAnalysis().getSummary()).isNotBlank();
        
        // Log results for inspection
        System.out.println("=== REAL DATA BACKTEST RESULTS ===");
        System.out.println("Dataset: " + result.getDataset().getName());
        System.out.println("Klines: " + result.getDataset().getKlines().size());
        System.out.println("Total Trades: " + result.getMetrics().getTotalTrades());
        System.out.println("Win Rate: " + result.getMetrics().getWinRate());
        System.out.println("Net Profit: " + result.getMetrics().getNetProfit());
        System.out.println("Max Drawdown: " + result.getMetrics().getMaxDrawdown());
        System.out.println("Sharpe Ratio: " + result.getMetrics().getSharpeRatio());
        System.out.println("Summary: " + result.getAnalysis().getSummary());
        System.out.println("Risk Assessment: " + result.getAnalysis().getRiskAssessment());
    }

    @Test
    void shouldRunRealDataBacktestsAcrossMultipleScopes() {
        // Given
        String symbol = "BTCUSDT";
        List<String> intervals = List.of("1h", "4h");
        List<Integer> dayRanges = List.of(3, 7);
        BigDecimal initialCapital = BigDecimal.valueOf(10000);

        // When
        MultiScopeBacktestReport report = backtestService.runRealDataBacktestAcrossScopes(symbol, intervals, dayRanges, initialCapital);

        // Then
        assertThat(report).isNotNull();
        assertThat(report.getScopeResults()).hasSize(intervals.size() * dayRanges.size());
        assertThat(report.getOverallSummary()).isNotBlank();
        assertThat(report.getKeyFindings()).isNotEmpty();
        assertThat(report.getRiskWarnings()).isNotEmpty();
        assertThat(report.getNextSteps()).isNotEmpty();

        // Log aggregated report for inspection
        System.out.println("=== MULTI-SCOPE BACKTEST REPORT ===");
        System.out.println(report.getOverallSummary());
        report.getScopeResults().forEach(scope -> System.out.println(" - " + scope.getHeadline()));
        System.out.println("Key Findings: " + report.getKeyFindings());
        System.out.println("Risk Warnings: " + report.getRiskWarnings());
        System.out.println("Next Steps: " + report.getNextSteps());
    }

    @Test
    void shouldValidateScopeInputsForMultiScopeBacktest() {
        BigDecimal initialCapital = BigDecimal.valueOf(10000);

        assertThatThrownBy(() -> backtestService.runRealDataBacktestAcrossScopes("BTCUSDT", List.of(), List.of(3), initialCapital))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("interval");

        assertThatThrownBy(() -> backtestService.runRealDataBacktestAcrossScopes("BTCUSDT", List.of("1h"), List.of(), initialCapital))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("day range");
    }

    @Test
    void shouldHandleEmptyDatasetGracefully() {
        // Given
        String symbol = "INVALID";
        String interval = "1h";
        int days = 1;
        BigDecimal initialCapital = BigDecimal.valueOf(10000);

        // When
        BacktestResult result = backtestService.runRealDataBacktest(symbol, interval, days, initialCapital);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.isSuccess()).isFalse();
        assertThat(result.getAnalysis().getSummary()).contains("No data available");
    }

    @Test
    void shouldGenerateComprehensiveMetrics() {
        // Given
        String symbol = "BTCUSDT";
        String interval = "1h";
        int dataPoints = 500; // More data for better metrics
        BigDecimal initialCapital = BigDecimal.valueOf(10000);

        // When
        BacktestResult result = backtestService.runSyntheticBacktest(symbol, interval, dataPoints, initialCapital);

        // Then
        BacktestMetrics metrics = result.getMetrics();
        assertThat(metrics).isNotNull();
        
        // Verify all major metrics are calculated
        assertThat(metrics.getDatasetName()).isNotBlank();
        assertThat(metrics.getSymbol()).isEqualTo(symbol);
        assertThat(metrics.getInterval()).isEqualTo(interval);
        assertThat(metrics.getTotalTrades()).isGreaterThanOrEqualTo(0);
        assertThat(metrics.getWinRate()).isNotNull();
        assertThat(metrics.getLossRate()).isNotNull();
        assertThat(metrics.getNetProfit()).isNotNull();
        assertThat(metrics.getMaxDrawdown()).isNotNull();
        assertThat(metrics.getMaxDrawdownPercent()).isNotNull();
        assertThat(metrics.getSharpeRatio()).isNotNull();
        assertThat(metrics.getSortinoRatio()).isNotNull();
        assertThat(metrics.getProfitFactor()).isNotNull();
        assertThat(metrics.getBestTrade()).isNotNull();
        assertThat(metrics.getWorstTrade()).isNotNull();
        assertThat(metrics.getAverageWin()).isNotNull();
        assertThat(metrics.getAverageLoss()).isNotNull();
        assertThat(metrics.getMaxConsecutiveWins()).isGreaterThanOrEqualTo(0);
        assertThat(metrics.getMaxConsecutiveLosses()).isGreaterThanOrEqualTo(0);
        assertThat(metrics.getAverageTradeDurationHours()).isNotNull();
        assertThat(metrics.getTradingFrequency()).isNotNull();
        assertThat(metrics.getInitialPrice()).isNotNull();
        assertThat(metrics.getFinalPrice()).isNotNull();
        assertThat(metrics.getMarketReturn()).isNotNull();
        assertThat(metrics.getRecoveryFactor()).isNotNull();
        assertThat(metrics.getCalmarRatio()).isNotNull();
        assertThat(metrics.getExpectancy()).isNotNull();
        assertThat(metrics.getKellyPercentage()).isNotNull();
        
        // Log comprehensive metrics
        System.out.println("=== COMPREHENSIVE METRICS ===");
        System.out.println("Basic Stats:");
        System.out.println("  Total Trades: " + metrics.getTotalTrades());
        System.out.println("  Winning Trades: " + metrics.getWinningTrades());
        System.out.println("  Losing Trades: " + metrics.getLosingTrades());
        System.out.println("  Win Rate: " + metrics.getWinRate());
        System.out.println("  Loss Rate: " + metrics.getLossRate());
        
        System.out.println("Profitability:");
        System.out.println("  Net Profit: " + metrics.getNetProfit());
        System.out.println("  Net Profit %: " + metrics.getNetProfitPercent());
        System.out.println("  Average Return: " + metrics.getAverageReturn());
        System.out.println("  Best Trade: " + metrics.getBestTrade());
        System.out.println("  Worst Trade: " + metrics.getWorstTrade());
        System.out.println("  Average Win: " + metrics.getAverageWin());
        System.out.println("  Average Loss: " + metrics.getAverageLoss());
        
        System.out.println("Risk Metrics:");
        System.out.println("  Max Drawdown: " + metrics.getMaxDrawdown());
        System.out.println("  Max Drawdown %: " + metrics.getMaxDrawdownPercent());
        System.out.println("  Sharpe Ratio: " + metrics.getSharpeRatio());
        System.out.println("  Sortino Ratio: " + metrics.getSortinoRatio());
        System.out.println("  Profit Factor: " + metrics.getProfitFactor());
        System.out.println("  Recovery Factor: " + metrics.getRecoveryFactor());
        System.out.println("  Calmar Ratio: " + metrics.getCalmarRatio());
        
        System.out.println("Consecutive Trades:");
        System.out.println("  Max Consecutive Wins: " + metrics.getMaxConsecutiveWins());
        System.out.println("  Max Consecutive Losses: " + metrics.getMaxConsecutiveLosses());
        System.out.println("  Current Consecutive Wins: " + metrics.getCurrentConsecutiveWins());
        System.out.println("  Current Consecutive Losses: " + metrics.getCurrentConsecutiveLosses());
        
        System.out.println("Time Analysis:");
        System.out.println("  Average Trade Duration (hours): " + metrics.getAverageTradeDurationHours());
        System.out.println("  Total Trading Time (hours): " + metrics.getTotalTradingTimeHours());
        System.out.println("  Trading Frequency (trades/day): " + metrics.getTradingFrequency());
        
        System.out.println("Market Analysis:");
        System.out.println("  Initial Price: " + metrics.getInitialPrice());
        System.out.println("  Final Price: " + metrics.getFinalPrice());
        System.out.println("  Market Return: " + metrics.getMarketReturn());
        System.out.println("  Strategy Outperformance: " + metrics.getStrategyOutperformance());
        
        System.out.println("Additional Metrics:");
        System.out.println("  Expectancy: " + metrics.getExpectancy());
        System.out.println("  Kelly Percentage: " + metrics.getKellyPercentage());
    }
    private BacktestDataset createDeterministicDataset(String symbol, String interval, int candles) {
        List<KlineEvent> klines = new ArrayList<>(candles);
        long stepMillis = intervalToMillis(interval);
        long currentTime = System.currentTimeMillis() - (long) candles * stepMillis;
        BigDecimal previousClose = BigDecimal.valueOf(50000);

        for (int i = 0; i < candles; i++) {
            double oscillation = Math.sin(i / 5.0) * 0.02 + Math.cos(i / 9.0) * 0.01;
            double drift = (i % 10 - 5) * 0.0008;
            double delta = oscillation + drift;

            BigDecimal open = previousClose;
            BigDecimal close = open.multiply(BigDecimal.ONE.add(BigDecimal.valueOf(delta))).setScale(8, RoundingMode.HALF_UP);

            if (close.compareTo(BigDecimal.ZERO) <= 0) {
                close = open.abs().add(BigDecimal.ONE);
            }

            BigDecimal high = close.max(open).multiply(BigDecimal.valueOf(1.01)).setScale(8, RoundingMode.HALF_UP);
            BigDecimal low = close.min(open).multiply(BigDecimal.valueOf(0.99)).setScale(8, RoundingMode.HALF_UP);
            BigDecimal volume = BigDecimal.valueOf(1000 + (i % 5) * 250L);

            klines.add(new KlineEvent(
                    "kline",
                    currentTime,
                    symbol,
                    interval,
                    currentTime,
                    currentTime + stepMillis,
                    open,
                    high,
                    low,
                    close,
                    volume
            ));

            currentTime += stepMillis;
            previousClose = close;
        }

        return BacktestDataset.builder()
                .name(symbol + "_" + interval)
                .symbol(symbol)
                .interval(interval)
                .collectedAt(Instant.now())
                .klines(klines)
                .build();
    }

    private long intervalToMillis(String interval) {
        return switch (interval) {
            case "1m" -> 60 * 1000L;
            case "3m" -> 3 * 60 * 1000L;
            case "5m" -> 5 * 60 * 1000L;
            case "15m" -> 15 * 60 * 1000L;
            case "30m" -> 30 * 60 * 1000L;
            case "1h" -> 60 * 60 * 1000L;
            case "2h" -> 2 * 60 * 60 * 1000L;
            case "4h" -> 4 * 60 * 60 * 1000L;
            case "6h" -> 6 * 60 * 60 * 1000L;
            case "8h" -> 8 * 60 * 60 * 1000L;
            case "12h" -> 12 * 60 * 60 * 1000L;
            case "1d" -> 24 * 60 * 60 * 1000L;
            case "3d" -> 3 * 24 * 60 * 60 * 1000L;
            case "1w" -> 7 * 24 * 60 * 60 * 1000L;
            case "1M" -> 30L * 24 * 60 * 60 * 1000L;
            default -> 60 * 1000L;
        };
    }

    private static class StubBinanceHistoricalDataFetcher extends BinanceHistoricalDataFetcher {

        private final Map<String, BacktestDataset> datasets = new HashMap<>();

        StubBinanceHistoricalDataFetcher() {
            super(new RestTemplate());
        }

        void register(String symbol, String interval, int days, BacktestDataset dataset) {
            String key = key(symbol, interval, days);
            datasets.put(key, BacktestDataset.builder()
                    .name(String.format("%s_%s_%ddays", symbol, interval, days))
                    .symbol(dataset.getSymbol())
                    .interval(dataset.getInterval())
                    .collectedAt(dataset.getCollectedAt())
                    .klines(dataset.getKlines())
                    .build());
        }

        @Override
        public BacktestDataset fetchLastNDays(String symbol, String interval, int days, String datasetName) {
            return datasets.getOrDefault(
                    key(symbol, interval, days),
                    BacktestDataset.builder()
                            .name(datasetName)
                            .symbol(symbol)
                            .interval(interval)
                            .collectedAt(Instant.now())
                            .klines(List.of())
                            .build()
            );
        }

        private String key(String symbol, String interval, int days) {
            return symbol + "|" + interval + "|" + days;
        }
    }
}
