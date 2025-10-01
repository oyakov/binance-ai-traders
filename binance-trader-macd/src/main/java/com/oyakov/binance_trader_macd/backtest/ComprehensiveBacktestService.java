package com.oyakov.binance_trader_macd.backtest;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_shared_model.backtest.BacktestDataset;
import com.oyakov.binance_trader_macd.config.MACDTraderConfig;
import com.oyakov.binance_trader_macd.domain.signal.MACDSignalAnalyzer;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;

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
}
