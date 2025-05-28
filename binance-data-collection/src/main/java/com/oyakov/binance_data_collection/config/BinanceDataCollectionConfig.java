package com.oyakov.binance_data_collection.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Data
@Configuration
@ConfigurationProperties(prefix = "binance")
public class BinanceDataCollectionConfig {

    private Rest rest = new Rest();
    private Websocket websocket = new Websocket();
    private Data data = new Data();

    @lombok.Data
    public static class Rest {
        private String baseUrl;
        private String apiToken;
        private String secretApiToken;
    }

    @lombok.Data
    public static class Websocket {
        private String baseUrl;
        private String klineUrlTemplate;
        private Boolean autoConnect = true;
    }

    @lombok.Data
    public static class Data {
        private Kline kline = new Kline();

        @lombok.Data
        public static class Kline {
            private String kafkaTopic;
            private String kafkaConsumerGroup;
            private Integer warmupKlineCount = 50;
            private List<String> intervals = List.of("15m");
            private List<String> symbols = List.of("btcusdt");
        }
    }
}

