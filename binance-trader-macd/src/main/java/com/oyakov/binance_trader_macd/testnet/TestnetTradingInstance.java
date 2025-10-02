package com.oyakov.binance_trader_macd.testnet;

import com.oyakov.binance_trader_macd.backtest.BinanceHistoricalDataFetcher;
import com.oyakov.binance_trader_macd.domain.OrderSide;
import com.oyakov.binance_trader_macd.domain.OrderType;
import com.oyakov.binance_trader_macd.domain.TimeInForce;
import com.oyakov.binance_trader_macd.domain.TradeSignal;
import com.oyakov.binance_trader_macd.domain.signal.MACDSignalAnalyzer;
import com.oyakov.binance_trader_macd.rest.client.BinanceOrderClient;
import com.oyakov.binance_trader_macd.rest.dto.BinanceOrderResponse;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicBoolean;

@Slf4j
@Component
@Profile("testnet")
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
    
    @Autowired
    private BinanceHistoricalDataFetcher dataFetcher;
    
    @Autowired
    private MACDSignalAnalyzer macdAnalyzer;
    
    @Autowired
    private BinanceOrderClient binanceOrderClient;

    public TestnetTradingInstance(String instanceId, StrategyConfig strategyConfig, BigDecimal startingBalance) {
        this.instanceId = instanceId != null ? instanceId : UUID.randomUUID().toString();
        this.strategyConfig = strategyConfig;
        this.performanceTracker = new TestnetPerformanceTracker(this.instanceId, strategyConfig, startingBalance);
        this.executorService = Executors.newSingleThreadExecutor(r -> new Thread(r, "testnet-instance-" + this.instanceId));
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
                    // 1. Fetch real-time market data
                    List<KlineEvent> klines = fetchMarketData();
                    
                    if (klines.size() < macdAnalyzer.getMinDataPointCount()) {
                        log.warn("Insufficient data for MACD calculation: {} (need {})", 
                                klines.size(), macdAnalyzer.getMinDataPointCount());
                        Thread.sleep(60_000L); // Wait 1 minute
                        continue;
                    }
                    
                    // 2. Generate MACD signals
                    TradeSignal signal = macdAnalyzer.tryExtractSignal(klines).orElse(null);
                    
                    // 3. Execute trades based on signal
                    if (signal != null && isTradeAllowed(signal)) {
                        executeTrade(signal);
                    }
                    
                    // 4. Wait before next iteration (check every minute)
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
    
    private List<KlineEvent> fetchMarketData() {
        try {
            // Calculate time range for last 100 klines
            long endTime = Instant.now().toEpochMilli();
            long startTime = endTime - (100 * getIntervalMilliseconds());
            
            // Fetch historical data (this will be real-time data from Binance)
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
    
    private void executeTrade(TradeSignal signal) {
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
            
        } catch (Exception e) {
            log.error("Error executing trade for instance {}: {}", instanceId, e.getMessage(), e);
        }
    }
}
