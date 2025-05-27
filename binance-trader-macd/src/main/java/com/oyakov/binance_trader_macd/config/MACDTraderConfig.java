package com.oyakov.binance_trader_macd.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

@Component
@ConfigurationProperties(prefix = "binance.trader")
@Data
public class MACDTraderConfig {
    private Boolean testOrderModeEnabled = true;
    private BigDecimal stopLossPercentage = BigDecimal.valueOf(0.98);
    private BigDecimal takeProfitPercentage = BigDecimal.valueOf(1.05);
    private BigDecimal orderQuantity = BigDecimal.valueOf(0.05);
}
