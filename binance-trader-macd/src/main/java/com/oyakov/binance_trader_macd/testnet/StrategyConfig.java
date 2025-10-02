package com.oyakov.binance_trader_macd.testnet;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StrategyConfig {

    private String id;
    private String name;
    private String symbol;
    private String timeframe;
    private MacdParameters macdParams;
    private RiskLevel riskLevel;
    private BigDecimal positionSize;
    private BigDecimal stopLossPercent;
    private BigDecimal takeProfitPercent;
    private boolean enabled;

    public enum RiskLevel {
        LOW,
        MEDIUM,
        HIGH
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MacdParameters {
        private int fastPeriod;
        private int slowPeriod;
        private int signalPeriod;
    }
}
