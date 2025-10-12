package com.oyakov.binance_trader_macd.service.api;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.HashMap;
import java.util.Map;

/**
 * Client for storing observability metrics to the data storage service
 */
@Service
@RequiredArgsConstructor
@Log4j2
public class ObservabilityStorageClient {

    private final RestTemplate restTemplate;
    private final com.oyakov.binance_trader_macd.config.MACDTraderConfig config;
    private final MeterRegistry meterRegistry;

    private Counter strategyAnalysisTotal;
    private Counter strategyAnalysisFailed;
    private Counter decisionLogTotal;
    private Counter decisionLogFailed;
    private Counter portfolioSnapshotTotal;
    private Counter portfolioSnapshotFailed;

    @jakarta.annotation.PostConstruct
    void init() {
        strategyAnalysisTotal = Counter.builder("binance.trader.observability.strategy_analysis.total")
                .description("Total strategy analysis events recorded")
                .register(meterRegistry);
        strategyAnalysisFailed = Counter.builder("binance.trader.observability.strategy_analysis.failed")
                .description("Failed strategy analysis events")
                .register(meterRegistry);
        decisionLogTotal = Counter.builder("binance.trader.observability.decision_log.total")
                .description("Total decision logs recorded")
                .register(meterRegistry);
        decisionLogFailed = Counter.builder("binance.trader.observability.decision_log.failed")
                .description("Failed decision logs")
                .register(meterRegistry);
        portfolioSnapshotTotal = Counter.builder("binance.trader.observability.portfolio_snapshot.total")
                .description("Total portfolio snapshots recorded")
                .register(meterRegistry);
        portfolioSnapshotFailed = Counter.builder("binance.trader.observability.portfolio_snapshot.failed")
                .description("Failed portfolio snapshots")
                .register(meterRegistry);
    }

    /**
     * Record a strategy analysis event (MACD calculation)
     */
    public boolean recordStrategyAnalysis(
            String instanceId,
            String strategyName,
            String symbol,
            String interval,
            Instant analysisTime,
            long klineTimestamp,
            Instant klineCloseTime,
            BigDecimal currentPrice,
            int klineCount,
            BigDecimal macdLine,
            BigDecimal signalLine,
            BigDecimal histogram,
            String signalStrength,
            String signalDetected,
            String signalReason) {
        
        String url = config.getData().getStorage().getBaseUrl() + "/api/v1/observability/strategy-analysis";
        
        Map<String, Object> body = new HashMap<>();
        body.put("instance_id", instanceId);
        body.put("strategy_name", strategyName);
        body.put("symbol", symbol);
        body.put("interval", interval);
        body.put("analysis_time", LocalDateTime.ofInstant(analysisTime, ZoneOffset.UTC).toString());
        body.put("kline_timestamp", klineTimestamp);
        body.put("kline_close_time", LocalDateTime.ofInstant(klineCloseTime, ZoneOffset.UTC).toString());
        body.put("current_price", currentPrice);
        body.put("kline_count", klineCount);
        body.put("macd_line", macdLine);
        body.put("signal_line", signalLine);
        body.put("histogram", histogram);
        body.put("signal_strength", signalStrength);
        body.put("signal_detected", signalDetected);
        body.put("signal_reason", signalReason);
        
        try {
            ResponseEntity<Void> resp = restTemplate.postForEntity(url, body, Void.class);
            if (!resp.getStatusCode().is2xxSuccessful()) {
                log.warn("Strategy analysis record non-2xx: {}", resp.getStatusCode());
                strategyAnalysisFailed.increment();
                return false;
            }
            strategyAnalysisTotal.increment();
            log.debug("Recorded strategy analysis for {} {}", instanceId, symbol);
            return true;
        } catch (Exception e) {
            log.error("Failed to record strategy analysis for {} {}", instanceId, symbol, e);
            strategyAnalysisFailed.increment();
            return false;
        }
    }

