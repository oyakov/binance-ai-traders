package com.oyakov.binance_trader_macd.testnet;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.Map;

@Data
@Component
@Profile("testnet")
@ConfigurationProperties(prefix = "testnet")
public class TestnetStrategiesProperties {

    private Map<String, StrategyProperties> strategies = new LinkedHashMap<>();

    @Data
    public static class StrategyProperties {
        private String name;
        private String symbol;
        private String timeframe;
        private MacdProperties macdParams = new MacdProperties();
        private StrategyConfig.RiskLevel riskLevel = StrategyConfig.RiskLevel.MEDIUM;
        private BigDecimal positionSize;
        private BigDecimal stopLossPercent;
        private BigDecimal takeProfitPercent;
        private boolean enabled = true;

        public StrategyConfig toStrategyConfig(String id) {
            return StrategyConfig.builder()
                    .id(id)
                    .name(name != null ? name : id)
                    .symbol(symbol)
                    .timeframe(timeframe)
                    .macdParams(macdParams.toMacdParameters())
                    .riskLevel(riskLevel)
                    .positionSize(positionSize)
                    .stopLossPercent(stopLossPercent)
                    .takeProfitPercent(takeProfitPercent)
                    .enabled(enabled)
                    .build();
        }
    }

    @Data
    public static class MacdProperties {
        private int fastPeriod;
        private int slowPeriod;
        private int signalPeriod;

        public StrategyConfig.MacdParameters toMacdParameters() {
            return StrategyConfig.MacdParameters.builder()
                    .fastPeriod(fastPeriod)
                    .slowPeriod(slowPeriod)
                    .signalPeriod(signalPeriod)
                    .build();
        }
    }
}
