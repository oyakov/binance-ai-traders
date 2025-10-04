# M1 - Testnet Launch Implementation Plan

## Overview

This document provides a detailed implementation plan for M1: Testnet Launch Alpha Testing. The goal is to deploy multiple trading instances on Binance Testnet to validate strategy profitability and determine the winning configuration.

## Phase 1: Infrastructure Setup (Week 1)

### 1.1 Binance Testnet Integration

#### Testnet Configuration
```java
// src/main/java/com/oyakov/binance_trader_macd/config/TestnetConfig.java
@Configuration
@Profile("testnet")
public class TestnetConfig {
    
    @Value("${binance.testnet.api.url:https://testnet.binance.vision}")
    private String testnetApiUrl;
    
    @Value("${binance.testnet.api.key}")
    private String testnetApiKey;
    
    @Value("${binance.testnet.secret.key}")
    private String testnetSecretKey;
    
    @Bean
    @Primary
    public BinanceOrderClient testnetOrderClient() {
        return new BinanceOrderClient(testnetApiUrl, testnetApiKey, testnetSecretKey);
    }
}
```

#### Testnet Properties
```yaml
# src/main/resources/application-testnet.yml
spring:
  profiles:
    active: testnet

binance:
  testnet:
    api:
      url: https://testnet.binance.vision
      key: ${TESTNET_API_KEY}
      secret: ${TESTNET_SECRET_KEY}
    enabled: true

trader:
  testnet:
    enabled: true
    virtual_balance: 10000
    max_position_size: 0.1
    risk_level: medium
```

### 1.2 Multi-Instance Architecture

#### Instance Manager
```java
// src/main/java/com/oyakov/binance_trader_macd/testnet/TestnetInstanceManager.java
@Service
public class TestnetInstanceManager {
    
    private final Map<String, TestnetTradingInstance> instances = new ConcurrentHashMap<>();
    private final TestnetPerformanceMonitor performanceMonitor;
    
    public void startInstance(String instanceId, StrategyConfig config) {
        TestnetTradingInstance instance = new TestnetTradingInstance(instanceId, config);
        instances.put(instanceId, instance);
        instance.start();
        performanceMonitor.registerInstance(instanceId);
    }
    
    public void stopInstance(String instanceId) {
        TestnetTradingInstance instance = instances.get(instanceId);
        if (instance != null) {
            instance.stop();
            instances.remove(instanceId);
        }
    }
    
    public List<InstancePerformance> getAllPerformance() {
        return instances.values().stream()
            .map(TestnetTradingInstance::getPerformance)
            .collect(Collectors.toList());
    }
}
```

#### Trading Instance
```java
// src/main/java/com/oyakov/binance_trader_macd/testnet/TestnetTradingInstance.java
@Component
public class TestnetTradingInstance {
    
    private final String instanceId;
    private final StrategyConfig config;
    private final TraderService traderService;
    private final TestnetPerformanceTracker tracker;
    
    public TestnetTradingInstance(String instanceId, StrategyConfig config) {
        this.instanceId = instanceId;
        this.config = config;
        this.tracker = new TestnetPerformanceTracker(instanceId);
    }
    
    public void start() {
        // Initialize trading with testnet configuration
        traderService.initialize(config);
        tracker.startTracking();
        log.info("Started testnet instance: {} with strategy: {}", instanceId, config.getName());
    }
    
    public void stop() {
        traderService.shutdown();
        tracker.stopTracking();
        log.info("Stopped testnet instance: {}", instanceId);
    }
    
    public InstancePerformance getPerformance() {
        return tracker.getPerformance();
    }
}
```

### 1.3 Strategy Configuration System

#### Strategy Config
```java
// src/main/java/com/oyakov/binance_trader_macd/testnet/StrategyConfig.java
@Data
@Builder
public class StrategyConfig {
    private String name;
    private String symbol;
    private String timeframe;
    private MACDParameters macdParams;
    private RiskLevel riskLevel;
    private BigDecimal positionSize;
    private BigDecimal stopLossPercent;
    private BigDecimal takeProfitPercent;
    private boolean enabled;
    
    public enum RiskLevel {
        LOW, MEDIUM, HIGH
    }
}
```

#### Strategy Profiles
```yaml
# src/main/resources/testnet-strategies.yml
testnet:
  strategies:
    conservative-btc:
      name: "Conservative BTC Strategy"
      symbol: BTCUSDT
      timeframe: 4h
      macd_params:
        fast_period: 12
        slow_period: 26
        signal_period: 9
      risk_level: LOW
      position_size: 0.01
      stop_loss_percent: 2.0
      take_profit_percent: 4.0
      enabled: true
      
    aggressive-eth:
      name: "Aggressive ETH Strategy"
      symbol: ETHUSDT
      timeframe: 1h
      macd_params:
        fast_period: 3
        slow_period: 7
        signal_period: 3
      risk_level: HIGH
      position_size: 0.05
      stop_loss_percent: 3.0
      take_profit_percent: 6.0
      enabled: true
      
    balanced-ada:
      name: "Balanced ADA Strategy"
      symbol: ADAUSDT
      timeframe: 1d
      macd_params:
        fast_period: 7
        slow_period: 14
        signal_period: 7
      risk_level: MEDIUM
      position_size: 0.02
      stop_loss_percent: 2.5
      take_profit_percent: 5.0
      enabled: true
```

