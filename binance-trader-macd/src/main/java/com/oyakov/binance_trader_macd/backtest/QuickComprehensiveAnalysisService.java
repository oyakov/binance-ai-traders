package com.oyakov.binance_trader_macd.backtest;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.stream.Collectors;

/**
 * Quick comprehensive analysis service for faster testing
 */
public class QuickComprehensiveAnalysisService {
    
    private final RestTemplate restTemplate;
    private final ExecutorService executorService;
    private final Map<String, List<KlineEvent>> dataCache;
    
    public QuickComprehensiveAnalysisService() {
        this.restTemplate = new RestTemplate();
        this.executorService = Executors.newFixedThreadPool(4);
        this.dataCache = new HashMap<>();
    }
    
    /**
     * Run quick comprehensive analysis
     */
    public CompletableFuture<QuickAnalysisResult> runQuickAnalysis() {
        return CompletableFuture.supplyAsync(() -> {
            System.out.println("=== QUICK COMPREHENSIVE ANALYSIS ===");
            
            // Define focused analysis dimensions
            String[] symbols = {"BTCUSDT", "ETHUSDT", "ADAUSDT"};
            String[] intervals = {"1d", "4h"};
            int[] timePeriods = {90, 180};
            
            // Define key MACD parameter sets
            List<MACDParameters> parameterSets = Arrays.asList(
                new MACDParameters(12, 26, 9),   // Classic
                new MACDParameters(8, 21, 5),    // Fast
                new MACDParameters(19, 39, 9),   // Slow
                new MACDParameters(5, 35, 5),    // Very fast/slow
                new MACDParameters(15, 30, 10),  // Custom 1
                new MACDParameters(6, 19, 6),    // Fast variant
                new MACDParameters(20, 40, 10),  // Slow variant
                new MACDParameters(10, 20, 10),  // Balanced
                new MACDParameters(7, 14, 7),    // Balanced 2
                new MACDParameters(14, 28, 14)   // Balanced 3
            );
            
            System.out.println("Configuration:");
            System.out.println("- Symbols: " + Arrays.toString(symbols));
            System.out.println("- Intervals: " + Arrays.toString(intervals));
            System.out.println("- Time Periods: " + Arrays.toString(timePeriods));
            System.out.println("- Parameter Sets: " + parameterSets.size());
            System.out.println("- Total Tests: " + (symbols.length * intervals.length * timePeriods.length * parameterSets.size()));
            System.out.println();
            
            List<AnalysisResult> allResults = new ArrayList<>();
            int totalTests = symbols.length * intervals.length * timePeriods.length * parameterSets.size();
            int completedTests = 0;
            
            // Run analysis for all combinations
            for (String symbol : symbols) {
                for (String interval : intervals) {
                    for (int timePeriod : timePeriods) {
                        for (MACDParameters params : parameterSets) {
                            try {
                                AnalysisResult result = runSingleAnalysis(symbol, interval, timePeriod, params).get();
                                allResults.add(result);
                                completedTests++;
                                
                                // Progress reporting
                                if (completedTests % 20 == 0 || completedTests == totalTests) {
                                    System.out.printf("Progress: %d/%d tests completed (%.1f%%)\n", 
                                        completedTests, totalTests, (completedTests * 100.0 / totalTests));
                                }
                                
                            } catch (Exception e) {
                                System.err.println("Error in analysis: " + e.getMessage());
                                completedTests++;
                            }
                        }
                    }
                }
            }
            
            System.out.println("\nGenerating insights...");
            
            // Generate quick insights
            return generateQuickInsights(allResults);
            
        }, executorService);
    }
    
    /**
     * Run single analysis for specific parameters
     */
    private CompletableFuture<AnalysisResult> runSingleAnalysis(String symbol, String interval, 
                                                               int timePeriod, MACDParameters params) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                // Collect data
                List<KlineEvent> klines = collectData(symbol, interval, timePeriod);
                
                if (klines.isEmpty()) {
                    return new AnalysisResult(symbol, interval, timePeriod, params, 
                        new SimpleBacktestMetrics(BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, 0), 
                        "No data", 0);
                }
                
                // Run MACD analysis
                CustomMACDAnalyzer analyzer = new CustomMACDAnalyzer();
                List<CustomMACDAnalyzer.MACDSignal> signals = analyzer.analyzeSignals(klines, params);
                
