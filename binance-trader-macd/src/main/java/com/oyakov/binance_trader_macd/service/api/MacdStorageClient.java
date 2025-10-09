package com.oyakov.binance_trader_macd.service.api;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Log4j2
public class MacdStorageClient {

    private final RestTemplate restTemplate;
    private final com.oyakov.binance_trader_macd.config.MACDTraderConfig config;
    private final MeterRegistry meterRegistry;

    private Counter macdUpsertsTotal;
    private Counter macdUpsertsFailedTotal;

    @jakarta.annotation.PostConstruct
    void init() {
        macdUpsertsTotal = Counter.builder("binance.trader.macd.upserts")
                .description("Total MACD upserts attempted")
                .register(meterRegistry);
        macdUpsertsFailedTotal = Counter.builder("binance.trader.macd.upserts.failed")
                .description("Total MACD upserts failed")
                .register(meterRegistry);
    }

    public boolean upsertMacd(String symbol,
                           String interval,
                           long timestamp,
                           Double emaFast,
                           Double emaSlow,
                           Double macd,
                           Double signal,
                           Double histogram) {
        String url = config.getData().getStorage().getBaseUrl() + "/api/v1/macd";
        LocalDateTime displayTime = LocalDateTime.ofInstant(Instant.ofEpochMilli(timestamp), ZoneOffset.UTC);
        Map<String, Object> body = new HashMap<>();
        body.put("symbol", symbol);
        body.put("interval", interval);
        body.put("timestamp", timestamp);
        body.put("display_time", displayTime);
        body.put("collection_time", LocalDateTime.now(ZoneOffset.UTC));
        body.put("ema_fast", emaFast);
        body.put("ema_slow", emaSlow);
        body.put("macd", macd);
        body.put("signal", signal);
        body.put("histogram", histogram);
        try {
            ResponseEntity<Void> resp = restTemplate.postForEntity(url, body, Void.class);
            if (!resp.getStatusCode().is2xxSuccessful()) {
                log.warn("MACD upsert non-2xx: {}", resp.getStatusCode());
                macdUpsertsFailedTotal.increment();
                return false;
            }
            macdUpsertsTotal.increment();
            return true;
        } catch (Exception e) {
            log.error("Failed to upsert MACD to storage for {} {} ts {}", symbol, interval, timestamp, e);
            macdUpsertsFailedTotal.increment();
            return false;
        }
    }
}


