package com.oyakov.binance_trader_macd.backtest;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_shared_model.backtest.BacktestDataset;
import com.oyakov.binance_trader_macd.config.MACDTraderConfig;
import com.oyakov.binance_trader_macd.domain.signal.MACDSignalAnalyzer;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Comprehensive backtesting service that can work with both synthetic and real market data.
 * Provides detailed profitability analysis and performance metrics for MACD trading strategies.
 */
@Service
@Log4j2
@RequiredArgsConstructor
public class ComprehensiveBacktestService {

    private final MACDSignalAnalyzer macdSignalAnalyzer;
    private final MACDTraderConfig traderConfig;
    private final BacktestMetricsCalculator metricsCalculator;
    private final BinanceHistoricalDataFetcher dataFetcher;
    private final BacktestDatasetLoader datasetLoader;

    /**
     * Runs a comprehensive backtest using real Binance historical data.
     * 
     * @param symbol Trading pair symbol (e.g., "BTCUSDT")
     * @param interval Kline interval (e.g., "1h", "4h", "1d")
     * @param days Number of days of historical data to fetch
     * @param initialCapital Initial capital for the backtest
     * @return Comprehensive backtest results
     */
    public BacktestResult runRealDataBacktest(String symbol, String interval, int days, BigDecimal initialCapital) {
        log.info("Starting real data backtest for {} {} for {} days with initial capital {}", 
                symbol, interval, days, initialCapital);
        
        try {
            // Fetch historical data from Binance
            BacktestDataset dataset = dataFetcher.fetchLastNDays(symbol, interval, days, 
                    String.format("%s_%s_%ddays", symbol, interval, days));
            
            if (dataset.getKlines().isEmpty()) {
                log.warn("No historical data available for {} {}", symbol, interval);
                return createEmptyResult(symbol, interval, "No data available");
            }
            
            // Run the backtest
            return runBacktest(dataset, initialCapital);
            
        } catch (Exception e) {
            log.error("Error running real data backtest for {} {}", symbol, interval, e);
            return createEmptyResult(symbol, interval, "Error: " + e.getMessage());
        }
    }

    /**
     * Runs a comprehensive backtest using a pre-loaded dataset.
     * 
     * @param datasetPath Path to the dataset file
     * @param initialCapital Initial capital for the backtest
     * @return Comprehensive backtest results
     */
    public BacktestResult runDatasetBacktest(String datasetPath, BigDecimal initialCapital) {
        log.info("Starting dataset backtest from {} with initial capital {}", datasetPath, initialCapital);
        
        try {
            // Load dataset from file
            BacktestDataset dataset = datasetLoader.load(java.nio.file.Path.of(datasetPath));
            
            if (dataset.getKlines().isEmpty()) {
                log.warn("No data available in dataset {}", datasetPath);
                return createEmptyResult(dataset.getName(), "unknown", "No data in dataset");
            }
            
            // Run the backtest
            return runBacktest(dataset, initialCapital);
            
        } catch (Exception e) {
            log.error("Error running dataset backtest from {}", datasetPath, e);
            return createEmptyResult("unknown", "unknown", "Error: " + e.getMessage());
        }
    }

    /**
     * Runs a comprehensive backtest using synthetic data for testing.
     * 
     * @param symbol Trading pair symbol
     * @param interval Kline interval
     * @param dataPoints Number of synthetic data points to generate
     * @param initialCapital Initial capital for the backtest
     * @return Comprehensive backtest results
     */
    public BacktestResult runSyntheticBacktest(String symbol, String interval, int dataPoints, BigDecimal initialCapital) {
        log.info("Starting synthetic backtest for {} {} with {} data points", symbol, interval, dataPoints);

        try {
            // Generate synthetic dataset
            BacktestDataset dataset = generateSyntheticDataset(symbol, interval, dataPoints);

            // Run the backtest
            return runBacktest(dataset, initialCapital);

        } catch (Exception e) {
            log.error("Error running synthetic backtest for {} {}", symbol, interval, e);
            return createEmptyResult(symbol, interval, "Error: " + e.getMessage());
        }
    }

