package com.oyakov.binance_trader_macd.testnet;

import com.oyakov.binance_trader_macd.backtest.BinanceHistoricalDataFetcher;
import com.oyakov.binance_trader_macd.domain.signal.MACDSignalAnalyzer;
import com.oyakov.binance_trader_macd.rest.client.BinanceOrderClient;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

@Slf4j
@Service
@Profile("testnet")
@RequiredArgsConstructor
public class TestnetInstanceManager {

    private final StrategyConfigLoader strategyConfigLoader;
    private final TestnetPerformanceMonitor performanceMonitor;
    private final TestnetProperties testnetProperties;
    private final BinanceHistoricalDataFetcher dataFetcher;
    private final MACDSignalAnalyzer macdAnalyzer;
    private final BinanceOrderClient binanceOrderClient;
    private final Map<String, TestnetTradingInstance> instances = new ConcurrentHashMap<>();

    @PostConstruct
    public void startConfiguredInstances() {
        if (!testnetProperties.isEnabled()) {
            log.info("Testnet trading disabled via configuration");
            return;
        }
        strategyConfigLoader.loadEnabledStrategies()
                .forEach(config -> startInstance(config.getId(), config));
    }

    public synchronized void startInstance(String instanceId, StrategyConfig config) {
        instances.computeIfAbsent(instanceId, id -> {
            BigDecimal balance = testnetProperties.getVirtualBalance();
            TestnetTradingInstance instance = new TestnetTradingInstance(id, config, balance, 
                dataFetcher, macdAnalyzer, binanceOrderClient);
            instance.start();
            performanceMonitor.registerInstance(instance);
            return instance;
        });
    }

    public void stopInstance(String instanceId) {
        TestnetTradingInstance instance = instances.remove(instanceId);
        if (instance != null) {
            instance.stop();
            performanceMonitor.unregisterInstance(instanceId);
        }
    }

    public List<InstancePerformance> getAllPerformance() {
        return performanceMonitor.getAllPerformances();
    }

    public Optional<InstancePerformance> findInstancePerformance(String instanceId) {
        return performanceMonitor.getPerformance(instanceId);
    }

    public Collection<TestnetTradingInstance> getActiveInstances() {
        return instances.values().stream()
                .filter(TestnetTradingInstance::isRunning)
                .collect(Collectors.toList());
    }
}
