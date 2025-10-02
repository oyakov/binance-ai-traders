package com.oyakov.binance_trader_macd.testnet;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

@Slf4j
@Service
@Profile("testnet")
@RequiredArgsConstructor
public class TestnetPerformanceMonitor {

    private final Map<String, TestnetTradingInstance> instances = new ConcurrentHashMap<>();
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(2);

    @PostConstruct
    public void startMonitoring() {
        scheduler.scheduleAtFixedRate(this::collectMetrics, 0, 1, TimeUnit.MINUTES);
        scheduler.scheduleAtFixedRate(this::generateReport, 0, 1, TimeUnit.HOURS);
        log.info("Testnet performance monitor started");
    }

    @PreDestroy
    public void shutdown() {
        scheduler.shutdownNow();
        log.info("Testnet performance monitor stopped");
    }

    public void registerInstance(TestnetTradingInstance instance) {
        instances.put(instance.getInstanceId(), instance);
    }

    public void unregisterInstance(String instanceId) {
        instances.remove(instanceId);
    }

    public List<InstancePerformance> getAllPerformances() {
        return instances.values().stream()
                .map(TestnetTradingInstance::getPerformance)
                .collect(Collectors.toList());
    }

    public Optional<InstancePerformance> getPerformance(String instanceId) {
        TestnetTradingInstance instance = instances.get(instanceId);
        return instance == null ? Optional.empty() : Optional.of(instance.getPerformance());
    }

    public TestnetSummary generateSummary() {
        List<InstancePerformance> performances = getAllPerformances();
        int totalInstances = performances.size();
        int activeInstances = (int) performances.stream().filter(InstancePerformance::isActive).count();
        BigDecimal totalProfit = performances.stream()
                .map(InstancePerformance::getTotalProfit)
                .filter(profit -> profit != null)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        String bestPerformer = performances.stream()
                .max(Comparator.comparing(InstancePerformance::getTotalProfit))
                .map(InstancePerformance::getInstanceId)
                .orElse("-");
        return TestnetSummary.builder()
                .totalInstances(totalInstances)
                .activeInstances(activeInstances)
                .totalProfit(totalProfit)
                .bestPerformer(bestPerformer)
                .generatedAt(Instant.now())
                .build();
    }

    public TestnetReport generateTestnetReport() {
        List<InstancePerformance> performances = getAllPerformances();
        String bestPerformer = performances.stream()
                .max(Comparator.comparing(InstancePerformance::getTotalProfit))
                .map(InstancePerformance::getInstanceId)
                .orElse("-");
        return TestnetReport.builder()
                .generatedAt(Instant.now())
                .performances(performances)
                .bestPerformer(bestPerformer)
                .build();
    }

    private void collectMetrics() {
        instances.values().forEach(instance -> instance.getPerformanceTracker().collectMetrics());
    }

    private void generateReport() {
        TestnetReport report = generateTestnetReport();
        log.info("Testnet Performance Report generated at {} with {} instances", report.getGeneratedAt(), report.getPerformances().size());
    }
}
