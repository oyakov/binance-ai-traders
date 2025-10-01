package com.oyakov.binance_trader_macd.backtest;

import com.oyakov.binance_shared_model.avro.KlineEvent;
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
import java.util.stream.Collectors;

/**
 * Comprehensive analysis service for extensive MACD strategy testing
 */
@Service
public class ComprehensiveAnalysisService {
    
    private final RestTemplate restTemplate;
    private final ExecutorService executorService;
    private final Map<String, List<KlineEvent>> dataCache;
    
    public ComprehensiveAnalysisService() {
        this.restTemplate = new RestTemplate();
        this.executorService = Executors.newFixedThreadPool(8);
        this.dataCache = new HashMap<>();
    }
    
    /**
     * Run comprehensive analysis across multiple dimensions
     */
    public CompletableFuture<ComprehensiveAnalysisResult> runComprehensiveAnalysis() {
        return CompletableFuture.supplyAsync(() -> {
            System.out.println("=== COMPREHENSIVE MACD STRATEGY ANALYSIS ===");
            System.out.println("Running extensive analysis across multiple dimensions...\n");
            
            // Define analysis dimensions
            String[] symbols = {"BTCUSDT", "ETHUSDT", "ADAUSDT", "BNBUSDT", "SOLUSDT", "XRPUSDT"};
            String[] intervals = {"1h", "4h", "1d", "1w"};
            int[] timePeriods = {30, 90, 180, 365};
            
            // Define extensive MACD parameter sets
            List<MACDParameters> parameterSets = createExtensiveParameterSets();
            
            System.out.println("Analysis Configuration:");
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
                                if (completedTests % 50 == 0 || completedTests == totalTests) {
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
            
            System.out.println("\n=== ANALYSIS COMPLETE ===");
            System.out.println("Total results: " + allResults.size());
            
            // Generate comprehensive insights
            return generateComprehensiveInsights(allResults);
            
        }, executorService);
    }
    
    /**
     * Create extensive MACD parameter sets for testing
     */
    private List<MACDParameters> createExtensiveParameterSets() {
        List<MACDParameters> parameters = new ArrayList<>();
        
        // Standard parameters
        parameters.add(new MACDParameters(12, 26, 9));   // Classic
        parameters.add(new MACDParameters(8, 21, 5));     // Fast
        parameters.add(new MACDParameters(19, 39, 9));    // Slow
        parameters.add(new MACDParameters(5, 35, 5));     // Very fast/slow
        parameters.add(new MACDParameters(15, 30, 10));   // Custom 1
        
        // Fast variations
        parameters.add(new MACDParameters(5, 13, 3));     // Very fast
        parameters.add(new MACDParameters(6, 19, 6));     // Fast variant
        parameters.add(new MACDParameters(9, 21, 7));     // Fast-medium
        parameters.add(new MACDParameters(10, 25, 8));    // Medium-fast
        
        // Slow variations
        parameters.add(new MACDParameters(20, 40, 10));   // Slow variant
        parameters.add(new MACDParameters(25, 50, 12));   // Very slow
        parameters.add(new MACDParameters(30, 60, 15));   // Ultra slow
        parameters.add(new MACDParameters(15, 45, 9));    // Medium-slow
        
        // Signal period variations
        parameters.add(new MACDParameters(12, 26, 3));    // Fast signal
        parameters.add(new MACDParameters(12, 26, 5));    // Medium signal
        parameters.add(new MACDParameters(12, 26, 12));   // Slow signal
        parameters.add(new MACDParameters(12, 26, 15));   // Very slow signal
        
        // Balanced variations
        parameters.add(new MACDParameters(7, 14, 7));     // Balanced 1
        parameters.add(new MACDParameters(10, 20, 10));   // Balanced 2
        parameters.add(new MACDParameters(14, 28, 14));   // Balanced 3
        parameters.add(new MACDParameters(16, 32, 16));   // Balanced 4
        
        // Extreme variations
        parameters.add(new MACDParameters(3, 7, 3));      // Ultra fast
        parameters.add(new MACDParameters(50, 100, 25));  // Ultra slow
        parameters.add(new MACDParameters(4, 8, 2));      // Very fast
        parameters.add(new MACDParameters(40, 80, 20));   // Very slow
        
        return parameters;
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
                
                // Calculate market condition
                MarketCondition marketCondition = analyzeMarketCondition(klines);
                
                return new AnalysisResult(symbol, interval, timePeriod, params, 
                    metrics, "Success", signals.size(), marketCondition);
                
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
     * Analyze market condition
     */
    private MarketCondition analyzeMarketCondition(List<KlineEvent> klines) {
        if (klines.size() < 10) {
            return MarketCondition.UNKNOWN;
        }
        
        List<BigDecimal> closes = klines.stream()
            .map(KlineEvent::getClose)
            .collect(Collectors.toList());
        
        // Calculate price change
        BigDecimal firstPrice = closes.get(0);
        BigDecimal lastPrice = closes.get(closes.size() - 1);
        BigDecimal priceChange = lastPrice.subtract(firstPrice)
            .divide(firstPrice, 4, BigDecimal.ROUND_HALF_UP)
            .multiply(BigDecimal.valueOf(100));
        
        // Calculate volatility
        BigDecimal avgPrice = closes.stream()
            .reduce(BigDecimal.ZERO, BigDecimal::add)
            .divide(BigDecimal.valueOf(closes.size()), 4, BigDecimal.ROUND_HALF_UP);
        
        BigDecimal variance = closes.stream()
            .map(price -> price.subtract(avgPrice).pow(2))
            .reduce(BigDecimal.ZERO, BigDecimal::add)
            .divide(BigDecimal.valueOf(closes.size()), 4, BigDecimal.ROUND_HALF_UP);
        
        BigDecimal volatility = BigDecimal.valueOf(Math.sqrt(variance.doubleValue()))
            .divide(avgPrice, 4, BigDecimal.ROUND_HALF_UP)
            .multiply(BigDecimal.valueOf(100));
        
        // Classify market condition
        if (priceChange.compareTo(BigDecimal.valueOf(20)) > 0) {
            return MarketCondition.STRONG_BULL;
        } else if (priceChange.compareTo(BigDecimal.valueOf(5)) > 0) {
            return MarketCondition.BULL;
        } else if (priceChange.compareTo(BigDecimal.valueOf(-5)) > 0) {
            return MarketCondition.SIDEWAYS;
        } else if (priceChange.compareTo(BigDecimal.valueOf(-20)) > 0) {
            return MarketCondition.BEAR;
        } else {
            return MarketCondition.STRONG_BEAR;
        }
    }
    
    /**
     * Generate comprehensive insights from all results
     */
    private ComprehensiveAnalysisResult generateComprehensiveInsights(List<AnalysisResult> results) {
        System.out.println("Generating comprehensive insights...");
        
        // Filter successful results
        List<AnalysisResult> successfulResults = results.stream()
            .filter(r -> "Success".equals(r.getStatus()))
            .collect(Collectors.toList());
        
        System.out.println("Successful results: " + successfulResults.size() + "/" + results.size());
        
        if (successfulResults.isEmpty()) {
            return new ComprehensiveAnalysisResult("No successful results to analyze");
        }
        
        // Generate insights
        ComprehensiveAnalysisResult analysisResult = new ComprehensiveAnalysisResult();
        
        // Overall statistics
        analysisResult.setTotalTests(results.size());
        analysisResult.setSuccessfulTests(successfulResults.size());
        analysisResult.setSuccessRate(successfulResults.size() * 100.0 / results.size());
        
        // Performance analysis
        analyzePerformance(analysisResult, successfulResults);
        
        // Parameter analysis
        analyzeParameters(analysisResult, successfulResults);
        
        // Symbol analysis
        analyzeSymbols(analysisResult, successfulResults);
        
        // Timeframe analysis
        analyzeTimeframes(analysisResult, successfulResults);
        
        // Market condition analysis
        analyzeMarketConditions(analysisResult, successfulResults);
        
        // Risk analysis
        analyzeRisk(analysisResult, successfulResults);
        
        return analysisResult;
    }
    
    private void analyzePerformance(ComprehensiveAnalysisResult result, List<AnalysisResult> successfulResults) {
        // Calculate overall statistics
        double avgProfit = successfulResults.stream()
            .mapToDouble(r -> r.getMetrics().getNetProfitPercent().doubleValue())
            .average().orElse(0.0);
        
        double avgSharpe = successfulResults.stream()
            .mapToDouble(r -> r.getMetrics().getSharpeRatio().doubleValue())
            .average().orElse(0.0);
        
        double avgWinRate = successfulResults.stream()
            .mapToDouble(r -> r.getMetrics().getWinRate().doubleValue())
            .average().orElse(0.0);
        
        // Find best and worst performers
        AnalysisResult bestResult = successfulResults.stream()
            .max(Comparator.comparing(r -> r.getMetrics().getNetProfitPercent().doubleValue()))
            .orElse(null);
        
        AnalysisResult worstResult = successfulResults.stream()
            .min(Comparator.comparing(r -> r.getMetrics().getNetProfitPercent().doubleValue()))
            .orElse(null);
        
        result.setAverageProfit(avgProfit);
        result.setAverageSharpeRatio(avgSharpe);
        result.setAverageWinRate(avgWinRate);
        result.setBestResult(bestResult);
        result.setWorstResult(worstResult);
    }
    
    private void analyzeParameters(ComprehensiveAnalysisResult result, List<AnalysisResult> successfulResults) {
        Map<String, List<AnalysisResult>> paramGroups = successfulResults.stream()
            .collect(Collectors.groupingBy(r -> r.getParameters().toString()));
        
        Map<String, Double> paramPerformance = new HashMap<>();
        for (Map.Entry<String, List<AnalysisResult>> entry : paramGroups.entrySet()) {
            double avgProfit = entry.getValue().stream()
                .mapToDouble(r -> r.getMetrics().getNetProfitPercent().doubleValue())
                .average().orElse(0.0);
            paramPerformance.put(entry.getKey(), avgProfit);
        }
        
        // Sort by performance
        List<Map.Entry<String, Double>> sortedParams = paramPerformance.entrySet().stream()
            .sorted(Map.Entry.<String, Double>comparingByValue().reversed())
            .collect(Collectors.toList());
        
        result.setParameterPerformance(sortedParams);
    }
    
    private void analyzeSymbols(ComprehensiveAnalysisResult result, List<AnalysisResult> successfulResults) {
        Map<String, List<AnalysisResult>> symbolGroups = successfulResults.stream()
            .collect(Collectors.groupingBy(AnalysisResult::getSymbol));
        
        Map<String, Double> symbolPerformance = new HashMap<>();
        for (Map.Entry<String, List<AnalysisResult>> entry : symbolGroups.entrySet()) {
            double avgProfit = entry.getValue().stream()
                .mapToDouble(r -> r.getMetrics().getNetProfitPercent().doubleValue())
                .average().orElse(0.0);
            symbolPerformance.put(entry.getKey(), avgProfit);
        }
        
        result.setSymbolPerformance(symbolPerformance);
    }
    
    private void analyzeTimeframes(ComprehensiveAnalysisResult result, List<AnalysisResult> successfulResults) {
        Map<String, List<AnalysisResult>> timeframeGroups = successfulResults.stream()
            .collect(Collectors.groupingBy(AnalysisResult::getInterval));
        
        Map<String, Double> timeframePerformance = new HashMap<>();
        for (Map.Entry<String, List<AnalysisResult>> entry : timeframeGroups.entrySet()) {
            double avgProfit = entry.getValue().stream()
                .mapToDouble(r -> r.getMetrics().getNetProfitPercent().doubleValue())
                .average().orElse(0.0);
            timeframePerformance.put(entry.getKey(), avgProfit);
        }
        
        result.setTimeframePerformance(timeframePerformance);
    }
    
    private void analyzeMarketConditions(ComprehensiveAnalysisResult result, List<AnalysisResult> successfulResults) {
        Map<MarketCondition, List<AnalysisResult>> conditionGroups = successfulResults.stream()
            .filter(r -> r.getMarketCondition() != null)
            .collect(Collectors.groupingBy(AnalysisResult::getMarketCondition));
        
        Map<MarketCondition, Double> conditionPerformance = new HashMap<>();
        for (Map.Entry<MarketCondition, List<AnalysisResult>> entry : conditionGroups.entrySet()) {
            double avgProfit = entry.getValue().stream()
                .mapToDouble(r -> r.getMetrics().getNetProfitPercent().doubleValue())
                .average().orElse(0.0);
            conditionPerformance.put(entry.getKey(), avgProfit);
        }
        
        result.setMarketConditionPerformance(conditionPerformance);
    }
    
    private void analyzeRisk(ComprehensiveAnalysisResult result, List<AnalysisResult> successfulResults) {
        // Calculate risk metrics
        double avgMaxDrawdown = successfulResults.stream()
            .mapToDouble(r -> r.getMetrics().getMaxDrawdownPercent().doubleValue())
            .average().orElse(0.0);
        
        double maxDrawdown = successfulResults.stream()
            .mapToDouble(r -> r.getMetrics().getMaxDrawdownPercent().doubleValue())
            .max().orElse(0.0);
        
        // Calculate profit factor
        double totalWins = successfulResults.stream()
            .mapToDouble(r -> r.getMetrics().getNetProfitPercent().doubleValue())
            .filter(profit -> profit > 0)
            .sum();
        
        double totalLosses = Math.abs(successfulResults.stream()
            .mapToDouble(r -> r.getMetrics().getNetProfitPercent().doubleValue())
            .filter(profit -> profit < 0)
            .sum());
        
        double profitFactor = totalLosses > 0 ? totalWins / totalLosses : Double.POSITIVE_INFINITY;
        
        result.setAverageMaxDrawdown(avgMaxDrawdown);
        result.setMaximumDrawdown(maxDrawdown);
        result.setProfitFactor(profitFactor);
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
        private final MarketCondition marketCondition;
        
        public AnalysisResult(String symbol, String interval, int timePeriod, MACDParameters parameters,
                            SimpleBacktestMetrics metrics, String status, int signalCount) {
            this(symbol, interval, timePeriod, parameters, metrics, status, signalCount, null);
        }
        
        public AnalysisResult(String symbol, String interval, int timePeriod, MACDParameters parameters,
                            SimpleBacktestMetrics metrics, String status, int signalCount, MarketCondition marketCondition) {
            this.symbol = symbol;
            this.interval = interval;
            this.timePeriod = timePeriod;
            this.parameters = parameters;
            this.metrics = metrics;
            this.status = status;
            this.signalCount = signalCount;
            this.marketCondition = marketCondition;
        }
        
        // Getters
        public String getSymbol() { return symbol; }
        public String getInterval() { return interval; }
        public int getTimePeriod() { return timePeriod; }
        public MACDParameters getParameters() { return parameters; }
        public SimpleBacktestMetrics getMetrics() { return metrics; }
        public String getStatus() { return status; }
        public int getSignalCount() { return signalCount; }
        public MarketCondition getMarketCondition() { return marketCondition; }
    }
    
    public static class ComprehensiveAnalysisResult {
        private int totalTests;
        private int successfulTests;
        private double successRate;
        private double averageProfit;
        private double averageSharpeRatio;
        private double averageWinRate;
        private AnalysisResult bestResult;
        private AnalysisResult worstResult;
        private List<Map.Entry<String, Double>> parameterPerformance;
        private Map<String, Double> symbolPerformance;
        private Map<String, Double> timeframePerformance;
        private Map<MarketCondition, Double> marketConditionPerformance;
        private double averageMaxDrawdown;
        private double maximumDrawdown;
        private double profitFactor;
        private String summary;
        
        public ComprehensiveAnalysisResult() {}
        
        public ComprehensiveAnalysisResult(String summary) {
            this.summary = summary;
        }
        
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
        
        public AnalysisResult getBestResult() { return bestResult; }
        public void setBestResult(AnalysisResult bestResult) { this.bestResult = bestResult; }
        
        public AnalysisResult getWorstResult() { return worstResult; }
        public void setWorstResult(AnalysisResult worstResult) { this.worstResult = worstResult; }
        
        public List<Map.Entry<String, Double>> getParameterPerformance() { return parameterPerformance; }
        public void setParameterPerformance(List<Map.Entry<String, Double>> parameterPerformance) { this.parameterPerformance = parameterPerformance; }
        
        public Map<String, Double> getSymbolPerformance() { return symbolPerformance; }
        public void setSymbolPerformance(Map<String, Double> symbolPerformance) { this.symbolPerformance = symbolPerformance; }
        
        public Map<String, Double> getTimeframePerformance() { return timeframePerformance; }
        public void setTimeframePerformance(Map<String, Double> timeframePerformance) { this.timeframePerformance = timeframePerformance; }
        
        public Map<MarketCondition, Double> getMarketConditionPerformance() { return marketConditionPerformance; }
        public void setMarketConditionPerformance(Map<MarketCondition, Double> marketConditionPerformance) { this.marketConditionPerformance = marketConditionPerformance; }
        
        public double getAverageMaxDrawdown() { return averageMaxDrawdown; }
        public void setAverageMaxDrawdown(double averageMaxDrawdown) { this.averageMaxDrawdown = averageMaxDrawdown; }
        
        public double getMaximumDrawdown() { return maximumDrawdown; }
        public void setMaximumDrawdown(double maximumDrawdown) { this.maximumDrawdown = maximumDrawdown; }
        
        public double getProfitFactor() { return profitFactor; }
        public void setProfitFactor(double profitFactor) { this.profitFactor = profitFactor; }
        
        public String getSummary() { return summary; }
        public void setSummary(String summary) { this.summary = summary; }
    }
    
    public enum MarketCondition {
        STRONG_BULL, BULL, SIDEWAYS, BEAR, STRONG_BEAR, UNKNOWN
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
