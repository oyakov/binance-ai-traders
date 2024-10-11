package com.oyakov.binance_data_storage;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.elasticsearch.repository.config.EnableElasticsearchRepositories;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
@EnableJpaRepositories(basePackages = "com.oyakov.binance_data_storage.repository.jpa") // JPA Repositories
@EnableElasticsearchRepositories(basePackages = "com.oyakov.binance_data_storage.repository.elastic") // Elasticsearch Repositories
public class BinanceDataStorageApplication {

	public static void main(String[] args) {
		SpringApplication.run(BinanceDataStorageApplication.class, args);
	}

}
