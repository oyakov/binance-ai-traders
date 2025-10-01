package com.oyakov.binance_trader_macd.backtest;

import org.junit.jupiter.api.Test;

import java.util.Map;
import java.util.concurrent.CompletableFuture;

/**
 * Quick comprehensive analysis demo for faster testing
 */
public class QuickComprehensiveDemo {
    
    @Test
    public void runQuickComprehensiveAnalysis() {
        System.out.println("=== QUICK COMPREHENSIVE MACD ANALYSIS ===");
        System.out.println("This demo will run a focused analysis:");
        System.out.println("- 3 symbols (BTCUSDT, ETHUSDT, ADAUSDT)");
        System.out.println("- 2 timeframes (1d, 4h)");
        System.out.println("- 2 time periods (90, 180 days)");
        System.out.println("- 10 MACD parameter combinations");
        System.out.println("- Total: 120 individual tests");
        System.out.println();
        System.out.println("This should complete in 2-3 minutes...\n");
        
        try {
            QuickComprehensiveAnalysisService service = new QuickComprehensiveAnalysisService();
            
            CompletableFuture<QuickComprehensiveAnalysisService.QuickAnalysisResult> future = 
                service.runQuickAnalysis();
            
            QuickComprehensiveAnalysisService.QuickAnalysisResult result = future.get();
            
            // Print results
            printQuickResults(result);
            
        } catch (Exception e) {
            System.err.println("Error running quick comprehensive analysis: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private void printQuickResults(QuickComprehensiveAnalysisService.QuickAnalysisResult result) {
        System.out.println("\n" + "=".repeat(60));
        System.out.println("QUICK COMPREHENSIVE ANALYSIS RESULTS");
        System.out.println("=".repeat(60));
        
        // Overall statistics
        System.out.println("\n📊 OVERALL STATISTICS");
        System.out.println("-".repeat(30));
        System.out.printf("Total Tests: %d\n", result.getTotalTests());
        System.out.printf("Successful Tests: %d\n", result.getSuccessfulTests());
        System.out.printf("Success Rate: %.1f%%\n", result.getSuccessRate());
        System.out.printf("Average Profit: %.2f%%\n", result.getAverageProfit());
        System.out.printf("Average Sharpe Ratio: %.2f\n", result.getAverageSharpeRatio());
        System.out.printf("Average Win Rate: %.1f%%\n", result.getAverageWinRate());
        
        // Best performers
        if (result.getBestResults() != null && !result.getBestResults().isEmpty()) {
            System.out.println("\n🏆 TOP 5 PERFORMERS");
            System.out.println("-".repeat(30));
            for (int i = 0; i < Math.min(5, result.getBestResults().size()); i++) {
                var entry = result.getBestResults().get(i);
                System.out.printf("%d. %s %s %dd %s: %.2f%%\n", 
                    i + 1, entry.getSymbol(), entry.getInterval(), entry.getTimePeriod(), 
                    entry.getParameters().toString(), entry.getMetrics().getNetProfitPercent().doubleValue());
            }
        }
        
        // Parameter performance
        if (result.getParameterPerformance() != null && !result.getParameterPerformance().isEmpty()) {
            System.out.println("\n📈 PARAMETER PERFORMANCE");
            System.out.println("-".repeat(30));
            result.getParameterPerformance().forEach((param, profit) -> 
                System.out.printf("%-20s: %.2f%%\n", param, profit));
        }
        
        // Symbol performance
        if (result.getSymbolPerformance() != null && !result.getSymbolPerformance().isEmpty()) {
            System.out.println("\n💰 SYMBOL PERFORMANCE");
            System.out.println("-".repeat(30));
            result.getSymbolPerformance().forEach((symbol, profit) -> 
                System.out.printf("%-10s: %.2f%%\n", symbol, profit));
        }
        
        // Timeframe performance
        if (result.getTimeframePerformance() != null && !result.getTimeframePerformance().isEmpty()) {
            System.out.println("\n⏰ TIMEFRAME PERFORMANCE");
            System.out.println("-".repeat(30));
            result.getTimeframePerformance().forEach((timeframe, profit) -> 
                System.out.printf("%-5s: %.2f%%\n", timeframe, profit));
        }
        
        // Recommendations
        printQuickRecommendations(result);
        
        System.out.println("\n" + "=".repeat(60));
        System.out.println("QUICK ANALYSIS COMPLETE");
        System.out.println("=".repeat(60));
    }
    
    private void printQuickRecommendations(QuickComprehensiveAnalysisService.QuickAnalysisResult result) {
        System.out.println("\n💡 QUICK RECOMMENDATIONS");
        System.out.println("-".repeat(30));
        
        if (result.getAverageProfit() > 0) {
            System.out.println("✅ Strategy shows positive potential");
        } else {
            System.out.println("❌ Strategy needs optimization");
        }
        
        if (result.getBestResults() != null && !result.getBestResults().isEmpty()) {
            var best = result.getBestResults().get(0);
            System.out.printf("🎯 Best Configuration: %s %s %dd %s\n", 
                best.getSymbol(), best.getInterval(), best.getTimePeriod(), best.getParameters().toString());
            System.out.printf("   Performance: %.2f%% profit\n", best.getMetrics().getNetProfitPercent().doubleValue());
        }
        
        System.out.println("🚀 Next Steps:");
        System.out.println("   1. Run full comprehensive analysis for complete insights");
        System.out.println("   2. Test best parameters on longer time periods");
        System.out.println("   3. Implement risk management based on results");
    }
}
