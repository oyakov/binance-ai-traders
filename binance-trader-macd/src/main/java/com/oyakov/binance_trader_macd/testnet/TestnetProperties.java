package com.oyakov.binance_trader_macd.testnet;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

@Data
@Component
@Profile("testnet")
@ConfigurationProperties(prefix = "trader.testnet")
public class TestnetProperties {

    private boolean enabled = true;
    private BigDecimal virtualBalance = BigDecimal.valueOf(10_000);
    private BigDecimal maxPositionSize = BigDecimal.valueOf(0.1);
    private StrategyConfig.RiskLevel riskLevel = StrategyConfig.RiskLevel.MEDIUM;
}
