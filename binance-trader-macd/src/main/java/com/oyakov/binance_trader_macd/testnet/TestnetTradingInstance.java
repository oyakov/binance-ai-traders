package com.oyakov.binance_trader_macd.testnet;

import lombok.Getter;
import lombok.extern.slf4j.Slf4j;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicBoolean;

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
                // Placeholder for integration with real trading loop.
                // For now we simply sleep and keep the thread alive.
                Thread.sleep(1_000L);
            }
        } catch (InterruptedException ignored) {
            Thread.currentThread().interrupt();
        } finally {
            log.debug("Lifecycle thread for instance {} finished at {}", instanceId, Instant.now());
        }
    }
}
