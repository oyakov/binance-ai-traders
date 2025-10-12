package com.oyakov.binance_data_storage.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.Map;

/**
 * Service for persisting observability metrics to the database
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class ObservabilityService {

    private final JdbcTemplate jdbcTemplate;

    @Transactional
    public void recordStrategyAnalysis(Map<String, Object> data) {
        String sql = """
            INSERT INTO strategy_analysis_events (
                instance_id, strategy_name, symbol, interval,
                analysis_time, kline_timestamp, kline_close_time,
                current_price, kline_count,
                macd_line, signal_line, histogram, signal_strength,
                signal_detected, signal_reason,
                ema_fast, ema_slow
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;

        jdbcTemplate.update(sql,
            data.get("instance_id"),
            data.get("strategy_name"),
            data.get("symbol"),
            data.get("interval"),
            toTimestamp(data.get("analysis_time")),
            data.get("kline_timestamp"),
            toTimestamp(data.get("kline_close_time")),
            data.get("current_price"),
            data.get("kline_count"),
            data.get("macd_line"),
            data.get("signal_line"),
            data.get("histogram"),
            data.get("signal_strength"),
            data.get("signal_detected"),
            data.get("signal_reason"),
            data.get("ema_fast"),
            data.get("ema_slow")
        );

        log.debug("Recorded strategy analysis for {} {}", data.get("instance_id"), data.get("symbol"));
    }

    @Transactional
    public void recordDecisionLog(Map<String, Object> data) {
        String sql = """
            INSERT INTO trading_decision_logs (
                instance_id, strategy_name, symbol,
                decision_time,
                signal_detected, signal_strength, macd_histogram, current_price,
                trade_allowed, trade_executed,
                has_active_position, position_size_ok, daily_loss_limit_ok, risk_check_passed,
                decision_reason, blocked_reason,
                order_id, executed_price, executed_quantity
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;

        jdbcTemplate.update(sql,
            data.get("instance_id"),
            data.get("strategy_name"),
            data.get("symbol"),
            toTimestamp(data.get("decision_time")),
            data.get("signal_detected"),
            data.get("signal_strength"),
            data.get("macd_histogram"),
            data.get("current_price"),
            data.get("trade_allowed"),
            data.get("trade_executed"),
            data.get("has_active_position"),
            data.get("position_size_ok"),
            data.get("daily_loss_limit_ok"),
            data.get("risk_check_passed"),
            data.get("decision_reason"),
            data.get("blocked_reason"),
            data.get("order_id"),
            data.get("executed_price"),
            data.get("executed_quantity")
        );

        log.debug("Recorded decision log for {} {}", data.get("instance_id"), data.get("symbol"));
    }

    @Transactional
    public void recordPortfolioSnapshot(Map<String, Object> data) {
        String sql = """
            INSERT INTO portfolio_snapshots (
                instance_id, strategy_name,
                snapshot_time,
                total_balance, available_balance, position_value,
                symbol, position_size, position_entry_price, current_market_price, unrealized_pnl,
                total_trades, winning_trades, total_realized_pnl, daily_pnl,
                current_drawdown, max_drawdown
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;

        jdbcTemplate.update(sql,
            data.get("instance_id"),
            data.get("strategy_name"),
            toTimestamp(data.get("snapshot_time")),
            data.get("total_balance"),
            data.get("available_balance"),
            data.get("position_value"),
            data.get("symbol"),
            data.get("position_size"),
            data.get("position_entry_price"),
            data.get("current_market_price"),
            data.get("unrealized_pnl"),
            data.get("total_trades"),
            data.get("winning_trades"),
            data.get("total_realized_pnl"),
            data.get("daily_pnl"),
            data.get("current_drawdown"),
            data.get("max_drawdown")
        );

        log.debug("Recorded portfolio snapshot for {}", data.get("instance_id"));
    }

    private Timestamp toTimestamp(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof LocalDateTime) {
            return Timestamp.valueOf((LocalDateTime) value);
        }
        if (value instanceof String) {
            try {
                return Timestamp.valueOf(LocalDateTime.parse((String) value));
            } catch (Exception e) {
                log.error("Failed to parse timestamp: {}", value, e);
                return null;
            }
        }
        // Handle LinkedHashMap from Jackson deserialization
        if (value instanceof Map) {
            Map<?, ?> map = (Map<?, ?>) value;
            // LocalDateTime comes as a map with year, month, day, hour, minute, second, nano fields
            try {
                int year = (Integer) map.get("year");
                int month = (Integer) map.get("monthValue");
                int day = (Integer) map.get("dayOfMonth");
                int hour = (Integer) map.get("hour");
                int minute = (Integer) map.get("minute");
                int second = (Integer) map.get("second");
                Object nanoObj = map.get("nano");
                int nano = nanoObj != null ? (Integer) nanoObj : 0;
                
                LocalDateTime ldt = LocalDateTime.of(year, month, day, hour, minute, second, nano);
                return Timestamp.valueOf(ldt);
            } catch (Exception e) {
                log.error("Failed to parse timestamp from map: {}", value, e);
                return null;
            }
        }
        log.warn("Unknown timestamp type: {}", value.getClass());
        return null;
    }
}

