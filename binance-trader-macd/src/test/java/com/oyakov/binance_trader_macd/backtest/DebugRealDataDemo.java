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
 * Debug version of real data demo to diagnose MACD signal generation
 */
public class DebugRealDataDemo {
    
    private final RestTemplate restTemplate;
    private final ExecutorService executorService;
    
    public DebugRealDataDemo() {
        this.restTemplate = new RestTemplate();
        this.executorService = Executors.newFixedThreadPool(2);
    }
    
    @Test
    public void debugMACDSignalGeneration() {
        System.out.println("=== DEBUG MACD SIGNAL GENERATION ===");
        System.out.println("This demo will debug why MACD signals are not being generated.\n");
        
        try {
            // Test with a single parameter set first
            MACDParameters params = new MACDParameters(12, 26, 9);
            
            System.out.println("Testing with parameters: " + params.toString());
            
            CompletableFuture<SimpleBacktestResult> future = runDebugBacktestOnRealData(
                "BTCUSDT", "1d", 90, params);
            
            SimpleBacktestResult result = future.get();
            
            System.out.println("\n=== FINAL RESULT ===");
            System.out.println("Status: " + result.getStatus());
            System.out.println("Net Profit: " + result.getMetrics().getNetProfitPercent() + "%");
            System.out.println("Total Trades: " + result.getMetrics().getTotalTrades());
            
        } catch (Exception e) {
            System.err.println("Error in debug analysis: " + e.getMessage());
            e.printStackTrace();
        } finally {
            executorService.shutdown();
        }
    }
    
    public CompletableFuture<SimpleBacktestResult> runDebugBacktestOnRealData(
            String symbol, String interval, int days, MACDParameters params) {
        
        return CompletableFuture.supplyAsync(() -> {
            try {
                System.out.println("Collecting data for " + symbol + " " + interval + " (" + days + " days)...");
                
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
                
                System.out.println("Collected " + klines.size() + " klines");
                
                if (klines.isEmpty()) {
                    return new SimpleBacktestResult(
                        symbol, interval, days, params,
                        new SimpleBacktestMetrics(BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, 0), 
                        "No valid kline data"
                    );
                }
                
                // Use debug analyzer
                DebugMACDAnalyzer analyzer = new DebugMACDAnalyzer();
                List<DebugMACDAnalyzer.MACDSignal> signals = analyzer.analyzeSignals(klines, params);
                
                System.out.println("Generated " + signals.size() + " signals from debug analyzer");
                
                // Convert to regular signals for trade simulation
                List<SimulatedTrade> trades = simulateTrades(klines, signals);
                
                SimpleBacktestMetrics metrics = calculateSimpleMetrics(trades);
                
                return new SimpleBacktestResult(
                    symbol, interval, days, params,
                    metrics, "Success"
                );
                
            } catch (Exception e) {
                System.err.println("    Error running debug backtest: " + e.getMessage());
                e.printStackTrace();
                return new SimpleBacktestResult(
                    symbol, interval, days, params,
                    new SimpleBacktestMetrics(BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, 0), 
                    "Error: " + e.getMessage()
                );
            }
        }, executorService);
    }
    
    private List<SimulatedTrade> simulateTrades(List<KlineEvent> klines, List<DebugMACDAnalyzer.MACDSignal> signals) {
        List<SimulatedTrade> trades = new ArrayList<>();
        boolean inPosition = false;
        BigDecimal entryPrice = BigDecimal.ZERO;
        long entryTime = 0;
        
        System.out.println("Simulating trades with " + signals.size() + " signals...");
        
        for (DebugMACDAnalyzer.MACDSignal signal : signals) {
            if (signal.getSignal() == DebugMACDAnalyzer.SignalType.BUY && !inPosition) {
                inPosition = true;
                entryPrice = signal.getPrice();
                entryTime = signal.getTimestamp();
                System.out.println("  BUY signal at " + entryPrice + " (time: " + entryTime + ")");
                
            } else if (signal.getSignal() == DebugMACDAnalyzer.SignalType.SELL && inPosition) {
                inPosition = false;
                BigDecimal exitPrice = signal.getPrice();
                long exitTime = signal.getTimestamp();
                
                BigDecimal pnl = exitPrice.subtract(entryPrice);
                BigDecimal pnlPercent = pnl.divide(entryPrice, 4, BigDecimal.ROUND_HALF_UP)
                    .multiply(BigDecimal.valueOf(100));
                
                System.out.println("  SELL signal at " + exitPrice + " (time: " + exitTime + ") - PnL: " + pnlPercent + "%");
                
                trades.add(new SimulatedTrade(
                    entryTime, exitTime, entryPrice, exitPrice,
                    pnl, pnlPercent, pnl.compareTo(BigDecimal.ZERO) > 0
                ));
            }
        }
        
        System.out.println("Simulated " + trades.size() + " trades");
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
