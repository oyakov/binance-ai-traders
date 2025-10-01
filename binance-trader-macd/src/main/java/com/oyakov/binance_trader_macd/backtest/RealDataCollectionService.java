package com.oyakov.binance_trader_macd.backtest;

import com.oyakov.binance_trader_macd.backtest.CustomMACDAnalyzer;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_trader_macd.backtest.MACDParameters;
import com.oyakov.binance_trader_macd.config.MACDTraderConfig;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * Service for collecting real Binance data and running comparative analysis
 */
@Service
public class RealDataCollectionService {
    
    private final RestTemplate restTemplate;
    private final ExecutorService executorService;
    private final Map<String, List<KlineEvent>> dataCache;
    
    public RealDataCollectionService() {
        this.restTemplate = new RestTemplate();
        this.executorService = Executors.newFixedThreadPool(4);
        this.dataCache = new HashMap<>();
    }
    
    /**
     * Collect real data from Binance API for a specific symbol and interval
     */
    public CompletableFuture<List<KlineEvent>> collectRealData(String symbol, String interval, int days) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                String cacheKey = symbol + "_" + interval + "_" + days;
                
                // Check cache first
                if (dataCache.containsKey(cacheKey)) {
                    System.out.println("Using cached data for " + cacheKey);
                    return dataCache.get(cacheKey);
                }
                
                System.out.println("Collecting real data for " + symbol + " " + interval + " (" + days + " days)");
                
                // Calculate time range
                long endTime = System.currentTimeMillis();
                long startTime = endTime - (days * 24 * 60 * 60 * 1000L);
                
                // Fetch data from Binance API
                String url = String.format(
                    "https://api.binance.com/api/v3/klines?symbol=%s&interval=%s&startTime=%d&endTime=%d&limit=1000",
                    symbol, interval, startTime, endTime
                );
                
                List<List<Object>> response = restTemplate.getForObject(url, List.class);
                
                if (response == null || response.isEmpty()) {
                    System.out.println("No data received from Binance API");
                    return new ArrayList<>();
                }
                
                List<KlineEvent> klines = new ArrayList<>();
                for (List<Object> kline : response) {
                    try {
                        KlineEvent event = new KlineEvent(
                            "kline",
                            System.currentTimeMillis(),
                            symbol,
                            interval,
                            Long.parseLong(kline.get(0).toString()),
                            Long.parseLong(kline.get(6).toString()),
                            new BigDecimal(kline.get(1).toString()),
                            new BigDecimal(kline.get(2).toString()),
                            new BigDecimal(kline.get(3).toString()),
                            new BigDecimal(kline.get(4).toString()),
                            new BigDecimal(kline.get(5).toString())
                        );
                        klines.add(event);
                    } catch (Exception e) {
                        System.err.println("Error parsing kline data: " + e.getMessage());
                    }
                }
                
                // Cache the data
                dataCache.put(cacheKey, klines);
                
