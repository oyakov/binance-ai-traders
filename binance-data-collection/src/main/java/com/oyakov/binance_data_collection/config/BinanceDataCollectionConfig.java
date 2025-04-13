package com.oyakov.binance_data_collection.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Data
@Configuration
@ConfigurationProperties(prefix = "binance")
public class BinanceDataCollectionConfig {

    private Rest rest;
    private Websocket websocket;
    private Data data;

    @lombok.Data
    public static class Rest {
        private String baseUrl;
    }

    @lombok.Data
    public static class Websocket {
        private String baseUrl;
        private Boolean autoConnect = true;
    }

    @lombok.Data
    public static class Data {
        private Kline kline;

        @lombok.Data
        public static class Kline {
            private String kafkaTopic;
            private String kafkaConsumerGroup;
            private List<String> intervals;
            private List<String> symbols;
        }
    }
}