    /**
     * Runs real-data backtests across multiple interval/day combinations and aggregates the findings.
     *
     * @param symbol Trading pair symbol
     * @param intervals List of kline intervals to evaluate
     * @param dayRanges Different day ranges to sample for each interval
     * @param initialCapital Initial capital for each scoped backtest
     * @return Aggregated multi-scope report with comparative insights
     */
    public MultiScopeBacktestReport runRealDataBacktestAcrossScopes(
            String symbol,
            List<String> intervals,
            List<Integer> dayRanges,
            BigDecimal initialCapital
    ) {
        if (intervals == null || intervals.isEmpty()) {
            throw new IllegalArgumentException("At least one interval must be provided");
        }
        if (dayRanges == null || dayRanges.isEmpty()) {
            throw new IllegalArgumentException("At least one day range must be provided");
        }

        List<BacktestScopeResult> scopeResults = new ArrayList<>();
        for (String interval : intervals) {
            for (Integer days : dayRanges) {
                if (days == null || days <= 0) {
                    log.warn("Skipping invalid day range {} for interval {}", days, interval);
                    continue;
                }
                BacktestResult result = runRealDataBacktest(symbol, interval, days, initialCapital);
                scopeResults.add(BacktestScopeResult.builder()
                        .interval(interval)
                        .days(days)
                        .result(result)
                        .headline(buildScopeHeadline(interval, days, result))
                        .build());
            }
        }

        if (scopeResults.isEmpty()) {
            return MultiScopeBacktestReport.builder()
                    .symbol(symbol)
                    .initialCapital(initialCapital)
                    .scopeResults(List.of())
                    .overallSummary("No valid scopes provided for analysis")
                    .keyFindings(List.of("Provide at least one valid interval and day range to evaluate."))
                    .riskWarnings(List.of())
                    .nextSteps(List.of("Verify scope configuration and rerun the analysis."))
                    .build();
        }

        String overallSummary = buildOverallSummary(symbol, initialCapital, scopeResults);
        List<String> keyFindings = buildKeyFindings(scopeResults);
        List<String> riskWarnings = buildRiskWarnings(scopeResults);
        List<String> nextSteps = buildNextSteps(scopeResults, keyFindings);

        return MultiScopeBacktestReport.builder()
                .symbol(symbol)
                .initialCapital(initialCapital)
                .scopeResults(scopeResults)
                .overallSummary(overallSummary)
                .keyFindings(keyFindings)
                .riskWarnings(riskWarnings)
                .nextSteps(nextSteps)
                .build();
    }

    /**
     * Core backtesting logic that processes the dataset and generates results.
     */
    private BacktestResult runBacktest(BacktestDataset dataset, BigDecimal initialCapital) {
        log.info("Running backtest for dataset: {} with {} klines", dataset.getName(), dataset.getKlines().size());
        
        // Initialize backtesting components
        BacktestOrderService orderService = new BacktestOrderService();
        BacktestTraderEngine traderEngine = new BacktestTraderEngine(
                macdSignalAnalyzer,
                orderService,
                traderConfig.getTrader()
        );
        
        // Process each kline through the trading engine
        List<KlineEvent> klines = dataset.getKlines();
        for (KlineEvent kline : klines) {
            traderEngine.onNewKline(kline);
        }
        
        // Get completed trades
        List<SimulatedTrade> trades = orderService.getClosedTrades();
        log.info("Backtest completed with {} trades executed", trades.size());
        
        // Calculate comprehensive metrics
        BacktestMetrics metrics = metricsCalculator.calculate(
                dataset.getName(),
                dataset.getSymbol(),
                dataset.getInterval(),
                klines,
                trades,
                initialCapital
        );
        
        // Generate detailed analysis
        BacktestAnalysis analysis = generateAnalysis(trades, klines, initialCapital);
        
        return BacktestResult.builder()
                .dataset(dataset)
                .metrics(metrics)
                .analysis(analysis)
                .trades(trades)
                .success(true)
                .build();
    }

    /**
     * Generates synthetic dataset for testing purposes.
     */
    private BacktestDataset generateSyntheticDataset(String symbol, String interval, int dataPoints) {
        List<KlineEvent> klines = new ArrayList<>();
        long currentTime = System.currentTimeMillis() - (dataPoints * 60 * 60 * 1000L); // Start from dataPoints hours ago
        BigDecimal basePrice = BigDecimal.valueOf(50000); // Starting price
        
        for (int i = 0; i < dataPoints; i++) {
            // Generate sinusoidal price movement with some randomness
            double trend = Math.sin(i / 10.0) * 0.1; // Long-term trend
            double noise = (Math.random() - 0.5) * 0.05; // Random noise
            double priceChange = trend + noise;
            
            BigDecimal price = basePrice.multiply(BigDecimal.ONE.add(BigDecimal.valueOf(priceChange)));
            
            // Ensure price doesn't go negative
            if (price.compareTo(BigDecimal.ZERO) <= 0) {
                price = basePrice;
            }
            
            klines.add(new KlineEvent(
                    "kline",
                    currentTime,
                    symbol,
                    interval,
                    currentTime,
                    currentTime + 3600000, // 1 hour later
                    price,
                    price.multiply(BigDecimal.valueOf(1.01)), // High
                    price.multiply(BigDecimal.valueOf(0.99)), // Low
                    price,
                    BigDecimal.valueOf(1000) // Volume
            ));
            
            currentTime += 3600000; // Move forward 1 hour
            basePrice = price; // Update base price for next iteration
        }
        
        return BacktestDataset.builder()
                .name("Synthetic_" + symbol + "_" + interval)
                .symbol(symbol)
                .interval(interval)
                .collectedAt(java.time.Instant.now())
                .klines(klines)
                .build();
    }

