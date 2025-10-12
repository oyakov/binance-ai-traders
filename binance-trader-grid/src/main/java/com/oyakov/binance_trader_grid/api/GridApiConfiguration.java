package com.oyakov.binance_trader_grid.api;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConditionalOnProperty(prefix = "grid.api", name = "enabled", havingValue = "true")
public class GridApiConfiguration {

    @Bean
    public InMemoryGridRepository inMemoryGridRepository() {
        return new InMemoryGridRepository();
    }
}


