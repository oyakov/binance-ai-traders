package com.oyakov.binance_trader_macd.backtest;

import com.oyakov.binance_trader_macd.backtest.MACDParameters;
import org.junit.jupiter.api.Test;

import java.util.concurrent.CompletableFuture;

/**
 * Demo class to run real data analysis
 */
public class RealDataAnalysisDemo {
    
    @Test
    public void runRealDataAnalysis() {
        System.out.println("=== REAL BINANCE DATA ANALYSIS DEMO ===");
        System.out.println("This demo will collect real data from Binance API and run comprehensive analysis");
        System.out.println("to understand why the MACD strategy is underperforming.\n");
        
        try {
            // Create the data collection service
            RealDataCollectionService service = new RealDataCollectionService();
            
            // Run comprehensive analysis
            System.out.println("Starting comprehensive analysis...");
            System.out.println("This may take a few minutes to collect data from Binance API...\n");
            
            CompletableFuture<RealDataCollectionService.AnalysisResult> future = service.runComprehensiveAnalysis();
            
            // Wait for completion
            RealDataCollectionService.AnalysisResult result = future.get();
            
            System.out.println("\n=== ANALYSIS COMPLETE ===");
            System.out.println("Summary: " + result.getSummary());
            
        } catch (Exception e) {
            System.err.println("Error running real data analysis: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    @Test
    public void runSingleSymbolAnalysis() {
        System.out.println("=== SINGLE SYMBOL ANALYSIS DEMO ===");
        System.out.println("Analyzing BTCUSDT with different parameters...\n");
        
        try {
            RealDataCollectionService service = new RealDataCollectionService();
            
            // Test different MACD parameters on BTCUSDT
            MACDParameters[] paramSets = {
                new MACDParameters(12, 26, 9),  // Standard
                new MACDParameters(8, 21, 5),   // Fast
                new MACDParameters(19, 39, 9),  // Slow
                new MACDParameters(5, 35, 5),   // Custom 1
                new MACDParameters(15, 30, 10)  // Custom 2
            };
            
            for (MACDParameters params : paramSets) {
                System.out.println("Testing parameters: " + params.toString());
                
                // Test on 1-day interval for 30 days
                CompletableFuture<SimpleBacktestResult> future = service.runBacktestOnRealData(
                    "BTCUSDT", "1d", 30, params);
                
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
                } else {
                    System.out.println("  Error: " + result.getStatus());
                }
                System.out.println();
            }
            
        } catch (Exception e) {
            System.err.println("Error running single symbol analysis: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    @Test
    public void runMultiSymbolComparison() {
        System.out.println("=== MULTI-SYMBOL COMPARISON DEMO ===");
        System.out.println("Comparing performance across different cryptocurrencies...\n");
        
        try {
            RealDataCollectionService service = new RealDataCollectionService();
            
            String[] symbols = {"BTCUSDT", "ETHUSDT", "ADAUSDT", "BNBUSDT"};
            MACDParameters standardParams = new MACDParameters(12, 26, 9);
            
            for (String symbol : symbols) {
                System.out.println("Analyzing " + symbol + "...");
                
                // Test on 4-hour interval for 30 days
                CompletableFuture<SimpleBacktestResult> future = service.runBacktestOnRealData(
                    symbol, "4h", 30, standardParams);
                
                SimpleBacktestResult result = future.get();
                
                if ("Success".equals(result.getStatus())) {
                    System.out.printf("  Net Profit: %.2f%%%n", 
                        result.getMetrics().getNetProfitPercent().doubleValue());
                    System.out.printf("  Sharpe Ratio: %.2f%n", 
                        result.getMetrics().getSharpeRatio().doubleValue());
                    System.out.printf("  Win Rate: %.2f%%%n", 
                        result.getMetrics().getWinRate().doubleValue());
                    System.out.printf("  Total Trades: %d%n", 
                        result.getMetrics().getTotalTrades());
                } else {
                    System.out.println("  Error: " + result.getStatus());
                }
                System.out.println();
            }
            
        } catch (Exception e) {
            System.err.println("Error running multi-symbol comparison: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    @Test
    public void runTimeframeAnalysis() {
        System.out.println("=== TIMEFRAME ANALYSIS DEMO ===");
        System.out.println("Comparing performance across different timeframes...\n");
        
        try {
            RealDataCollectionService service = new RealDataCollectionService();
            
            String[] intervals = {"1h", "4h", "1d", "1w"};
            MACDParameters standardParams = new MACDParameters(12, 26, 9);
            
            for (String interval : intervals) {
                System.out.println("Analyzing " + interval + " interval...");
                
                // Test on BTCUSDT for 30 days
                CompletableFuture<SimpleBacktestResult> future = service.runBacktestOnRealData(
                    "BTCUSDT", interval, 30, standardParams);
                
                SimpleBacktestResult result = future.get();
                
                if ("Success".equals(result.getStatus())) {
                    System.out.printf("  Net Profit: %.2f%%%n", 
                        result.getMetrics().getNetProfitPercent().doubleValue());
                    System.out.printf("  Sharpe Ratio: %.2f%n", 
                        result.getMetrics().getSharpeRatio().doubleValue());
                    System.out.printf("  Win Rate: %.2f%%%n", 
                        result.getMetrics().getWinRate().doubleValue());
                    System.out.printf("  Total Trades: %d%n", 
                        result.getMetrics().getTotalTrades());
                } else {
                    System.out.println("  Error: " + result.getStatus());
                }
                System.out.println();
            }
            
        } catch (Exception e) {
            System.err.println("Error running timeframe analysis: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
