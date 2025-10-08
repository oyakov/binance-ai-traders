package com.oyakov.binance_trader_macd.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.List;

@Component
@ConfigurationProperties(prefix = "binance")
@Data
public class MACDTraderConfig {

    private Rest rest = new Rest();
    private Websocket websocket = new Websocket();
    private Data data = new Data();
    private Trader trader = new Trader();

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
        private Storage storage = new Storage();

        @lombok.Data
        public static class Kline {
            private String kafkaTopic;
            private String kafkaConsumerGroup;
            private Integer warmupKlineCount = 50;
            private List<String> intervals = List.of("15m");
            private List<String> symbols = List.of("btcusdt");
        }

        @lombok.Data
        public static class Storage {
            private String baseUrl = "http://binance-data-storage-testnet:8081";
        }
    }

    @lombok.Data
    public static class Trader {
        private Boolean testOrderModeEnabled = true;
        private BigDecimal stopLossPercentage = BigDecimal.valueOf(0.98);
        private BigDecimal takeProfitPercentage = BigDecimal.valueOf(1.05);
        private BigDecimal orderQuantity = BigDecimal.valueOf(0.05);
        private Integer slidingWindowSize = 78;
    }
}
