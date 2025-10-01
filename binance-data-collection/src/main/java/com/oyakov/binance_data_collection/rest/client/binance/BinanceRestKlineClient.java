package com.oyakov.binance_data_collection.rest.client.binance;

import com.oyakov.binance_data_collection.config.BinanceDataCollectionConfig;
import com.oyakov.binance_data_collection.domain.converter.JsonToKlineEventMapper;
import com.oyakov.binance_data_collection.domain.kline.KlineStream;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.List;

@Component
@Log4j2
@RequiredArgsConstructor
public class BinanceRestKlineClient {

    private final BinanceDataCollectionConfig config;
    private final RestTemplate restTemplate;
    private final JsonToKlineEventMapper mapper;

    public List<KlineEvent> fetchWarmupKlines(KlineStream klineStream, int limit) {
        String symbol = klineStream.fingerprint().symbol().toUpperCase();
        String interval = klineStream.fingerprint().interval();
        String url = UriComponentsBuilder.fromHttpUrl(config.getRest().getBaseUrl())
                .path("/api/v3/klines")
                .queryParam("symbol", symbol)
                .queryParam("interval", interval)
                .queryParam("limit", limit)
                .encode()
                .build()
                .toUriString();

        log.info("Fetching warm-up klines from: {}", url);
        try {
            String json = restTemplate.getForObject(url, String.class);
            List<KlineEvent> events = mapper.mapJsonToKlineEvents(json, symbol, interval);
            log.debug("{} warmup klines received from {}", events.size(), url);
            return events;
        } catch (Exception e) {
            log.error("Failed to fetch warm-up klines for {}-{}", symbol, interval, e);
            return List.of();
        }
    }

    public List<KlineEvent> fetchHistoricalKlines(String symbol,
                                                  String interval,
                                                  Integer limit,
                                                  Long startTime,
                                                  Long endTime) {
        String upperSymbol = symbol.toUpperCase();
        UriComponentsBuilder builder = UriComponentsBuilder.fromHttpUrl(config.getRest().getBaseUrl())
                .path("/api/v3/klines")
                .queryParam("symbol", upperSymbol)
                .queryParam("interval", interval);
        if (limit != null) {
            builder.queryParam("limit", limit);
        }
        if (startTime != null) {
            builder.queryParam("startTime", startTime);
        }
        if (endTime != null) {
            builder.queryParam("endTime", endTime);
        }

        String url = builder.encode().build().toUriString();
        log.info("Fetching historical klines from {}", url);
        try {
            String json = restTemplate.getForObject(url, String.class);
            return mapper.mapJsonToKlineEvents(json, upperSymbol, interval);
        } catch (Exception e) {
            log.error("Failed to fetch historical klines for {}-{}", upperSymbol, interval, e);
            return List.of();
        }
    }
}
