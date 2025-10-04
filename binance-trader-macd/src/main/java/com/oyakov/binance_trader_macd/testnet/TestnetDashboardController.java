package com.oyakov.binance_trader_macd.testnet;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Slf4j
@RestController
@Profile("testnet")
@RequiredArgsConstructor
@RequestMapping("/api/testnet")
public class TestnetDashboardController {

    private final TestnetInstanceManager instanceManager;
    private final TestnetPerformanceMonitor performanceMonitor;
    private final StrategyComparator strategyComparator;

    @GetMapping("/instances")
    public ResponseEntity<List<InstancePerformance>> getAllInstances() {
        return ResponseEntity.ok(instanceManager.getAllPerformance());
    }

    @GetMapping("/instances/{instanceId}")
    public ResponseEntity<InstancePerformance> getInstance(@PathVariable String instanceId) {
        return instanceManager.findInstancePerformance(instanceId)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping("/summary")
    public ResponseEntity<TestnetSummary> getSummary() {
        return ResponseEntity.ok(performanceMonitor.generateSummary());
    }

    @GetMapping("/strategies/ranking")
    public ResponseEntity<StrategyRanking> getStrategyRanking() {
        List<InstancePerformance> performances = performanceMonitor.getAllPerformances();
        StrategyRanking ranking = strategyComparator.compareStrategies(performances);
        return ResponseEntity.ok(ranking);
    }

    @GetMapping("/dashboard")
    public ResponseEntity<String> getDashboard() {
        return ResponseEntity.ok("Testnet Dashboard is working! Trading instances are running.");
    }

    @GetMapping("/health")
    public ResponseEntity<String> getHealth() {
        return ResponseEntity.ok("Testnet controller is healthy");
    }
}