    /**
     * Generates detailed analysis of the backtest results.
     */
    private BacktestAnalysis generateAnalysis(List<SimulatedTrade> trades, List<KlineEvent> klines, BigDecimal initialCapital) {
        if (trades.isEmpty()) {
            return BacktestAnalysis.builder()
                    .summary("No trades executed during backtest period")
                    .recommendations(List.of("Consider adjusting strategy parameters", "Check market conditions"))
                    .riskAssessment("Low risk - no trades executed")
                    .build();
        }
        
        // Calculate basic statistics
        long totalTrades = trades.size();
        long winningTrades = trades.stream().filter(t -> t.getProfit().compareTo(BigDecimal.ZERO) > 0).count();
        long losingTrades = trades.stream().filter(t -> t.getProfit().compareTo(BigDecimal.ZERO) < 0).count();
        
        BigDecimal totalProfit = trades.stream()
                .map(SimulatedTrade::getProfit)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        BigDecimal winRate = BigDecimal.valueOf(winningTrades)
                .divide(BigDecimal.valueOf(totalTrades), 4, java.math.RoundingMode.HALF_UP);
        
        // Generate summary
        String summary = String.format(
                "Backtest completed with %d trades. Win rate: %.2f%%. Total profit: %s. " +
                "Winning trades: %d, Losing trades: %d",
                totalTrades, winRate.multiply(BigDecimal.valueOf(100)), totalProfit, winningTrades, losingTrades
        );
        
        // Generate recommendations
        List<String> recommendations = new ArrayList<>();
        if (winRate.compareTo(BigDecimal.valueOf(0.5)) < 0) {
            recommendations.add("Consider improving entry/exit criteria - win rate is below 50%");
        }
        if (totalProfit.compareTo(BigDecimal.ZERO) < 0) {
            recommendations.add("Strategy is currently unprofitable - review parameters");
        }
        if (trades.size() < 10) {
            recommendations.add("Limited sample size - consider longer backtest period");
        }
        if (recommendations.isEmpty()) {
            recommendations.add("Strategy shows promising results - consider live testing with small position sizes");
        }
        
        // Risk assessment
        String riskAssessment;
        if (totalProfit.compareTo(BigDecimal.ZERO) > 0 && winRate.compareTo(BigDecimal.valueOf(0.6)) > 0) {
            riskAssessment = "Low to Medium risk - profitable strategy with good win rate";
        } else if (totalProfit.compareTo(BigDecimal.ZERO) > 0) {
            riskAssessment = "Medium risk - profitable but inconsistent performance";
        } else {
            riskAssessment = "High risk - unprofitable strategy, needs optimization";
        }
        
        return BacktestAnalysis.builder()
                .summary(summary)
                .recommendations(recommendations)
                .riskAssessment(riskAssessment)
                .build();
    }

    /**
     * Creates an empty result for error cases.
     */
    private BacktestResult createEmptyResult(String symbol, String interval, String errorMessage) {
        return BacktestResult.builder()
                .dataset(BacktestDataset.builder()
                        .name("Empty")
                        .symbol(symbol)
                        .interval(interval)
                        .klines(List.of())
                        .build())
                .metrics(BacktestMetrics.builder()
                        .datasetName("Empty")
                        .symbol(symbol)
                        .interval(interval)
                        .build())
                .analysis(BacktestAnalysis.builder()
                        .summary(errorMessage)
                        .recommendations(List.of("Check data availability", "Verify parameters"))
                        .riskAssessment("Unable to assess - no data")
                        .build())
                .trades(List.of())
                .success(false)
                .build();
    }

