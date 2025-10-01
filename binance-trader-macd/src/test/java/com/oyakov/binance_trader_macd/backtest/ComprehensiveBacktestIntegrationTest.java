package com.oyakov.binance_trader_macd.backtest;

import com.oyakov.binance_trader_macd.config.MACDTraderConfig;
import com.oyakov.binance_trader_macd.domain.signal.MACDSignalAnalyzer;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Integration test for the comprehensive backtesting system.
 * Tests both synthetic and real data backtesting capabilities.
 */
@SpringBootTest
@TestPropertySource(properties = {
        "backtest.enabled=false" // Disable automatic backtest runner
})
class ComprehensiveBacktestIntegrationTest {

    @Autowired
    private ComprehensiveBacktestService backtestService;

    @Autowired
    private MACDSignalAnalyzer signalAnalyzer;

    @Autowired
    private MACDTraderConfig traderConfig;

    @Test
    void shouldRunSyntheticBacktestSuccessfully() {
        // Given
        String symbol = "BTCUSDT";
        String interval = "1h";
        int dataPoints = 200; // 200 hours of data
        BigDecimal initialCapital = BigDecimal.valueOf(10000);

        // When
        BacktestResult result = backtestService.runSyntheticBacktest(symbol, interval, dataPoints, initialCapital);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.isSuccess()).isTrue();
        assertThat(result.getDataset()).isNotNull();
        assertThat(result.getDataset().getSymbol()).isEqualTo(symbol);
        assertThat(result.getDataset().getInterval()).isEqualTo(interval);
        assertThat(result.getDataset().getKlines()).hasSize(dataPoints);
        
        assertThat(result.getMetrics()).isNotNull();
        assertThat(result.getMetrics().getDatasetName()).contains("Synthetic");
        assertThat(result.getMetrics().getSymbol()).isEqualTo(symbol);
        assertThat(result.getMetrics().getInterval()).isEqualTo(interval);
        assertThat(result.getMetrics().getTotalTrades()).isGreaterThanOrEqualTo(0);
        
        assertThat(result.getAnalysis()).isNotNull();
        assertThat(result.getAnalysis().getSummary()).isNotBlank();
        assertThat(result.getAnalysis().getRecommendations()).isNotEmpty();
        assertThat(result.getAnalysis().getRiskAssessment()).isNotBlank();
        
        assertThat(result.getTrades()).isNotNull();
        
