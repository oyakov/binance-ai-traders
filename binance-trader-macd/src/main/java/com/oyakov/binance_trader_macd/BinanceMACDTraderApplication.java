package com.oyakov.binance_trader_macd;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.elasticsearch.repository.config.EnableElasticsearchRepositories;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
@EnableJpaRepositories(basePackages = "com.oyakov.binance_trader_macd.repository.jpa") // JPA Repositories
@EnableElasticsearchRepositories(basePackages = "com.oyakov.binance_trader_macd.repository.elastic") // Elasticsearch Repositories
public class BinanceMACDTraderApplication {

	public static void main(String[] args) {
		SpringApplication.run(BinanceMACDTraderApplication.class, args);
	}

}