    private String buildScopeHeadline(String interval, int days, BacktestResult result) {
        if (result == null) {
            return String.format("%s/%dd - No result returned", interval, days);
        }

        if (!result.isSuccess()) {
            String reason = Optional.ofNullable(result.getAnalysis())
                    .map(BacktestAnalysis::getSummary)
                    .orElse("Backtest unsuccessful");
            return String.format("%s/%dd - %s", interval, days, reason);
        }

        BacktestMetrics metrics = result.getMetrics();
        String profit = formatCurrency(extractNetProfit(result));
        String winRate = formatPercentage(metrics != null ? metrics.getWinRate() : null);
        int trades = metrics != null ? metrics.getTotalTrades() :
                (result.getTrades() != null ? result.getTrades().size() : 0);
        return String.format("%s/%dd - Net profit %s, win rate %s across %d trades",
                interval, days, profit, winRate, trades);
    }

    private String buildOverallSummary(String symbol, BigDecimal initialCapital, List<BacktestScopeResult> scopeResults) {
        long successful = scopeResults.stream().filter(this::isSuccessful).count();
        long failures = scopeResults.size() - successful;
        BigDecimal averageNetProfit = calculateAverageNetProfit(scopeResults);

        return String.format(
                "Evaluated %d backtest scope(s) for %s with initial capital %s. %d succeeded, %d reported data issues. Average net profit: %s.",
                scopeResults.size(),
                symbol,
                formatCurrency(initialCapital),
                successful,
                failures,
                formatCurrency(averageNetProfit)
        );
    }

    private List<String> buildKeyFindings(List<BacktestScopeResult> scopeResults) {
        List<String> findings = new ArrayList<>();

        Optional<BacktestScopeResult> bestProfit = scopeResults.stream()
                .filter(this::hasMetrics)
                .filter(scope -> extractNetProfit(scope.getResult()) != null)
                .max(Comparator.comparing(scope -> extractNetProfit(scope.getResult())));

        bestProfit.ifPresent(scope -> {
            BigDecimal netProfit = extractNetProfit(scope.getResult());
            BigDecimal winRate = extractWinRate(scope.getResult());
            findings.add(String.format(
                    "%s/%dd delivered the highest net profit of %s with a win rate of %s.",
                    scope.getInterval(),
                    scope.getDays(),
                    formatCurrency(netProfit),
                    formatPercentage(winRate)
            ));
        });

        Optional<BacktestScopeResult> bestWinRate = scopeResults.stream()
                .filter(this::hasMetrics)
                .filter(scope -> extractWinRate(scope.getResult()) != null)
                .max(Comparator.comparing(scope -> extractWinRate(scope.getResult())));

        if (bestProfit.isPresent() && bestWinRate.isPresent() && bestProfit.get().equals(bestWinRate.get())) {
            // Avoid duplicating the same message when both metrics point to the same scope
            bestWinRate = Optional.empty();
        }

        bestWinRate.ifPresent(scope -> findings.add(String.format(
                "%s/%dd achieved the strongest win rate at %s across %d trades.",
                scope.getInterval(),
                scope.getDays(),
                formatPercentage(extractWinRate(scope.getResult())),
                extractTotalTrades(scope.getResult())
        )));

        Optional<BacktestScopeResult> lowestDrawdown = scopeResults.stream()
                .filter(this::hasMetrics)
                .filter(scope -> extractMaxDrawdownPercent(scope.getResult()) != null)
                .min(Comparator.comparing(scope -> extractMaxDrawdownPercent(scope.getResult())));

        lowestDrawdown.ifPresent(scope -> findings.add(String.format(
                "%s/%dd maintained the lowest drawdown at %s, indicating smoother equity swings.",
                scope.getInterval(),
                scope.getDays(),
                formatPercentage(extractMaxDrawdownPercent(scope.getResult()))
        )));

        if (findings.isEmpty()) {
            findings.add("No successful backtests were produced; review strategy parameters or data availability.");
        }

        return findings;
    }