                // Simulate trades
                List<SimulatedTrade> trades = simulateTrades(klines, signals);
                
                // Calculate metrics
                SimpleBacktestMetrics metrics = calculateMetrics(trades);
                
                return new AnalysisResult(symbol, interval, timePeriod, params, 
                    metrics, "Success", signals.size());
                
            } catch (Exception e) {
                return new AnalysisResult(symbol, interval, timePeriod, params, 
                    new SimpleBacktestMetrics(BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, 0), 
                    "Error: " + e.getMessage(), 0);
            }
        }, executorService);
    }
    
    /**
     * Collect data with caching
     */
    private List<KlineEvent> collectData(String symbol, String interval, int timePeriod) {
        String cacheKey = symbol + "_" + interval + "_" + timePeriod;
        
        if (dataCache.containsKey(cacheKey)) {
            return dataCache.get(cacheKey);
        }
        
        try {
            long endTime = System.currentTimeMillis();
            long startTime = endTime - (timePeriod * 24 * 60 * 60 * 1000L);
            
            String url = String.format(
                "https://api.binance.com/api/v3/klines?symbol=%s&interval=%s&startTime=%d&endTime=%d&limit=1000",
                symbol, interval, startTime, endTime
            );
            
            List<List<Object>> response = restTemplate.getForObject(url, List.class);
            
            if (response == null || response.isEmpty()) {
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
                    // Skip invalid klines
                }
            }
            
            // Cache the data
            dataCache.put(cacheKey, klines);
            return klines;
            
        } catch (Exception e) {
            return new ArrayList<>();
        }
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
                inPosition = true;
                entryPrice = signal.getPrice();
                entryTime = signal.getTimestamp();
                
            } else if (signal.getSignal() == CustomMACDAnalyzer.SignalType.SELL && inPosition) {
                inPosition = false;
                BigDecimal exitPrice = signal.getPrice();
                long exitTime = signal.getTimestamp();
                
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
     * Calculate comprehensive metrics
     */
    private SimpleBacktestMetrics calculateMetrics(List<SimulatedTrade> trades) {
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
        
        // Calculate max drawdown
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
        
        // Calculate Sharpe ratio
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
     * Generate quick insights from all results
     */
    private QuickAnalysisResult generateQuickInsights(List<AnalysisResult> results) {
        // Filter successful results
        List<AnalysisResult> successfulResults = results.stream()
            .filter(r -> "Success".equals(r.getStatus()))
            .collect(Collectors.toList());
        
        QuickAnalysisResult analysisResult = new QuickAnalysisResult();
        
        // Overall statistics
        analysisResult.setTotalTests(results.size());
        analysisResult.setSuccessfulTests(successfulResults.size());
        analysisResult.setSuccessRate(successfulResults.size() * 100.0 / results.size());
        
        if (successfulResults.isEmpty()) {
            return analysisResult;
        }
        
        // Performance analysis
        double avgProfit = successfulResults.stream()
            .mapToDouble(r -> r.getMetrics().getNetProfitPercent().doubleValue())
            .average().orElse(0.0);
        
        double avgSharpe = successfulResults.stream()
            .mapToDouble(r -> r.getMetrics().getSharpeRatio().doubleValue())
            .average().orElse(0.0);
        
        double avgWinRate = successfulResults.stream()
            .mapToDouble(r -> r.getMetrics().getWinRate().doubleValue())
            .average().orElse(0.0);
        
        analysisResult.setAverageProfit(avgProfit);
        analysisResult.setAverageSharpeRatio(avgSharpe);
        analysisResult.setAverageWinRate(avgWinRate);
        
        // Best performers
        List<AnalysisResult> bestResults = successfulResults.stream()
            .sorted(Comparator.comparing((AnalysisResult r) -> r.getMetrics().getNetProfitPercent().doubleValue()).reversed())
            .collect(Collectors.toList());
        
        analysisResult.setBestResults(bestResults);
        
        // Parameter performance
        Map<String, Double> paramPerformance = successfulResults.stream()
            .collect(Collectors.groupingBy(
                r -> r.getParameters().toString(),
                Collectors.averagingDouble(r -> r.getMetrics().getNetProfitPercent().doubleValue())
            ));
        
        analysisResult.setParameterPerformance(paramPerformance);
        
        // Symbol performance
        Map<String, Double> symbolPerformance = successfulResults.stream()
            .collect(Collectors.groupingBy(
                AnalysisResult::getSymbol,
                Collectors.averagingDouble(r -> r.getMetrics().getNetProfitPercent().doubleValue())
            ));
        
        analysisResult.setSymbolPerformance(symbolPerformance);
        
        // Timeframe performance
        Map<String, Double> timeframePerformance = successfulResults.stream()
            .collect(Collectors.groupingBy(
                AnalysisResult::getInterval,
                Collectors.averagingDouble(r -> r.getMetrics().getNetProfitPercent().doubleValue())
            ));
        
        analysisResult.setTimeframePerformance(timeframePerformance);
        
        return analysisResult;
    }
    
    // Data classes
    public static class AnalysisResult {
        private final String symbol;
        private final String interval;
        private final int timePeriod;
        private final MACDParameters parameters;
        private final SimpleBacktestMetrics metrics;
        private final String status;
        private final int signalCount;
        
        public AnalysisResult(String symbol, String interval, int timePeriod, MACDParameters parameters,
                            SimpleBacktestMetrics metrics, String status, int signalCount) {
            this.symbol = symbol;
            this.interval = interval;
            this.timePeriod = timePeriod;
            this.parameters = parameters;
            this.metrics = metrics;
            this.status = status;
            this.signalCount = signalCount;
        }
        
        // Getters
        public String getSymbol() { return symbol; }
        public String getInterval() { return interval; }
        public int getTimePeriod() { return timePeriod; }
        public MACDParameters getParameters() { return parameters; }
        public SimpleBacktestMetrics getMetrics() { return metrics; }
        public String getStatus() { return status; }
        public int getSignalCount() { return signalCount; }
    }
    
    public static class QuickAnalysisResult {
        private int totalTests;
        private int successfulTests;
        private double successRate;
        private double averageProfit;
        private double averageSharpeRatio;
        private double averageWinRate;
        private List<AnalysisResult> bestResults;
        private Map<String, Double> parameterPerformance;
        private Map<String, Double> symbolPerformance;
        private Map<String, Double> timeframePerformance;
        
        // Getters and setters
        public int getTotalTests() { return totalTests; }
        public void setTotalTests(int totalTests) { this.totalTests = totalTests; }
        
        public int getSuccessfulTests() { return successfulTests; }
        public void setSuccessfulTests(int successfulTests) { this.successfulTests = successfulTests; }
        
        public double getSuccessRate() { return successRate; }
        public void setSuccessRate(double successRate) { this.successRate = successRate; }
        
        public double getAverageProfit() { return averageProfit; }
        public void setAverageProfit(double averageProfit) { this.averageProfit = averageProfit; }
        
        public double getAverageSharpeRatio() { return averageSharpeRatio; }
        public void setAverageSharpeRatio(double averageSharpeRatio) { this.averageSharpeRatio = averageSharpeRatio; }
        
        public double getAverageWinRate() { return averageWinRate; }
        public void setAverageWinRate(double averageWinRate) { this.averageWinRate = averageWinRate; }
        
        public List<AnalysisResult> getBestResults() { return bestResults; }
        public void setBestResults(List<AnalysisResult> bestResults) { this.bestResults = bestResults; }
        
        public Map<String, Double> getParameterPerformance() { return parameterPerformance; }
        public void setParameterPerformance(Map<String, Double> parameterPerformance) { this.parameterPerformance = parameterPerformance; }
        
        public Map<String, Double> getSymbolPerformance() { return symbolPerformance; }
        public void setSymbolPerformance(Map<String, Double> symbolPerformance) { this.symbolPerformance = symbolPerformance; }
        
        public Map<String, Double> getTimeframePerformance() { return timeframePerformance; }
        public void setTimeframePerformance(Map<String, Double> timeframePerformance) { this.timeframePerformance = timeframePerformance; }
    }
    
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
        
        public long getEntryTime() { return entryTime; }
        public long getExitTime() { return exitTime; }
        public BigDecimal getEntryPrice() { return entryPrice; }
        public BigDecimal getExitPrice() { return exitPrice; }
        public BigDecimal getPnl() { return pnl; }
        public BigDecimal getPnlPercent() { return pnlPercent; }
        public boolean isWin() { return isWin; }
    }
}
