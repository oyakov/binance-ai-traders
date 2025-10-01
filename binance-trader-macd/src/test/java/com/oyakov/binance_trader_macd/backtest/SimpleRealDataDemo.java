package com.oyakov.binance_trader_macd.backtest;

import com.oyakov.binance_trader_macd.backtest.MACDParameters;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import org.junit.jupiter.api.Test;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * Simple standalone demo for real data analysis
 */
public class SimpleRealDataDemo {
    
    private final RestTemplate restTemplate;
    private final ExecutorService executorService;
    
    public SimpleRealDataDemo() {
        this.restTemplate = new RestTemplate();
        this.executorService = Executors.newFixedThreadPool(2);
    }
    
    @Test
    public void runRealDataAnalysis() {
        main(new String[0]);
    }
    
    public static void main(String[] args) {
        System.out.println("=== SIMPLE REAL DATA ANALYSIS DEMO ===");
        System.out.println("This demo will collect real data from Binance API and run analysis");
        System.out.println("to understand why the MACD strategy is underperforming.\n");
        
        SimpleRealDataDemo demo = new SimpleRealDataDemo();
        
        try {
            demo.runSingleSymbolAnalysis();
        } catch (Exception e) {
            System.err.println("Error running demo: " + e.getMessage());
            e.printStackTrace();
        } finally {
            demo.executorService.shutdown();
        }
    }
    
    public void runSingleSymbolAnalysis() {
        System.out.println("=== SINGLE SYMBOL ANALYSIS ===");
        System.out.println("Analyzing BTCUSDT with different MACD parameters...\n");
        
        try {
            MACDParameters[] paramSets = {
                new MACDParameters(12, 26, 9),  // Standard
                new MACDParameters(8, 21, 5),   // Fast
                new MACDParameters(19, 39, 9),  // Slow
                new MACDParameters(5, 35, 5),   // Custom 1
                new MACDParameters(15, 30, 10)  // Custom 2
            };
            
            for (MACDParameters params : paramSets) {
                System.out.println("Testing parameters: " + params.toString());
                
                CompletableFuture<SimpleBacktestResult> future = runBacktestOnRealData(
                    "BTCUSDT", "1d", 90, params);
                
                SimpleBacktestResult result = future.get();
                
                if ("Success".equals(result.getStatus())) {
                    System.out.printf("  Net Profit: %.2f%%%n", 
                        result.getMetrics().getNetProfitPercent().doubleValue());
                    System.out.printf("  Sharpe Ratio: %.2f%n", 
                        result.getMetrics().getSharpeRatio().doubleValue());
                    System.out.printf("  Win Rate: %.2f%%%n", 
                        result.getMetrics().getWinRate().doubleValue());
                    System.out.printf("  Max Drawdown: %.2f%%%n", 
                        result.getMetrics().getMaxDrawdownPercent().doubleValue());
                    System.out.printf("  Total Trades: %d%n", 
                        result.getMetrics().getTotalTrades());
                } else {
                    System.out.println("  Error: " + result.getStatus());
                }
                System.out.println();
            }
            
        } catch (Exception e) {
            System.err.println("Error in single symbol analysis: " + e.getMessage());
        }
    }
    
    public CompletableFuture<SimpleBacktestResult> runBacktestOnRealData(
            String symbol, String interval, int days, MACDParameters params) {
        
        return CompletableFuture.supplyAsync(() -> {
            try {
                System.out.println("  Collecting data for " + symbol + " " + interval + " (" + days + " days)...");
                
                long endTime = System.currentTimeMillis();
                long startTime = endTime - (days * 24 * 60 * 60 * 1000L);
                
                String url = String.format(
                    "https://api.binance.com/api/v3/klines?symbol=%s&interval=%s&startTime=%d&endTime=%d&limit=1000",
                    symbol, interval, startTime, endTime
                );
                
                List<List<Object>> response = restTemplate.getForObject(url, List.class);
                
                if (response == null || response.isEmpty()) {
                    return new SimpleBacktestResult(
                        symbol, interval, days, params,
                        new SimpleBacktestMetrics(BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, 0), 
                        "No data received from Binance API"
                    );
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
                        System.err.println("    Error parsing kline data: " + e.getMessage());
                    }
                }
                
                System.out.println("    Collected " + klines.size() + " klines");
                
                if (klines.isEmpty()) {
                    return new SimpleBacktestResult(
                        symbol, interval, days, params,
                        new SimpleBacktestMetrics(BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, 0), 
                        "No valid kline data"
                    );
                }
                
                CustomMACDAnalyzer analyzer = new CustomMACDAnalyzer();
                List<CustomMACDAnalyzer.MACDSignal> signals = analyzer.analyzeSignals(klines, params);
                
                List<SimulatedTrade> trades = simulateTrades(klines, signals);
                
                SimpleBacktestMetrics metrics = calculateSimpleMetrics(trades);
                
                return new SimpleBacktestResult(
                    symbol, interval, days, params,
                    metrics, "Success"
                );
                
            } catch (Exception e) {
                System.err.println("    Error running backtest: " + e.getMessage());
                return new SimpleBacktestResult(
                    symbol, interval, days, params,
                    new SimpleBacktestMetrics(BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, 0), 
                    "Error: " + e.getMessage()
                );
            }
        }, executorService);
    }
    
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