    /**
     * Record a trading decision log
     */
    public boolean recordDecisionLog(
            String instanceId,
            String strategyName,
            String symbol,
            Instant decisionTime,
            String signalDetected,
            String signalStrength,
            BigDecimal macdHistogram,
            BigDecimal currentPrice,
            boolean tradeAllowed,
            boolean tradeExecuted,
            Boolean hasActivePosition,
            Boolean positionSizeOk,
            Boolean dailyLossLimitOk,
            Boolean riskCheckPassed,
            String decisionReason,
            String blockedReason,
            String orderId,
            BigDecimal executedPrice,
            BigDecimal executedQuantity) {
        
        String url = config.getData().getStorage().getBaseUrl() + "/api/v1/observability/decision-log";
        
        Map<String, Object> body = new HashMap<>();
        body.put("instance_id", instanceId);
        body.put("strategy_name", strategyName);
        body.put("symbol", symbol);
        body.put("decision_time", LocalDateTime.ofInstant(decisionTime, ZoneOffset.UTC).toString());
        body.put("signal_detected", signalDetected);
        body.put("signal_strength", signalStrength);
        body.put("macd_histogram", macdHistogram);
        body.put("current_price", currentPrice);
        body.put("trade_allowed", tradeAllowed);
        body.put("trade_executed", tradeExecuted);
        body.put("has_active_position", hasActivePosition);
        body.put("position_size_ok", positionSizeOk);
        body.put("daily_loss_limit_ok", dailyLossLimitOk);
        body.put("risk_check_passed", riskCheckPassed);
        body.put("decision_reason", decisionReason);
        body.put("blocked_reason", blockedReason);
        body.put("order_id", orderId);
        body.put("executed_price", executedPrice);
        body.put("executed_quantity", executedQuantity);
        
        try {
            ResponseEntity<Void> resp = restTemplate.postForEntity(url, body, Void.class);
            if (!resp.getStatusCode().is2xxSuccessful()) {
                log.warn("Decision log record non-2xx: {}", resp.getStatusCode());
                decisionLogFailed.increment();
                return false;
            }
            decisionLogTotal.increment();
            log.debug("Recorded decision log for {} {}", instanceId, symbol);
            return true;
        } catch (Exception e) {
            log.error("Failed to record decision log for {} {}", instanceId, symbol, e);
            decisionLogFailed.increment();
            return false;
        }
    }

    /**
     * Record a portfolio snapshot
     */
    public boolean recordPortfolioSnapshot(
            String instanceId,
            String strategyName,
            Instant snapshotTime,
            BigDecimal totalBalance,
            BigDecimal availableBalance,
            BigDecimal positionValue,
            String symbol,
            BigDecimal positionSize,
            BigDecimal positionEntryPrice,
            BigDecimal currentMarketPrice,
            BigDecimal unrealizedPnl,
            int totalTrades,
            int winningTrades,
            BigDecimal totalRealizedPnl,
            BigDecimal dailyPnl,
            BigDecimal currentDrawdown,
            BigDecimal maxDrawdown) {
        
        String url = config.getData().getStorage().getBaseUrl() + "/api/v1/observability/portfolio-snapshot";
        
        Map<String, Object> body = new HashMap<>();
        body.put("instance_id", instanceId);
        body.put("strategy_name", strategyName);
        body.put("snapshot_time", LocalDateTime.ofInstant(snapshotTime, ZoneOffset.UTC).toString());
        body.put("total_balance", totalBalance);
        body.put("available_balance", availableBalance);
        body.put("position_value", positionValue);
        body.put("symbol", symbol);
        body.put("position_size", positionSize);
        body.put("position_entry_price", positionEntryPrice);
        body.put("current_market_price", currentMarketPrice);
        body.put("unrealized_pnl", unrealizedPnl);
        body.put("total_trades", totalTrades);
        body.put("winning_trades", winningTrades);
        body.put("total_realized_pnl", totalRealizedPnl);
        body.put("daily_pnl", dailyPnl);
        body.put("current_drawdown", currentDrawdown);
        body.put("max_drawdown", maxDrawdown);
        
        try {
            ResponseEntity<Void> resp = restTemplate.postForEntity(url, body, Void.class);
            if (!resp.getStatusCode().is2xxSuccessful()) {
                log.warn("Portfolio snapshot record non-2xx: {}", resp.getStatusCode());
                portfolioSnapshotFailed.increment();
                return false;
            }
            portfolioSnapshotTotal.increment();
            log.debug("Recorded portfolio snapshot for {}", instanceId);
            return true;
        } catch (Exception e) {
            log.error("Failed to record portfolio snapshot for {}", instanceId, e);
            portfolioSnapshotFailed.increment();
            return false;
        }
    }
}

