package com.oyakov.binance_trader_macd.service;

import com.oyakov.binance_trader_macd.metrics.MACDMetricsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

/**
 * Scheduled service for automatically updating MACD indicators
 */
@Service
@RequiredArgsConstructor
@Log4j2
@ConditionalOnProperty(name = "binance.trader.macd.scheduler.enabled", havingValue = "true", matchIfMissing = true)
public class MACDSchedulerService {

    private final MACDMetricsService macdMetricsService;

    /**
     * Update all MACD indicators every 5 minutes
     */
    @Scheduled(fixedRate = 300000) // 5 minutes
    public void updateAllIndicators() {
        log.debug("Scheduled update of all MACD indicators");
        try {
            macdMetricsService.updateAllIndicators();
            log.debug("Successfully updated all MACD indicators");
        } catch (Exception e) {
            log.error("Error in scheduled MACD update", e);
        }
    }

    /**
     * Update high-frequency indicators every minute
     */
    @Scheduled(fixedRate = 60000) // 1 minute
    public void updateHighFrequencyIndicators() {
        log.debug("Scheduled update of high-frequency MACD indicators");
        try {
            // Update 5-minute indicators more frequently
            macdMetricsService.updateIndicator("BTCUSDT", "5m");
            macdMetricsService.updateIndicator("ETHUSDT", "5m");
            log.debug("Successfully updated high-frequency MACD indicators");
        } catch (Exception e) {
            log.error("Error in scheduled high-frequency MACD update", e);
        }
    }
}