## Phase 2: Multi-Strategy Deployment (Week 2)

### 2.1 Performance Monitoring

#### Performance Tracker
```java
// src/main/java/com/oyakov/binance_trader_macd/testnet/TestnetPerformanceTracker.java
@Component
public class TestnetPerformanceTracker {
    
    private final String instanceId;
    private final List<Trade> trades = new ArrayList<>();
    private final AtomicReference<BigDecimal> currentBalance = new AtomicReference<>();
    private final AtomicReference<BigDecimal> maxDrawdown = new AtomicReference<>();
    private final AtomicInteger totalTrades = new AtomicInteger(0);
    private final AtomicInteger winningTrades = new AtomicInteger(0);
    
    public void recordTrade(Trade trade) {
        trades.add(trade);
        totalTrades.incrementAndGet();
        if (trade.getProfit().compareTo(BigDecimal.ZERO) > 0) {
            winningTrades.incrementAndGet();
        }
        updateDrawdown();
    }
    
    public InstancePerformance getPerformance() {
        return InstancePerformance.builder()
            .instanceId(instanceId)
            .totalTrades(totalTrades.get())
            .winningTrades(winningTrades.get())
            .winRate(calculateWinRate())
            .totalProfit(calculateTotalProfit())
            .maxDrawdown(maxDrawdown.get())
            .sharpeRatio(calculateSharpeRatio())
            .build();
    }
}
```

#### Performance Monitor
```java
// src/main/java/com/oyakov/binance_trader_macd/testnet/TestnetPerformanceMonitor.java
@Service
public class TestnetPerformanceMonitor {
    
    private final Map<String, TestnetPerformanceTracker> trackers = new ConcurrentHashMap<>();
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(2);
    
    @PostConstruct
    public void startMonitoring() {
        scheduler.scheduleAtFixedRate(this::collectMetrics, 0, 1, TimeUnit.MINUTES);
        scheduler.scheduleAtFixedRate(this::generateReport, 0, 1, TimeUnit.HOURS);
    }
    
    public void registerInstance(String instanceId) {
        trackers.put(instanceId, new TestnetPerformanceTracker(instanceId));
    }
    
    private void collectMetrics() {
        trackers.values().forEach(TestnetPerformanceTracker::collectMetrics);
    }
    
    private void generateReport() {
        TestnetReport report = generateTestnetReport();
        log.info("Testnet Performance Report: {}", report);
        // Send to monitoring system
    }
}
```

### 2.2 Monitoring Dashboard

#### Dashboard Controller
```java
// src/main/java/com/oyakov/binance_trader_macd/testnet/TestnetDashboardController.java
@RestController
@RequestMapping("/api/testnet")
public class TestnetDashboardController {
    
    private final TestnetInstanceManager instanceManager;
    private final TestnetPerformanceMonitor performanceMonitor;
    
    @GetMapping("/instances")
    public ResponseEntity<List<InstancePerformance>> getAllInstances() {
        List<InstancePerformance> performances = instanceManager.getAllPerformance();
        return ResponseEntity.ok(performances);
    }
    
    @GetMapping("/instances/{instanceId}")
    public ResponseEntity<InstancePerformance> getInstance(@PathVariable String instanceId) {
        InstancePerformance performance = instanceManager.getInstancePerformance(instanceId);
        return ResponseEntity.ok(performance);
    }
    
    @GetMapping("/summary")
    public ResponseEntity<TestnetSummary> getSummary() {
        TestnetSummary summary = performanceMonitor.generateSummary();
        return ResponseEntity.ok(summary);
    }
}
```

#### Dashboard Frontend
```html
<!-- src/main/resources/static/testnet-dashboard.html -->
<!DOCTYPE html>
<html>
<head>
    <title>Testnet Trading Dashboard</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <div class="dashboard">
        <h1>Testnet Trading Performance</h1>
        
        <div class="summary-cards">
            <div class="card">
                <h3>Total Instances</h3>
                <span id="total-instances">0</span>
            </div>
            <div class="card">
                <h3>Active Instances</h3>
                <span id="active-instances">0</span>
            </div>
            <div class="card">
                <h3>Best Performer</h3>
                <span id="best-performer">-</span>
            </div>
        </div>
        
        <div class="performance-chart">
            <canvas id="performanceChart"></canvas>
        </div>
        
        <div class="instances-table">
            <table id="instancesTable">
                <thead>
                    <tr>
                        <th>Instance ID</th>
                        <th>Strategy</th>
                        <th>Symbol</th>
                        <th>Total Trades</th>
                        <th>Win Rate</th>
                        <th>Total Profit</th>
                        <th>Sharpe Ratio</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>
    
    <script>
        // Dashboard JavaScript implementation
        setInterval(updateDashboard, 5000);
        
        function updateDashboard() {
            fetch('/api/testnet/summary')
                .then(response => response.json())
                .then(data => {
                    document.getElementById('total-instances').textContent = data.totalInstances;
                    document.getElementById('active-instances').textContent = data.activeInstances;
                    document.getElementById('best-performer').textContent = data.bestPerformer;
                });
        }
    </script>
</body>
</html>
```

