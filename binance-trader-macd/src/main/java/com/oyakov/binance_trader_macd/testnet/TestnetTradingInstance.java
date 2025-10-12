package com.oyakov.binance_trader_macd.testnet;

import com.oyakov.binance_trader_macd.backtest.BinanceHistoricalDataFetcher;
import com.oyakov.binance_trader_macd.backtest.SharedDataFetcher;
import com.oyakov.binance_trader_macd.domain.OrderSide;
import com.oyakov.binance_trader_macd.domain.OrderType;
import com.oyakov.binance_trader_macd.domain.TimeInForce;
import com.oyakov.binance_trader_macd.domain.TradeSignal;
import com.oyakov.binance_trader_macd.domain.signal.MACDSignalAnalyzer;
import com.oyakov.binance_trader_macd.rest.client.BinanceOrderClient;
import com.oyakov.binance_trader_macd.rest.dto.BinanceOrderResponse;
import com.oyakov.binance_trader_macd.service.api.MacdStorageClient;
import com.oyakov.binance_trader_macd.service.api.ObservabilityStorageClient;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

@Slf4j
public class TestnetTradingInstance {

    @Getter
    private final String instanceId;
    @Getter
    private final StrategyConfig strategyConfig;
    @Getter
    private final TestnetPerformanceTracker performanceTracker;
    private final ExecutorService executorService;
    private final AtomicBoolean running = new AtomicBoolean(false);
    private volatile Future<?> executionFuture;
    
    private final BinanceHistoricalDataFetcher dataFetcher;
    private final SharedDataFetcher sharedDataFetcher;
    private final MACDSignalAnalyzer macdAnalyzer;
    private final BinanceOrderClient binanceOrderClient;
    private final MacdStorageClient macdStorageClient;
    private final ObservabilityStorageClient observabilityClient;
    
    // Portfolio snapshot interval (every 5 minutes)
    private final AtomicInteger iterationCount = new AtomicInteger(0);
    private static final int SNAPSHOT_INTERVAL = 5;

    public TestnetTradingInstance(String instanceId, StrategyConfig strategyConfig, BigDecimal startingBalance,
                                  BinanceHistoricalDataFetcher dataFetcher, SharedDataFetcher sharedDataFetcher,
                                  MACDSignalAnalyzer macdAnalyzer, BinanceOrderClient binanceOrderClient,
                                  MacdStorageClient macdStorageClient, ObservabilityStorageClient observabilityClient) {
        this.instanceId = instanceId != null ? instanceId : UUID.randomUUID().toString();
        this.strategyConfig = strategyConfig;
        this.performanceTracker = new TestnetPerformanceTracker(this.instanceId, strategyConfig, startingBalance);
        this.executorService = Executors.newSingleThreadExecutor(r -> new Thread(r, "testnet-instance-" + this.instanceId));
        this.dataFetcher = dataFetcher;
        this.sharedDataFetcher = sharedDataFetcher;
        this.macdAnalyzer = macdAnalyzer;
        this.binanceOrderClient = binanceOrderClient;
        this.macdStorageClient = macdStorageClient;
        this.observabilityClient = observabilityClient;
    }

    public void start() {
        if (running.compareAndSet(false, true)) {
            log.info("Starting testnet trading instance {} for strategy {}", instanceId, strategyConfig.getName());
            performanceTracker.startTracking();
            executionFuture = executorService.submit(this::simulateLifecycle);
        } else {
            log.debug("Instance {} already running", instanceId);
        }
    }

    public void stop() {
        if (running.compareAndSet(true, false)) {
            log.info("Stopping testnet trading instance {}", instanceId);
            performanceTracker.stopTracking();
            if (executionFuture != null) {
                executionFuture.cancel(true);
            }
            executorService.shutdownNow();
        }
    }

    public boolean isRunning() {
        return running.get();
    }

    public InstancePerformance getPerformance() {
        return performanceTracker.getPerformance(isRunning());
    }

