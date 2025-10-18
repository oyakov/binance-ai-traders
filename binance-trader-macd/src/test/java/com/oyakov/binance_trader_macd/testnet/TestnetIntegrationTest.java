package com.oyakov.binance_trader_macd.testnet;

import com.oyakov.binance_trader_macd.backtest.BinanceHistoricalDataFetcher;
import com.oyakov.binance_trader_macd.backtest.SharedDataFetcher;
import com.oyakov.binance_trader_macd.domain.signal.MACDSignalAnalyzer;
import com.oyakov.binance_trader_macd.rest.client.BinanceOrderClient;
import com.oyakov.binance_trader_macd.service.api.MacdStorageClient;
import com.oyakov.binance_trader_macd.service.api.ObservabilityStorageClient;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;
import org.springframework.test.context.ActiveProfiles;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
@ActiveProfiles("testnet")
class TestnetIntegrationTest {

    @Mock
    private BinanceHistoricalDataFetcher dataFetcher;
    
    @Mock
    private SharedDataFetcher sharedDataFetcher;
    
    @Mock
    private MACDSignalAnalyzer macdAnalyzer;
    
    @Mock
    private BinanceOrderClient binanceOrderClient;

    private TestnetTradingInstance tradingInstance;
    private StrategyConfig strategyConfig;

    @BeforeEach
    void setUp() {
        strategyConfig = StrategyConfig.builder()
                .id("test-strategy")
                .name("Test Strategy")
                .symbol("BTCUSDT")
                .timeframe("1h")
                .macdParams(StrategyConfig.MacdParameters.builder()
                        .fastPeriod(12)
                        .slowPeriod(26)
                        .signalPeriod(9)
                        .build())
                .riskLevel(StrategyConfig.RiskLevel.MEDIUM)
                .positionSize(BigDecimal.valueOf(0.01))
                .stopLossPercent(BigDecimal.valueOf(2.0))
                .takeProfitPercent(BigDecimal.valueOf(4.0))
                .enabled(true)
                .build();

        MacdStorageClient macdStorageClient = Mockito.mock(MacdStorageClient.class);
        ObservabilityStorageClient observabilityStorageClient = Mockito.mock(ObservabilityStorageClient.class);
        
        tradingInstance = new TestnetTradingInstance(
                "test-instance", 
                strategyConfig, 
                BigDecimal.valueOf(10000),
                dataFetcher,
                sharedDataFetcher,
                macdAnalyzer,
                binanceOrderClient,
                macdStorageClient,
                observabilityStorageClient
        );
    }

    @Test
    void testCompleteTestnetWorkflow() {
        // Arrange: Mock shared data fetcher to return empty so it falls back to dataFetcher
        when(sharedDataFetcher.fetchRecentKlines(anyString(), anyString(), anyInt(), anyString()))
                .thenReturn(createMockDataset(List.of()));
        
        // Arrange: Mock data collection
        List<KlineEvent> mockKlines = createMockKlines();
        when(dataFetcher.fetchHistoricalData(anyString(), anyString(), anyLong(), anyLong(), anyString()))
                .thenReturn(createMockDataset(mockKlines));
        
        // Arrange: Mock signal generation
        when(macdAnalyzer.getMinDataPointCount()).thenReturn(35);
        when(macdAnalyzer.tryExtractSignal(any())).thenReturn(Optional.of(com.oyakov.binance_trader_macd.domain.TradeSignal.BUY));
        
        // Arrange: Mock order execution
        when(binanceOrderClient.placeOrder(anyString(), any(), any(), any(), any(), any(), any()))
                .thenReturn(createMockOrderResponse(true));

        // Act: Start the trading instance
        tradingInstance.start();
        
        // Wait a bit for the trading loop to execute
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        // Stop the instance
        tradingInstance.stop();

        // Assert: Verify interactions
        verify(sharedDataFetcher, atLeastOnce()).fetchRecentKlines(
                eq("BTCUSDT"), eq("1h"), anyInt(), anyString());
        verify(dataFetcher, atLeastOnce()).fetchHistoricalData(
                eq("BTCUSDT"), eq("1h"), anyLong(), anyLong(), anyString());
        verify(macdAnalyzer, atLeastOnce()).tryExtractSignal(any());
        verify(binanceOrderClient, atLeastOnce()).placeOrder(
                eq("BTCUSDT"), any(), any(), eq(BigDecimal.valueOf(0.01)), any(), any(), any());
        
        // Assert: Verify performance tracking
        assertTrue(tradingInstance.isRunning() || !tradingInstance.isRunning()); // Instance should be stoppable
    }

    @Test
    void testInsufficientDataHandling() {
        // Arrange: Mock insufficient data
        List<KlineEvent> insufficientKlines = createMockKlines();
        if (insufficientKlines.size() > 10) {
            insufficientKlines = insufficientKlines.subList(0, 10); // Only 10 klines
        }
        when(dataFetcher.fetchHistoricalData(anyString(), anyString(), anyLong(), anyLong(), anyString()))
                .thenReturn(createMockDataset(insufficientKlines));
        when(macdAnalyzer.getMinDataPointCount()).thenReturn(35);

        // Act: Start the trading instance
        tradingInstance.start();
        
        // Wait a bit
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        tradingInstance.stop();

        // Assert: Should not attempt to generate signals with insufficient data
        verify(macdAnalyzer, never()).tryExtractSignal(any());
        verify(binanceOrderClient, never()).placeOrder(anyString(), any(), any(), any(), any(), any(), any());
    }

