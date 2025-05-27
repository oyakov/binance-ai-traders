package com.oyakov.binance_trader_macd.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "bookstore.discount")
@Data
public class MACDTraderConfig {
    private Boolean testOrderModeEnabled = true;
}