    private void simulateLifecycle() {
        try {
            while (running.get()) {
                try {
                    Instant analysisTime = Instant.now();
                    int currentIteration = iterationCount.incrementAndGet();
                    
                    // 1. Fetch real-time market data
                    List<KlineEvent> klines = fetchMarketData();
                    
                    if (klines.isEmpty()) {
                        log.warn("No kline data available for instance {}", instanceId);
                        Thread.sleep(60_000L);
                        continue;
                    }
                    
                    if (klines.size() < macdAnalyzer.getMinDataPointCount()) {
                        log.warn("Insufficient data for MACD calculation: {} (need {})", 
                                klines.size(), macdAnalyzer.getMinDataPointCount());
                        Thread.sleep(60_000L); // Wait 1 minute
                        continue;
                    }
                    
                    // 2. Calculate MACD values
                    MACDCalculationHelper.MACDValues macdValues = MACDCalculationHelper.calculateMACD(klines);
                    
                    if (macdValues == null) {
                        log.warn("Failed to calculate MACD for instance {}", instanceId);
                        Thread.sleep(60_000L);
                        continue;
                    }
                    
                    // 3. Persist MACD to database for historical reference
                    KlineEvent latestKline = klines.get(klines.size() - 1);
                    persistMACDData(latestKline, macdValues);
                    
                    // 4. Generate trade signals
                    TradeSignal signal = macdAnalyzer.tryExtractSignal(klines).orElse(null);
                    
                    // 5. Record strategy analysis event (every iteration)
                    recordStrategyAnalysis(analysisTime, klines, macdValues, signal);
                    
                    // 6. Handle trading decision
                    if (signal != null) {
                        handleTradingDecision(signal, macdValues);
                    }
                    
                    // 7. Record portfolio snapshot (every 5 minutes)
                    if (currentIteration % SNAPSHOT_INTERVAL == 0) {
                        recordPortfolioSnapshot(analysisTime, macdValues.getCurrentPrice());
                    }
                    
                    // 8. Wait before next iteration (check every minute)
                    Thread.sleep(60_000L);
                    
                } catch (Exception e) {
                    log.error("Error in trading lifecycle for instance {}: {}", instanceId, e.getMessage(), e);
                    Thread.sleep(30_000L); // Wait 30 seconds on error
                }
            }
        } catch (InterruptedException ignored) {
            Thread.currentThread().interrupt();
        } finally {
            log.debug("Lifecycle thread for instance {} finished at {}", instanceId, Instant.now());
        }
    }
    
    private void persistMACDData(KlineEvent latestKline, MACDCalculationHelper.MACDValues macdValues) {
        try {
            macdStorageClient.upsertMacd(
                strategyConfig.getSymbol(),
                strategyConfig.getTimeframe(),
                latestKline.getCloseTime(),
                macdValues.getEmaFast() != null ? macdValues.getEmaFast().doubleValue() : null,
                macdValues.getEmaSlow() != null ? macdValues.getEmaSlow().doubleValue() : null,
                macdValues.getMacdLine() != null ? macdValues.getMacdLine().doubleValue() : null,
                macdValues.getSignalLine() != null ? macdValues.getSignalLine().doubleValue() : null,
                macdValues.getHistogram() != null ? macdValues.getHistogram().doubleValue() : null
            );
            log.debug("Persisted MACD data for {} {}", instanceId, strategyConfig.getSymbol());
        } catch (Exception e) {
            log.error("Failed to persist MACD data for {}: {}", instanceId, e.getMessage());
        }
    }
    
    private void recordStrategyAnalysis(Instant analysisTime, List<KlineEvent> klines,
                                       MACDCalculationHelper.MACDValues macdValues, TradeSignal signal) {
        try {
            KlineEvent latestKline = klines.get(klines.size() - 1);
            String signalDetected = signal != null ? signal.name() : null;
            String signalReason = signal != null ? 
                "Signal detected: " + signal.name() + " with histogram=" + macdValues.getHistogram() :
                "No signal - histogram=" + macdValues.getHistogram();
            
            observabilityClient.recordStrategyAnalysis(
                instanceId,
                strategyConfig.getName(),
                strategyConfig.getSymbol(),
                strategyConfig.getTimeframe(),
                analysisTime,
                latestKline.getCloseTime(),
                Instant.ofEpochMilli(latestKline.getCloseTime()),
                macdValues.getCurrentPrice(),
                klines.size(),
                macdValues.getMacdLine(),
                macdValues.getSignalLine(),
                macdValues.getHistogram(),
                macdValues.getSignalStrength(),
                signalDetected,
                signalReason
            );
        } catch (Exception e) {
            log.error("Failed to record strategy analysis for {}: {}", instanceId, e.getMessage());
        }
    }
    
