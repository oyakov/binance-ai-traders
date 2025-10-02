package com.oyakov.binance_trader_macd.config;

import com.oyakov.binance_trader_macd.rest.client.BinanceOrderClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;
import org.springframework.web.client.RestTemplate;

@Slf4j
@Configuration
@Profile("testnet")
@RequiredArgsConstructor
public class TestnetConfig {

    private final RestTemplate restTemplate;
    private final MACDTraderConfig traderConfig;

    @Value("${binance.testnet.api.url:https://testnet.binance.vision}")
    private String testnetApiUrl;

    @Value("${binance.testnet.api.key:}")
    private String testnetApiKey;

    @Value("${binance.testnet.secret.key:}")
    private String testnetSecretKey;

    @Bean
    @Primary
    public BinanceOrderClient testnetOrderClient() {
        MACDTraderConfig.Rest rest = traderConfig.getRest();
        rest.setBaseUrl(testnetApiUrl);
        rest.setApiToken(testnetApiKey);
        rest.setSecretApiToken(testnetSecretKey);
        log.info("Configured Binance testnet client with base URL {}", testnetApiUrl);
        return new BinanceOrderClient(restTemplate, traderConfig);
    }
}
