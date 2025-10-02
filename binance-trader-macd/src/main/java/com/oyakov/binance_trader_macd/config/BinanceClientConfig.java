package com.oyakov.binance_trader_macd.config;

import com.oyakov.binance_trader_macd.rest.client.BinanceOrderClient;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

@Configuration
@RequiredArgsConstructor
public class BinanceClientConfig {

    private final RestTemplate restTemplate;
    private final MACDTraderConfig traderConfig;

    @Bean
    @ConditionalOnMissingBean(BinanceOrderClient.class)
    public BinanceOrderClient binanceOrderClient() {
        return new BinanceOrderClient(restTemplate, traderConfig);
    }
}