    private void handleTradingDecision(TradeSignal signal, MACDCalculationHelper.MACDValues macdValues) {
        Instant decisionTime = Instant.now();
        boolean tradeAllowed = isTradeAllowed(signal);
        boolean hasActivePosition = performanceTracker.hasActivePosition();
        boolean positionSizeOk = performanceTracker.getCurrentPositionSize().compareTo(strategyConfig.getPositionSize()) <= 0;
        boolean dailyLossLimitOk = performanceTracker.getDailyPnL().compareTo(strategyConfig.getMaxDailyLoss()) >= 0;
        
        String decisionReason;
        String blockedReason = null;
        boolean tradeExecuted = false;
        String orderId = null;
        BigDecimal executedPrice = null;
        BigDecimal executedQuantity = null;
        
        if (tradeAllowed) {
            decisionReason = "Trade allowed - all checks passed";
            // Execute the trade
            BinanceOrderResponse response = executeTrade(signal);
            if (response != null && response.isSuccess()) {
                tradeExecuted = true;
                orderId = response.getOrderId() != null ? response.getOrderId().toString() : null;
                executedPrice = response.getPrice();
                executedQuantity = response.getExecutedQty();
            }
        } else {
            if (hasActivePosition) {
                blockedReason = "Active position exists";
            } else if (!positionSizeOk) {
                blockedReason = "Position size limit exceeded";
            } else if (!dailyLossLimitOk) {
                blockedReason = "Daily loss limit reached";
            } else {
                blockedReason = "Other risk check failed";
            }
            decisionReason = "Trade blocked: " + blockedReason;
        }
        
        // Record decision log
        try {
            observabilityClient.recordDecisionLog(
                instanceId,
                strategyConfig.getName(),
                strategyConfig.getSymbol(),
                decisionTime,
                signal.name(),
                macdValues.getSignalStrength(),
                macdValues.getHistogram(),
                macdValues.getCurrentPrice(),
                tradeAllowed,
                tradeExecuted,
                hasActivePosition,
                positionSizeOk,
                dailyLossLimitOk,
                tradeAllowed,
                decisionReason,
                blockedReason,
                orderId,
                executedPrice,
                executedQuantity
            );
        } catch (Exception e) {
            log.error("Failed to record decision log for {}: {}", instanceId, e.getMessage());
        }
    }
    
    private void recordPortfolioSnapshot(Instant snapshotTime, BigDecimal currentMarketPrice) {
        try {
            InstancePerformance perf = performanceTracker.getPerformance(true);
            
            observabilityClient.recordPortfolioSnapshot(
                instanceId,
                strategyConfig.getName(),
                snapshotTime,
                perf.getCurrentBalance(),
                perf.getCurrentBalance().subtract(performanceTracker.getCurrentPositionSize()),
                performanceTracker.getCurrentPositionSize(),
                strategyConfig.getSymbol(),
                performanceTracker.getCurrentPositionSize(),
                null, // Position entry price (not tracked yet)
                currentMarketPrice,
                null, // Unrealized P&L (not tracked yet)
                perf.getTotalTrades(),
                perf.getWinningTrades(),
                perf.getTotalProfit(),
                performanceTracker.getDailyPnL(),
                null, // Current drawdown (not tracked yet)
                perf.getMaxDrawdown()
            );
        } catch (Exception e) {
            log.error("Failed to record portfolio snapshot for {}: {}", instanceId, e.getMessage());
        }
    }
    
