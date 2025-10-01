package com.oyakov.binance_trader_macd.backtest;

import org.junit.jupiter.api.Test;

import java.util.Map;
import java.util.concurrent.CompletableFuture;

/**
 * Comprehensive analysis demo for extensive MACD strategy testing
 */
public class ComprehensiveAnalysisDemo {
    
    @Test
    public void runComprehensiveAnalysis() {
        System.out.println("=== COMPREHENSIVE MACD STRATEGY ANALYSIS ===");
        System.out.println("This demo will run extensive analysis across multiple dimensions:");
        System.out.println("- 6 symbols (BTCUSDT, ETHUSDT, ADAUSDT, BNBUSDT, SOLUSDT, XRPUSDT)");
        System.out.println("- 4 timeframes (1h, 4h, 1d, 1w)");
        System.out.println("- 4 time periods (30, 90, 180, 365 days)");
        System.out.println("- 25+ MACD parameter combinations");
        System.out.println("- Total: 2,400+ individual tests");
        System.out.println();
        System.out.println("This will take several minutes to complete...\n");
        
        try {
            ComprehensiveAnalysisService service = new ComprehensiveAnalysisService();
            
            CompletableFuture<ComprehensiveAnalysisService.ComprehensiveAnalysisResult> future = 
                service.runComprehensiveAnalysis();
            
            ComprehensiveAnalysisService.ComprehensiveAnalysisResult result = future.get();
            
            // Print comprehensive results
            printComprehensiveResults(result);
            
        } catch (Exception e) {
            System.err.println("Error running comprehensive analysis: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private void printComprehensiveResults(ComprehensiveAnalysisService.ComprehensiveAnalysisResult result) {
        System.out.println("\n" + "=".repeat(80));
        System.out.println("COMPREHENSIVE ANALYSIS RESULTS");
        System.out.println("=".repeat(80));
        
        // Overall statistics
        System.out.println("\n📊 OVERALL STATISTICS");
        System.out.println("-".repeat(40));
        System.out.printf("Total Tests: %d\n", result.getTotalTests());
        System.out.printf("Successful Tests: %d\n", result.getSuccessfulTests());
        System.out.printf("Success Rate: %.1f%%\n", result.getSuccessRate());
        System.out.printf("Average Profit: %.2f%%\n", result.getAverageProfit());
        System.out.printf("Average Sharpe Ratio: %.2f\n", result.getAverageSharpeRatio());
        System.out.printf("Average Win Rate: %.1f%%\n", result.getAverageWinRate());
        
        // Risk metrics
        System.out.println("\n⚠️ RISK METRICS");
        System.out.println("-".repeat(40));
        System.out.printf("Average Max Drawdown: %.2f%%\n", result.getAverageMaxDrawdown());
        System.out.printf("Maximum Drawdown: %.2f%%\n", result.getMaximumDrawdown());
        System.out.printf("Profit Factor: %.2f\n", result.getProfitFactor());
        
        // Best and worst performers
        if (result.getBestResult() != null) {
            System.out.println("\n🏆 BEST PERFORMER");
            System.out.println("-".repeat(40));
            printResultDetails("BEST", result.getBestResult());
        }
        
        if (result.getWorstResult() != null) {
            System.out.println("\n❌ WORST PERFORMER");
            System.out.println("-".repeat(40));
            printResultDetails("WORST", result.getWorstResult());
        }
        
        // Parameter performance
        if (result.getParameterPerformance() != null && !result.getParameterPerformance().isEmpty()) {
            System.out.println("\n📈 TOP 10 PARAMETER COMBINATIONS");
            System.out.println("-".repeat(40));
            result.getParameterPerformance().stream()
                .limit(10)
                .forEach(entry -> System.out.printf("%-20s: %.2f%%\n", entry.getKey(), entry.getValue()));
        }
        
        // Symbol performance
        if (result.getSymbolPerformance() != null && !result.getSymbolPerformance().isEmpty()) {
            System.out.println("\n💰 SYMBOL PERFORMANCE");
            System.out.println("-".repeat(40));
            result.getSymbolPerformance().entrySet().stream()
                .sorted(Map.Entry.<String, Double>comparingByValue().reversed())
                .forEach(entry -> System.out.printf("%-10s: %.2f%%\n", entry.getKey(), entry.getValue()));
        }
        
        // Timeframe performance
        if (result.getTimeframePerformance() != null && !result.getTimeframePerformance().isEmpty()) {
            System.out.println("\n⏰ TIMEFRAME PERFORMANCE");
            System.out.println("-".repeat(40));
            result.getTimeframePerformance().entrySet().stream()
                .sorted(Map.Entry.<String, Double>comparingByValue().reversed())
                .forEach(entry -> System.out.printf("%-5s: %.2f%%\n", entry.getKey(), entry.getValue()));
        }
        
        // Market condition performance
        if (result.getMarketConditionPerformance() != null && !result.getMarketConditionPerformance().isEmpty()) {
            System.out.println("\n🌍 MARKET CONDITION PERFORMANCE");
            System.out.println("-".repeat(40));
            result.getMarketConditionPerformance().entrySet().stream()
                .sorted(Map.Entry.<ComprehensiveAnalysisService.MarketCondition, Double>comparingByValue().reversed())
                .forEach(entry -> System.out.printf("%-15s: %.2f%%\n", entry.getKey(), entry.getValue()));
        }
        
        // Insights and recommendations
        printInsightsAndRecommendations(result);
        
        System.out.println("\n" + "=".repeat(80));
        System.out.println("ANALYSIS COMPLETE");
        System.out.println("=".repeat(80));
    }
    
    private void printResultDetails(String label, ComprehensiveAnalysisService.AnalysisResult result) {
        System.out.printf("%s: %s %s %dd %s\n", label, 
            result.getSymbol(), result.getInterval(), result.getTimePeriod(), result.getParameters().toString());
        System.out.printf("  Net Profit: %.2f%%\n", result.getMetrics().getNetProfitPercent().doubleValue());
        System.out.printf("  Sharpe Ratio: %.2f\n", result.getMetrics().getSharpeRatio().doubleValue());
        System.out.printf("  Win Rate: %.1f%%\n", result.getMetrics().getWinRate().doubleValue());
        System.out.printf("  Max Drawdown: %.2f%%\n", result.getMetrics().getMaxDrawdownPercent().doubleValue());
        System.out.printf("  Total Trades: %d\n", result.getMetrics().getTotalTrades());
        System.out.printf("  Signal Count: %d\n", result.getSignalCount());
        if (result.getMarketCondition() != null) {
            System.out.printf("  Market Condition: %s\n", result.getMarketCondition());
        }
    }
    
    private void printInsightsAndRecommendations(ComprehensiveAnalysisService.ComprehensiveAnalysisResult result) {
        System.out.println("\n💡 INSIGHTS & RECOMMENDATIONS");
        System.out.println("-".repeat(40));
        
        // Overall performance insights
        if (result.getAverageProfit() > 0) {
            System.out.println("✅ Overall Strategy Performance: POSITIVE");
            System.out.printf("   Average profit across all tests: %.2f%%\n", result.getAverageProfit());
        } else {
            System.out.println("❌ Overall Strategy Performance: NEGATIVE");
            System.out.printf("   Average loss across all tests: %.2f%%\n", result.getAverageProfit());
        }
        
        // Risk assessment
        if (result.getAverageMaxDrawdown() < 5.0) {
            System.out.println("✅ Risk Level: LOW");
            System.out.printf("   Average max drawdown: %.2f%%\n", result.getAverageMaxDrawdown());
        } else if (result.getAverageMaxDrawdown() < 15.0) {
            System.out.println("⚠️ Risk Level: MODERATE");
            System.out.printf("   Average max drawdown: %.2f%%\n", result.getAverageMaxDrawdown());
        } else {
            System.out.println("🚨 Risk Level: HIGH");
            System.out.printf("   Average max drawdown: %.2f%%\n", result.getAverageMaxDrawdown());
        }
        
        // Parameter recommendations
        if (result.getParameterPerformance() != null && !result.getParameterPerformance().isEmpty()) {
            System.out.println("\n🎯 PARAMETER RECOMMENDATIONS:");
            var topParams = result.getParameterPerformance().stream().limit(3).toList();
            for (int i = 0; i < topParams.size(); i++) {
                System.out.printf("   %d. %s (%.2f%%)\n", i + 1, 
                    topParams.get(i).getKey(), topParams.get(i).getValue());
            }
        }
        
        // Symbol recommendations
        if (result.getSymbolPerformance() != null && !result.getSymbolPerformance().isEmpty()) {
            System.out.println("\n💰 BEST PERFORMING SYMBOLS:");
            result.getSymbolPerformance().entrySet().stream()
                .sorted(Map.Entry.<String, Double>comparingByValue().reversed())
                .limit(3)
                .forEach(entry -> System.out.printf("   • %s: %.2f%%\n", entry.getKey(), entry.getValue()));
        }
        
        // Timeframe recommendations
        if (result.getTimeframePerformance() != null && !result.getTimeframePerformance().isEmpty()) {
            System.out.println("\n⏰ BEST PERFORMING TIMEFRAMES:");
            result.getTimeframePerformance().entrySet().stream()
                .sorted(Map.Entry.<String, Double>comparingByValue().reversed())
                .limit(3)
                .forEach(entry -> System.out.printf("   • %s: %.2f%%\n", entry.getKey(), entry.getValue()));
        }
        
        // Market condition insights
        if (result.getMarketConditionPerformance() != null && !result.getMarketConditionPerformance().isEmpty()) {
            System.out.println("\n🌍 MARKET CONDITION INSIGHTS:");
            result.getMarketConditionPerformance().entrySet().stream()
                .sorted(Map.Entry.<ComprehensiveAnalysisService.MarketCondition, Double>comparingByValue().reversed())
                .forEach(entry -> System.out.printf("   • %s: %.2f%%\n", entry.getKey(), entry.getValue()));
        }
        
        // Strategy optimization recommendations
        System.out.println("\n🚀 STRATEGY OPTIMIZATION RECOMMENDATIONS:");
        System.out.println("   1. Use the top-performing parameter combinations identified above");
        System.out.println("   2. Focus on symbols and timeframes with positive performance");
        System.out.println("   3. Consider market condition filters for better timing");
        System.out.println("   4. Implement risk management based on drawdown analysis");
        System.out.println("   5. Test parameter combinations on longer time periods for validation");
    }
}