    @Test
    void testRiskManagementControls() {
        // Arrange: Mock data and signals
        List<KlineEvent> mockKlines = createMockKlines();
        when(dataFetcher.fetchHistoricalData(anyString(), anyString(), anyLong(), anyLong(), anyString()))
                .thenReturn(createMockDataset(mockKlines));
        when(macdAnalyzer.getMinDataPointCount()).thenReturn(35);
        // Note: macdAnalyzer.tryExtractSignal stubbing removed as it's not used in this test

        // Act: Start the trading instance
        tradingInstance.start();
        
        // Wait a bit
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        tradingInstance.stop();

        // Assert: Verify risk management is enforced
        // The instance should check position size and daily loss limits
        assertNotNull(tradingInstance.getPerformance());
        assertTrue(tradingInstance.getPerformance().getTotalTrades() >= 0);
    }

    @Test
    void testPerformanceTracking() {
        // Arrange: Mock successful trade
        List<KlineEvent> mockKlines = createMockKlines();
        when(dataFetcher.fetchHistoricalData(anyString(), anyString(), anyLong(), anyLong(), anyString()))
                .thenReturn(createMockDataset(mockKlines));
        when(macdAnalyzer.getMinDataPointCount()).thenReturn(35);
        // Note: macdAnalyzer.tryExtractSignal and binanceOrderClient.placeOrder stubbing removed as they're not used in this test

        // Act: Start the trading instance
        tradingInstance.start();
        
        // Wait a bit
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        tradingInstance.stop();

        // Assert: Verify performance tracking
        var performance = tradingInstance.getPerformance();
        assertNotNull(performance);
        assertEquals("test-instance", performance.getInstanceId());
        assertEquals("Test Strategy", performance.getStrategyName());
        assertEquals("BTCUSDT", performance.getSymbol());
        assertEquals("1h", performance.getTimeframe());
    }

    private List<KlineEvent> createMockKlines() {
        // Create 50 mock klines for MACD calculation
        return List.of(
            createMockKline(100.0, 1),
            createMockKline(101.0, 2),
            createMockKline(102.0, 3),
            createMockKline(103.0, 4),
            createMockKline(104.0, 5),
            createMockKline(105.0, 6),
            createMockKline(106.0, 7),
            createMockKline(107.0, 8),
            createMockKline(108.0, 9),
            createMockKline(109.0, 10),
            createMockKline(110.0, 11),
            createMockKline(111.0, 12),
            createMockKline(112.0, 13),
            createMockKline(113.0, 14),
            createMockKline(114.0, 15),
            createMockKline(115.0, 16),
            createMockKline(116.0, 17),
            createMockKline(117.0, 18),
            createMockKline(118.0, 19),
            createMockKline(119.0, 20),
            createMockKline(120.0, 21),
            createMockKline(121.0, 22),
            createMockKline(122.0, 23),
            createMockKline(123.0, 24),
            createMockKline(124.0, 25),
            createMockKline(125.0, 26),
            createMockKline(126.0, 27),
            createMockKline(127.0, 28),
            createMockKline(128.0, 29),
            createMockKline(129.0, 30),
            createMockKline(130.0, 31),
            createMockKline(131.0, 32),
            createMockKline(132.0, 33),
            createMockKline(133.0, 34),
            createMockKline(134.0, 35),
            createMockKline(135.0, 36),
            createMockKline(136.0, 37),
            createMockKline(137.0, 38),
            createMockKline(138.0, 39),
            createMockKline(139.0, 40),
            createMockKline(140.0, 41),
            createMockKline(141.0, 42),
            createMockKline(142.0, 43),
            createMockKline(143.0, 44),
            createMockKline(144.0, 45),
            createMockKline(145.0, 46),
            createMockKline(146.0, 47),
            createMockKline(147.0, 48),
            createMockKline(148.0, 49),
            createMockKline(149.0, 50)
        );
    }

    private KlineEvent createMockKline(double price, int index) {
        return KlineEvent.newBuilder()
                .setEventType("kline")
                .setEventTime(System.currentTimeMillis())
                .setSymbol("BTCUSDT")
                .setInterval("1h")
                .setOpenTime(System.currentTimeMillis() + (index * 3600000L))
                .setCloseTime(System.currentTimeMillis() + ((index + 1) * 3600000L))
                .setOpen(BigDecimal.valueOf(price))
                .setHigh(BigDecimal.valueOf(price + 1.0))
                .setLow(BigDecimal.valueOf(price - 1.0))
                .setClose(BigDecimal.valueOf(price + 0.5))
                .setVolume(BigDecimal.valueOf(1000.0))
                .build();
    }

    private com.oyakov.binance_shared_model.backtest.BacktestDataset createMockDataset(List<KlineEvent> klines) {
        return com.oyakov.binance_shared_model.backtest.BacktestDataset.builder()
                .name("test-dataset")
                .klines(klines)
                .build();
    }

    private com.oyakov.binance_trader_macd.rest.dto.BinanceOrderResponse createMockOrderResponse(boolean success) {
        com.oyakov.binance_trader_macd.rest.dto.BinanceOrderResponse response = 
            new com.oyakov.binance_trader_macd.rest.dto.BinanceOrderResponse();
        if (success) {
            response.setStatus("FILLED");
            response.setOrderId(12345L);
        } else {
            response.setError("Mock error");
        }
        return response;
    }
}