        // Log results for inspection
        System.out.println("=== SYNTHETIC BACKTEST RESULTS ===");
        System.out.println("Dataset: " + result.getDataset().getName());
        System.out.println("Total Trades: " + result.getMetrics().getTotalTrades());
        System.out.println("Win Rate: " + result.getMetrics().getWinRate());
        System.out.println("Net Profit: " + result.getMetrics().getNetProfit());
        System.out.println("Max Drawdown: " + result.getMetrics().getMaxDrawdown());
        System.out.println("Sharpe Ratio: " + result.getMetrics().getSharpeRatio());
        System.out.println("Summary: " + result.getAnalysis().getSummary());
        System.out.println("Risk Assessment: " + result.getAnalysis().getRiskAssessment());
    }

    @Test
    void shouldRunRealDataBacktestSuccessfully() {
        // Given
        String symbol = "BTCUSDT";
        String interval = "1h";
        int days = 7; // 7 days of data
        BigDecimal initialCapital = BigDecimal.valueOf(10000);

        // When
        BacktestResult result = backtestService.runRealDataBacktest(symbol, interval, days, initialCapital);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getDataset()).isNotNull();
        assertThat(result.getDataset().getSymbol()).isEqualTo(symbol);
        assertThat(result.getDataset().getInterval()).isEqualTo(interval);
        
        assertThat(result.getMetrics()).isNotNull();
        assertThat(result.getMetrics().getSymbol()).isEqualTo(symbol);
        assertThat(result.getMetrics().getInterval()).isEqualTo(interval);
        
        assertThat(result.getAnalysis()).isNotNull();
        assertThat(result.getAnalysis().getSummary()).isNotBlank();
        
        // Log results for inspection
        System.out.println("=== REAL DATA BACKTEST RESULTS ===");
        System.out.println("Dataset: " + result.getDataset().getName());
        System.out.println("Klines: " + result.getDataset().getKlines().size());
        System.out.println("Total Trades: " + result.getMetrics().getTotalTrades());
        System.out.println("Win Rate: " + result.getMetrics().getWinRate());
        System.out.println("Net Profit: " + result.getMetrics().getNetProfit());
        System.out.println("Max Drawdown: " + result.getMetrics().getMaxDrawdown());
        System.out.println("Sharpe Ratio: " + result.getMetrics().getSharpeRatio());
        System.out.println("Summary: " + result.getAnalysis().getSummary());
        System.out.println("Risk Assessment: " + result.getAnalysis().getRiskAssessment());
    }

    @Test
    void shouldHandleEmptyDatasetGracefully() {
        // Given
        String symbol = "INVALID";
        String interval = "1h";
        int days = 1;
        BigDecimal initialCapital = BigDecimal.valueOf(10000);

        // When
        BacktestResult result = backtestService.runRealDataBacktest(symbol, interval, days, initialCapital);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.isSuccess()).isFalse();
        assertThat(result.getAnalysis().getSummary()).contains("No data available");
    }

    @Test
    void shouldGenerateComprehensiveMetrics() {
        // Given
        String symbol = "BTCUSDT";
        String interval = "1h";
        int dataPoints = 500; // More data for better metrics
        BigDecimal initialCapital = BigDecimal.valueOf(10000);

        // When
        BacktestResult result = backtestService.runSyntheticBacktest(symbol, interval, dataPoints, initialCapital);

        // Then
        BacktestMetrics metrics = result.getMetrics();
        assertThat(metrics).isNotNull();
        
        // Verify all major metrics are calculated
        assertThat(metrics.getDatasetName()).isNotBlank();
        assertThat(metrics.getSymbol()).isEqualTo(symbol);
        assertThat(metrics.getInterval()).isEqualTo(interval);
        assertThat(metrics.getTotalTrades()).isGreaterThanOrEqualTo(0);
        assertThat(metrics.getWinRate()).isNotNull();
        assertThat(metrics.getLossRate()).isNotNull();
        assertThat(metrics.getNetProfit()).isNotNull();
        assertThat(metrics.getMaxDrawdown()).isNotNull();
        assertThat(metrics.getMaxDrawdownPercent()).isNotNull();
        assertThat(metrics.getSharpeRatio()).isNotNull();
        assertThat(metrics.getSortinoRatio()).isNotNull();
        assertThat(metrics.getProfitFactor()).isNotNull();
        assertThat(metrics.getBestTrade()).isNotNull();
        assertThat(metrics.getWorstTrade()).isNotNull();
        assertThat(metrics.getAverageWin()).isNotNull();
        assertThat(metrics.getAverageLoss()).isNotNull();
        assertThat(metrics.getMaxConsecutiveWins()).isGreaterThanOrEqualTo(0);
        assertThat(metrics.getMaxConsecutiveLosses()).isGreaterThanOrEqualTo(0);
        assertThat(metrics.getAverageTradeDurationHours()).isNotNull();
        assertThat(metrics.getTradingFrequency()).isNotNull();
        assertThat(metrics.getInitialPrice()).isNotNull();
        assertThat(metrics.getFinalPrice()).isNotNull();
        assertThat(metrics.getMarketReturn()).isNotNull();
        assertThat(metrics.getRecoveryFactor()).isNotNull();
        assertThat(metrics.getCalmarRatio()).isNotNull();
        assertThat(metrics.getExpectancy()).isNotNull();
        assertThat(metrics.getKellyPercentage()).isNotNull();
        
        // Log comprehensive metrics
        System.out.println("=== COMPREHENSIVE METRICS ===");
        System.out.println("Basic Stats:");
        System.out.println("  Total Trades: " + metrics.getTotalTrades());
        System.out.println("  Winning Trades: " + metrics.getWinningTrades());
        System.out.println("  Losing Trades: " + metrics.getLosingTrades());
        System.out.println("  Win Rate: " + metrics.getWinRate());
        System.out.println("  Loss Rate: " + metrics.getLossRate());
        
        System.out.println("Profitability:");
        System.out.println("  Net Profit: " + metrics.getNetProfit());
        System.out.println("  Net Profit %: " + metrics.getNetProfitPercent());
        System.out.println("  Average Return: " + metrics.getAverageReturn());
        System.out.println("  Best Trade: " + metrics.getBestTrade());
        System.out.println("  Worst Trade: " + metrics.getWorstTrade());
        System.out.println("  Average Win: " + metrics.getAverageWin());
        System.out.println("  Average Loss: " + metrics.getAverageLoss());
        
        System.out.println("Risk Metrics:");
        System.out.println("  Max Drawdown: " + metrics.getMaxDrawdown());
        System.out.println("  Max Drawdown %: " + metrics.getMaxDrawdownPercent());
        System.out.println("  Sharpe Ratio: " + metrics.getSharpeRatio());
        System.out.println("  Sortino Ratio: " + metrics.getSortinoRatio());
        System.out.println("  Profit Factor: " + metrics.getProfitFactor());
        System.out.println("  Recovery Factor: " + metrics.getRecoveryFactor());
        System.out.println("  Calmar Ratio: " + metrics.getCalmarRatio());
        
        System.out.println("Consecutive Trades:");
        System.out.println("  Max Consecutive Wins: " + metrics.getMaxConsecutiveWins());
        System.out.println("  Max Consecutive Losses: " + metrics.getMaxConsecutiveLosses());
        System.out.println("  Current Consecutive Wins: " + metrics.getCurrentConsecutiveWins());
        System.out.println("  Current Consecutive Losses: " + metrics.getCurrentConsecutiveLosses());
        
        System.out.println("Time Analysis:");
        System.out.println("  Average Trade Duration (hours): " + metrics.getAverageTradeDurationHours());
        System.out.println("  Total Trading Time (hours): " + metrics.getTotalTradingTimeHours());
        System.out.println("  Trading Frequency (trades/day): " + metrics.getTradingFrequency());
        
        System.out.println("Market Analysis:");
        System.out.println("  Initial Price: " + metrics.getInitialPrice());
        System.out.println("  Final Price: " + metrics.getFinalPrice());
        System.out.println("  Market Return: " + metrics.getMarketReturn());
        System.out.println("  Strategy Outperformance: " + metrics.getStrategyOutperformance());
        
        System.out.println("Additional Metrics:");
        System.out.println("  Expectancy: " + metrics.getExpectancy());
        System.out.println("  Kelly Percentage: " + metrics.getKellyPercentage());
    }
}