    private List<KlineEvent> fetchMarketData() {
        try {
            // First try to get data from shared database (preferred)
            if (sharedDataFetcher != null) {
                log.debug("Fetching market data from shared database for instance {}", instanceId);
                var dataset = sharedDataFetcher.fetchRecentKlines(
                    strategyConfig.getSymbol().toUpperCase(),
                    strategyConfig.getTimeframe(),
                    100, // Get last 100 klines
                    "testnet-" + instanceId
                );
                
                if (!dataset.getKlines().isEmpty()) {
                    log.debug("Retrieved {} klines from shared database for instance {}", 
                        dataset.getKlines().size(), instanceId);
                    return dataset.getKlines();
                } else {
                    log.warn("No data available in shared database, falling back to direct API for instance {}", instanceId);
                }
            }
            
            // Fallback to direct Binance API if shared data is not available
            log.debug("Fetching market data from Binance API for instance {}", instanceId);
            long endTime = Instant.now().toEpochMilli();
            long startTime = endTime - (100 * getIntervalMilliseconds());
            
            var dataset = dataFetcher.fetchHistoricalData(
                strategyConfig.getSymbol().toUpperCase(),
                strategyConfig.getTimeframe(),
                startTime,
                endTime,
                "testnet-" + instanceId
            );
            
            return dataset.getKlines();
        } catch (Exception e) {
            log.error("Failed to fetch market data for instance {}: {}", instanceId, e.getMessage(), e);
            return List.of();
        }
    }
    
    private long getIntervalMilliseconds() {
        return switch (strategyConfig.getTimeframe()) {
            case "1m" -> 60_000L;
            case "3m" -> 180_000L;
            case "5m" -> 300_000L;
            case "15m" -> 900_000L;
            case "30m" -> 1_800_000L;
            case "1h" -> 3_600_000L;
            case "2h" -> 7_200_000L;
            case "4h" -> 14_400_000L;
            case "6h" -> 21_600_000L;
            case "8h" -> 28_800_000L;
            case "12h" -> 43_200_000L;
            case "1d" -> 86_400_000L;
            case "3d" -> 259_200_000L;
            case "1w" -> 604_800_000L;
            case "1M" -> 2_592_000_000L;
            default -> 3_600_000L; // Default to 1h
        };
    }
    
    private boolean isTradeAllowed(TradeSignal signal) {
        // Check if we already have an active position
        if (performanceTracker.hasActivePosition()) {
            log.debug("Instance {} has active position, skipping trade", instanceId);
            return false;
        }
        
        // Check position size limits
        BigDecimal currentPositionSize = performanceTracker.getCurrentPositionSize();
        if (currentPositionSize.compareTo(strategyConfig.getPositionSize()) > 0) {
            log.warn("Instance {} position size exceeds limit: {}", instanceId, currentPositionSize);
            return false;
        }
        
        // Check daily loss limits
        BigDecimal dailyPnL = performanceTracker.getDailyPnL();
        BigDecimal maxDailyLoss = strategyConfig.getMaxDailyLoss();
        if (dailyPnL.compareTo(maxDailyLoss) < 0) {
            log.warn("Instance {} daily loss limit reached: {}", instanceId, dailyPnL);
            return false;
        }
        
        return true;
    }
    
    private BinanceOrderResponse executeTrade(TradeSignal signal) {
        try {
            // Create order request based on signal
            OrderSide orderSide = signal == TradeSignal.BUY ? 
                OrderSide.BUY : OrderSide.SELL;
            
            BinanceOrderResponse response = binanceOrderClient.placeOrder(
                strategyConfig.getSymbol().toUpperCase(),
                OrderType.MARKET,
                orderSide,
                strategyConfig.getPositionSize(),
                null, // price not needed for market orders
                null, // stop price not needed for market orders
                TimeInForce.GTC
            );
            
            if (response.isSuccess()) {
                // Record the trade
                TestnetTrade trade = TestnetTrade.builder()
                    .instanceId(instanceId)
                    .signal(signal)
                    .orderResponse(response)
                    .timestamp(Instant.now())
                    .build();
                
                performanceTracker.recordTrade(trade);
                log.info("Trade executed successfully for instance {}: {} {} at market price", 
                        instanceId, orderSide, strategyConfig.getPositionSize());
            } else {
                log.error("Failed to execute trade for instance {}: {}", instanceId, response.getError());
            }
            
            return response;
            
        } catch (Exception e) {
            log.error("Error executing trade for instance {}: {}", instanceId, e.getMessage(), e);
            return null;
        }
    }
}