    private List<String> buildRiskWarnings(List<BacktestScopeResult> scopeResults) {
        List<String> warnings = new ArrayList<>();

        scopeResults.stream()
                .filter(scope -> !isSuccessful(scope))
                .forEach(scope -> warnings.add(String.format(
                        "%s/%dd backtest did not complete successfully: %s",
                        scope.getInterval(),
                        scope.getDays(),
                        Optional.ofNullable(scope.getResult())
                                .map(BacktestResult::getAnalysis)
                                .map(BacktestAnalysis::getSummary)
                                .orElse("Unknown issue")
                )));

        scopeResults.stream()
                .filter(this::hasMetrics)
                .forEach(scope -> {
                    BacktestResult result = scope.getResult();
                    BacktestMetrics metrics = result.getMetrics();

                    BigDecimal drawdownPercent = metrics.getMaxDrawdownPercent();
                    if (drawdownPercent != null && drawdownPercent.compareTo(BigDecimal.valueOf(0.2)) > 0) {
                        warnings.add(String.format(
                                "%s/%dd experienced elevated drawdown of %s.",
                                scope.getInterval(),
                                scope.getDays(),
                                formatPercentage(drawdownPercent)
                        ));
                    }

                    if (metrics.getTotalTrades() < 5) {
                        warnings.add(String.format(
                                "%s/%dd produced fewer than five trades; statistical significance is limited.",
                                scope.getInterval(),
                                scope.getDays()
                        ));
                    }

                    BigDecimal winRate = metrics.getWinRate();
                    if (winRate != null && winRate.compareTo(BigDecimal.valueOf(0.45)) < 0) {
                        warnings.add(String.format(
                                "%s/%dd shows a sub-45%% win rate (%s), suggesting parameter tuning is needed.",
                                scope.getInterval(),
                                scope.getDays(),
                                formatPercentage(winRate)
                        ));
                    }
                });

        if (warnings.isEmpty()) {
            warnings.add("No immediate risks detected across evaluated scopes.");
        }

        return warnings;
    }

    private List<String> buildNextSteps(List<BacktestScopeResult> scopeResults, List<String> keyFindings) {
        List<String> actions = new ArrayList<>();

        Optional<BacktestScopeResult> topProfitScope = scopeResults.stream()
                .filter(this::hasMetrics)
                .filter(scope -> extractNetProfit(scope.getResult()) != null)
                .max(Comparator.comparing(scope -> extractNetProfit(scope.getResult())));

        topProfitScope.ifPresent(scope -> actions.add(String.format(
                "Prioritize deeper parameter optimization for the %s/%dd configuration after observing %s net profit.",
                scope.getInterval(),
                scope.getDays(),
                formatCurrency(extractNetProfit(scope.getResult()))
        )));

        boolean hasFailures = scopeResults.stream().anyMatch(scope -> !isSuccessful(scope));
        if (hasFailures) {
            actions.add("Investigate scopes with data issues to ensure historical coverage and configuration correctness.");
        }

        if (keyFindings.stream().noneMatch(finding -> finding.contains("highest net profit"))) {
            actions.add("Experiment with additional intervals or longer ranges to uncover more profitable configurations.");
        }

        actions.add("Re-run the multi-scope backtest after adjusting strategy parameters to confirm robustness.");

        return actions.stream().distinct().collect(Collectors.toList());
    }

    private boolean hasMetrics(BacktestScopeResult scope) {
        return scope.getResult() != null && scope.getResult().getMetrics() != null;
    }

    private boolean isSuccessful(BacktestScopeResult scope) {
        return scope.getResult() != null && scope.getResult().isSuccess();
    }

    private BigDecimal calculateAverageNetProfit(List<BacktestScopeResult> scopeResults) {
        List<BigDecimal> profits = scopeResults.stream()
                .map(BacktestScopeResult::getResult)
                .filter(Objects::nonNull)
                .map(this::extractNetProfit)
                .filter(Objects::nonNull)
                .collect(Collectors.toList());

        if (profits.isEmpty()) {
            return null;
        }

        BigDecimal total = profits.stream().reduce(BigDecimal.ZERO, BigDecimal::add);
        return total.divide(BigDecimal.valueOf(profits.size()), 2, RoundingMode.HALF_UP);
    }

    private BigDecimal extractNetProfit(BacktestResult result) {
        if (result == null || result.getMetrics() == null) {
            return null;
        }
        return result.getMetrics().getNetProfit();
    }

    private BigDecimal extractWinRate(BacktestResult result) {
        if (result == null || result.getMetrics() == null) {
            return null;
        }
        return result.getMetrics().getWinRate();
    }

    private int extractTotalTrades(BacktestResult result) {
        if (result == null || result.getMetrics() == null) {
            return 0;
        }
        return result.getMetrics().getTotalTrades();
    }

    private BigDecimal extractMaxDrawdownPercent(BacktestResult result) {
        if (result == null || result.getMetrics() == null) {
            return null;
        }
        return result.getMetrics().getMaxDrawdownPercent();
    }

    private String formatCurrency(BigDecimal value) {
        if (value == null) {
            return "n/a";
        }
        return value.setScale(2, RoundingMode.HALF_UP).toPlainString();
    }

    private String formatPercentage(BigDecimal value) {
        if (value == null) {
            return "n/a";
        }
        BigDecimal percent = value.multiply(BigDecimal.valueOf(100));
        return percent.setScale(2, RoundingMode.HALF_UP).toPlainString() + "%";
    }
}