                System.out.println("Collected " + klines.size() + " klines for " + symbol + " " + interval);
                return klines;
                
            } catch (Exception e) {
                System.err.println("Error collecting real data: " + e.getMessage());
                return new ArrayList<>();
            }
        }, executorService);
    }
    
    /**
     * Run backtest on real data with different MACD parameters
     */
    public CompletableFuture<SimpleBacktestResult> runBacktestOnRealData(
            String symbol, String interval, int days, MACDParameters params) {
        
        return collectRealData(symbol, interval, days)
            .thenApply(klines -> {
                if (klines.isEmpty()) {
                    return new SimpleBacktestResult(
                        symbol, interval, days, params,
                        new SimpleBacktestMetrics(BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, 0), 
                        "No data available"
                    );
                }
                
                try {
                    // Run MACD analysis
                    CustomMACDAnalyzer analyzer = new CustomMACDAnalyzer();
                    List<CustomMACDAnalyzer.MACDSignal> signals = analyzer.analyzeSignals(klines, params);
                    
                    // Simulate trades
                    List<SimulatedTrade> trades = simulateTrades(klines, signals);
                    
                    // Calculate simple metrics
                    SimpleBacktestMetrics metrics = calculateSimpleMetrics(trades);
                    
                    return new SimpleBacktestResult(
                        symbol, interval, days, params,
                        metrics, "Success"
                    );
                    
                } catch (Exception e) {
                    System.err.println("Error running backtest: " + e.getMessage());
                    return new SimpleBacktestResult(
                        symbol, interval, days, params,
                        new SimpleBacktestMetrics(BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, 0), 
                        "Error: " + e.getMessage()
                    );
                }
            });
    }
    
    /**
     * Simulate trades based on MACD signals
     */
    private List<SimulatedTrade> simulateTrades(List<KlineEvent> klines, List<CustomMACDAnalyzer.MACDSignal> signals) {
        List<SimulatedTrade> trades = new ArrayList<>();
        boolean inPosition = false;
        BigDecimal entryPrice = BigDecimal.ZERO;
        long entryTime = 0;
        
        for (CustomMACDAnalyzer.MACDSignal signal : signals) {
            if (signal.getSignal() == CustomMACDAnalyzer.SignalType.BUY && !inPosition) {
                // Enter long position
                inPosition = true;
                entryPrice = signal.getPrice();
                entryTime = signal.getTimestamp();
                
            } else if (signal.getSignal() == CustomMACDAnalyzer.SignalType.SELL && inPosition) {
                // Exit long position
                inPosition = false;
                BigDecimal exitPrice = signal.getPrice();
                long exitTime = signal.getTimestamp();
                
                // Calculate trade result
                BigDecimal pnl = exitPrice.subtract(entryPrice);
                BigDecimal pnlPercent = pnl.divide(entryPrice, 4, BigDecimal.ROUND_HALF_UP)
                    .multiply(BigDecimal.valueOf(100));
                
                trades.add(new SimulatedTrade(
                    entryTime, exitTime, entryPrice, exitPrice,
                    pnl, pnlPercent, pnl.compareTo(BigDecimal.ZERO) > 0
                ));
            }
        }
        
        return trades;
    }
    
    /**
     * Calculate simple metrics from trades
     */
    private SimpleBacktestMetrics calculateSimpleMetrics(List<SimulatedTrade> trades) {
        if (trades.isEmpty()) {
            return new SimpleBacktestMetrics(BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, 0);
        }
        
        // Calculate basic metrics
        BigDecimal totalPnl = trades.stream()
            .map(SimulatedTrade::getPnlPercent)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        long winCount = trades.stream()
            .mapToLong(trade -> trade.isWin() ? 1 : 0)
            .sum();
        
        BigDecimal winRate = BigDecimal.valueOf(winCount)
            .divide(BigDecimal.valueOf(trades.size()), 4, BigDecimal.ROUND_HALF_UP)
            .multiply(BigDecimal.valueOf(100));
        
        // Calculate max drawdown (simplified)
        BigDecimal maxDrawdown = BigDecimal.ZERO;
        BigDecimal runningPnl = BigDecimal.ZERO;
        BigDecimal peak = BigDecimal.ZERO;
        
        for (SimulatedTrade trade : trades) {
            runningPnl = runningPnl.add(trade.getPnlPercent());
            if (runningPnl.compareTo(peak) > 0) {
                peak = runningPnl;
            }
            BigDecimal drawdown = peak.subtract(runningPnl);
            if (drawdown.compareTo(maxDrawdown) > 0) {
                maxDrawdown = drawdown;
            }
        }
        
        // Calculate Sharpe ratio (simplified)
        BigDecimal avgReturn = totalPnl.divide(BigDecimal.valueOf(trades.size()), 4, BigDecimal.ROUND_HALF_UP);
        BigDecimal variance = trades.stream()
            .map(trade -> trade.getPnlPercent().subtract(avgReturn).pow(2))
            .reduce(BigDecimal.ZERO, BigDecimal::add)
            .divide(BigDecimal.valueOf(trades.size()), 4, BigDecimal.ROUND_HALF_UP);
        
        BigDecimal stdDev = BigDecimal.valueOf(Math.sqrt(variance.doubleValue()));
        BigDecimal sharpeRatio = stdDev.compareTo(BigDecimal.ZERO) > 0 ? 
            avgReturn.divide(stdDev, 4, BigDecimal.ROUND_HALF_UP) : BigDecimal.ZERO;
        
        return new SimpleBacktestMetrics(totalPnl, sharpeRatio, winRate, maxDrawdown, trades.size());
    }
    
    /**
     * Run comprehensive analysis across multiple symbols, intervals, and time periods
     */
    public CompletableFuture<AnalysisResult> runComprehensiveAnalysis() {
        return CompletableFuture.supplyAsync(() -> {
            System.out.println("Starting comprehensive real data analysis...");
            
            // Define analysis parameters
            String[] symbols = {"BTCUSDT", "ETHUSDT", "ADAUSDT"};
            String[] intervals = {"1h", "4h", "1d"};
            int[] days = {7, 30, 90};
            
            // Define MACD parameter sets to test
            MACDParameters[] paramSets = {
                new MACDParameters(12, 26, 9),  // Standard
                new MACDParameters(8, 21, 5),   // Fast
                new MACDParameters(19, 39, 9),  // Slow
                new MACDParameters(5, 35, 5),   // Custom 1
                new MACDParameters(15, 30, 10)  // Custom 2
            };
            
            List<SimpleBacktestResult> allResults = new ArrayList<>();
            
            // Run backtests for all combinations
            for (String symbol : symbols) {
                for (String interval : intervals) {
                    for (int day : days) {
                        for (MACDParameters params : paramSets) {
                            try {
                                SimpleBacktestResult result = runBacktestOnRealData(symbol, interval, day, params).get();
                                allResults.add(result);
                                
                                // Print progress
                                System.out.printf("Completed: %s %s %dd %s - Net Profit: %.2f%%%n",
                                    symbol, interval, day, params.toString(),
                                    result.getMetrics().getNetProfitPercent().doubleValue());
                                
                            } catch (Exception e) {
                                System.err.println("Error in analysis: " + e.getMessage());
                            }
                        }
                    }
                }
            }
            
            // Analyze results
            return analyzeResults(allResults);
            
        }, executorService);
    }
    
    /**
     * Analyze and compare backtest results
     */
    private AnalysisResult analyzeResults(List<SimpleBacktestResult> results) {
        System.out.println("\n=== COMPREHENSIVE ANALYSIS RESULTS ===");
        
        // Filter successful results
        List<SimpleBacktestResult> successfulResults = results.stream()
            .filter(r -> "Success".equals(r.getStatus()))
            .toList();
        
        System.out.println("Total backtests: " + results.size());
        System.out.println("Successful backtests: " + successfulResults.size());
        
        if (successfulResults.isEmpty()) {
            return new AnalysisResult("No successful backtests to analyze");
        }
        
        // Calculate summary statistics
        double avgNetProfit = successfulResults.stream()
            .mapToDouble(r -> r.getMetrics().getNetProfitPercent().doubleValue())
            .average().orElse(0.0);
        
        double avgSharpeRatio = successfulResults.stream()
            .mapToDouble(r -> r.getMetrics().getSharpeRatio().doubleValue())
            .average().orElse(0.0);
        
        double avgWinRate = successfulResults.stream()
            .mapToDouble(r -> r.getMetrics().getWinRate().doubleValue())
            .average().orElse(0.0);
        
        // Find best and worst performers
        SimpleBacktestResult bestResult = successfulResults.stream()
            .max(Comparator.comparing(r -> r.getMetrics().getNetProfitPercent()))
            .orElse(null);
        
        SimpleBacktestResult worstResult = successfulResults.stream()
            .min(Comparator.comparing(r -> r.getMetrics().getNetProfitPercent()))
            .orElse(null);
        
        // Print summary
        System.out.printf("Average Net Profit: %.2f%%%n", avgNetProfit);
        System.out.printf("Average Sharpe Ratio: %.2f%n", avgSharpeRatio);
        System.out.printf("Average Win Rate: %.2f%%%n", avgWinRate);
        
        if (bestResult != null) {
            System.out.printf("Best Performer: %s %s %dd %s - Net Profit: %.2f%%%n",
                bestResult.getSymbol(), bestResult.getInterval(), bestResult.getDays(),
                bestResult.getParameters().toString(),
                bestResult.getMetrics().getNetProfitPercent().doubleValue());
        }
        
        if (worstResult != null) {
            System.out.printf("Worst Performer: %s %s %dd %s - Net Profit: %.2f%%%n",
                worstResult.getSymbol(), worstResult.getInterval(), worstResult.getDays(),
                worstResult.getParameters().toString(),
                worstResult.getMetrics().getNetProfitPercent().doubleValue());
        }
        
        // Analyze by symbol
        System.out.println("\n=== PERFORMANCE BY SYMBOL ===");
        for (String symbol : new String[]{"BTCUSDT", "ETHUSDT", "ADAUSDT"}) {
            double symbolAvgProfit = successfulResults.stream()
                .filter(r -> symbol.equals(r.getSymbol()))
                .mapToDouble(r -> r.getMetrics().getNetProfitPercent().doubleValue())
                .average().orElse(0.0);
            System.out.printf("%s: %.2f%%%n", symbol, symbolAvgProfit);
        }
        
        // Analyze by interval
        System.out.println("\n=== PERFORMANCE BY INTERVAL ===");
        for (String interval : new String[]{"1h", "4h", "1d"}) {
            double intervalAvgProfit = successfulResults.stream()
                .filter(r -> interval.equals(r.getInterval()))
                .mapToDouble(r -> r.getMetrics().getNetProfitPercent().doubleValue())
                .average().orElse(0.0);
            System.out.printf("%s: %.2f%%%n", interval, intervalAvgProfit);
        }
        
        // Analyze by time period
        System.out.println("\n=== PERFORMANCE BY TIME PERIOD ===");
        for (int days : new int[]{7, 30, 90}) {
            double periodAvgProfit = successfulResults.stream()
                .filter(r -> days == r.getDays())
                .mapToDouble(r -> r.getMetrics().getNetProfitPercent().doubleValue())
                .average().orElse(0.0);
            System.out.printf("%d days: %.2f%%%n", days, periodAvgProfit);
        }
        
        // Analyze by MACD parameters
        System.out.println("\n=== PERFORMANCE BY MACD PARAMETERS ===");
        for (MACDParameters params : new MACDParameters[]{
            new MACDParameters(12, 26, 9),
            new MACDParameters(8, 21, 5),
            new MACDParameters(19, 39, 9),
            new MACDParameters(5, 35, 5),
            new MACDParameters(15, 30, 10)
        }) {
            double paramAvgProfit = successfulResults.stream()
                .filter(r -> params.equals(r.getParameters()))
                .mapToDouble(r -> r.getMetrics().getNetProfitPercent().doubleValue())
                .average().orElse(0.0);
            System.out.printf("%s: %.2f%%%n", params.toString(), paramAvgProfit);
        }
        
        return new AnalysisResult("Analysis completed successfully");
    }
    
    /**
     * Simple data class for simulated trades
     */
    public static class SimulatedTrade {
        private final long entryTime;
        private final long exitTime;
        private final BigDecimal entryPrice;
        private final BigDecimal exitPrice;
        private final BigDecimal pnl;
        private final BigDecimal pnlPercent;
        private final boolean isWin;
        
        public SimulatedTrade(long entryTime, long exitTime, BigDecimal entryPrice, BigDecimal exitPrice,
                            BigDecimal pnl, BigDecimal pnlPercent, boolean isWin) {
            this.entryTime = entryTime;
            this.exitTime = exitTime;
            this.entryPrice = entryPrice;
            this.exitPrice = exitPrice;
            this.pnl = pnl;
            this.pnlPercent = pnlPercent;
            this.isWin = isWin;
        }
        
        // Getters
        public long getEntryTime() { return entryTime; }
        public long getExitTime() { return exitTime; }
        public BigDecimal getEntryPrice() { return entryPrice; }
        public BigDecimal getExitPrice() { return exitPrice; }
        public BigDecimal getPnl() { return pnl; }
        public BigDecimal getPnlPercent() { return pnlPercent; }
        public boolean isWin() { return isWin; }
    }
    
    /**
     * Simple data class for analysis results
     */
    public static class AnalysisResult {
        private final String summary;
        
        public AnalysisResult(String summary) {
            this.summary = summary;
        }
        
        public String getSummary() { return summary; }
    }
}