## Phase 3: Extended Validation (Week 3-4)

### 3.1 Automated Testing

#### Testnet Test Suite
```java
// src/test/java/com/oyakov/binance_trader_macd/testnet/TestnetValidationTest.java
@SpringBootTest
@TestPropertySource(properties = {"spring.profiles.active=testnet"})
class TestnetValidationTest {
    
    @Autowired
    private TestnetInstanceManager instanceManager;
    
    @Test
    void testMultipleInstancesRunning() {
        // Start multiple instances with different configurations
        List<StrategyConfig> configs = loadTestnetStrategies();
        
        for (StrategyConfig config : configs) {
            String instanceId = "test-" + config.getName().toLowerCase();
            instanceManager.startInstance(instanceId, config);
        }
        
        // Wait for instances to run for 24 hours
        Thread.sleep(24 * 60 * 60 * 1000);
        
        // Validate performance
        List<InstancePerformance> performances = instanceManager.getAllPerformance();
        assertThat(performances).hasSize(configs.size());
        
        // Check that at least 50% of instances are profitable
        long profitableInstances = performances.stream()
            .filter(p -> p.getTotalProfit().compareTo(BigDecimal.ZERO) > 0)
            .count();
        
        assertThat(profitableInstances).isGreaterThanOrEqualTo(configs.size() / 2);
    }
}
```

### 3.2 Performance Analysis

#### Strategy Comparison
```java
// src/main/java/com/oyakov/binance_trader_macd/testnet/StrategyComparator.java
@Service
public class StrategyComparator {
    
    public StrategyRanking compareStrategies(List<InstancePerformance> performances) {
        return performances.stream()
            .collect(Collectors.groupingBy(InstancePerformance::getStrategyName))
            .entrySet().stream()
            .map(entry -> StrategyPerformance.builder()
                .strategyName(entry.getKey())
                .averageProfit(calculateAverageProfit(entry.getValue()))
                .averageSharpeRatio(calculateAverageSharpeRatio(entry.getValue()))
                .averageWinRate(calculateAverageWinRate(entry.getValue()))
                .consistency(calculateConsistency(entry.getValue()))
                .build())
            .sorted(Comparator.comparing(StrategyPerformance::getAverageProfit).reversed())
            .collect(Collectors.toList());
    }
}
```

## Implementation Timeline

### Week 1: Infrastructure Setup
- [ ] Day 1-2: Set up Binance Testnet integration
- [ ] Day 3-4: Implement multi-instance architecture
- [ ] Day 5-7: Create monitoring dashboard and performance tracking

### Week 2: Multi-Strategy Deployment
- [ ] Day 1-2: Deploy 5-10 trading instances with different configurations
- [ ] Day 3-4: Implement real-time performance monitoring
- [ ] Day 5-7: Set up automated reporting and alerting

### Week 3-4: Extended Validation
- [ ] Week 3: Run continuous testing and collect performance data
- [ ] Week 4: Analyze results and identify winning strategies

## Success Criteria

### Technical Criteria
- [ ] All instances running stable for 2+ weeks
- [ ] 99%+ uptime across all instances
- [ ] Real-time monitoring and alerting working
- [ ] Performance data collection complete

### Performance Criteria
- [ ] At least 3 strategies showing consistent profitability
- [ ] Risk management systems validated
- [ ] Performance metrics meeting backtesting expectations
- [ ] Strategy consistency validated across different market conditions

### Deliverables
- [ ] Testnet deployment infrastructure
- [ ] Multi-instance management system
- [ ] Performance monitoring dashboard
- [ ] Strategy comparison framework
- [ ] Comprehensive testnet validation report

## Risk Mitigation

### Technical Risks
- **API Rate Limits**: Implement proper rate limiting and request queuing
- **Instance Failures**: Automatic restart and recovery mechanisms
- **Data Loss**: Comprehensive logging and backup systems

### Performance Risks
- **Strategy Overfitting**: Test across multiple market conditions
- **Parameter Drift**: Monitor and alert on performance degradation
- **Market Changes**: Adaptive risk management and strategy switching

## Next Steps

After successful completion of M1, proceed to M2 (Low-Budget Production Launch) with the winning strategy identified from testnet validation.

---

**Document Version**: 1.0  
**Last Updated**: 2025-10-02  
**Next Review**: Weekly during implementation
