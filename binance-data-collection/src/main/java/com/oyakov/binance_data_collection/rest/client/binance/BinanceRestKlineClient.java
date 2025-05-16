package com.oyakov.binance_data_collection.rest.client.binance;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.oyakov.binance_data_collection.domain.kline.KlineStream;
import com.oyakov.binance_data_collection.config.BinanceDataCollectionConfig;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;

@Component
@Log4j2
@RequiredArgsConstructor
public class BinanceRestKlineClient {

    private final BinanceDataCollectionConfig config;
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    public List<KlineEvent> fetchWarmupKlines(KlineStream klineStream, int limit) {
        String symbol = klineStream.fingerprint().symbol().toUpperCase();
        String interval = klineStream.fingerprint().interval();
        String url = UriComponentsBuilder.fromHttpUrl("%s/api/v3/klines".formatted(config.getRest().getBaseUrl()))
                .queryParam("symbol", symbol)
                .queryParam("interval", interval)
                .queryParam("limit", limit)
                .build()
                .toUriString();

        log.info("Fetching warm-up klines from: {}", url);

        try {
            String json = restTemplate.getForObject(url, String.class);
            List<List<Object>> rawList = objectMapper.readValue(json, new TypeReference<>() {});

            List<KlineEvent> events = new ArrayList<>();
            for (List<Object> row : rawList) {
                events.add(mapToKlineEvent(row, symbol, interval));
            }
            return events;
        } catch (Exception e) {
            log.error("Failed to fetch warm-up klines for {}-{}", symbol, interval, e);
            return List.of();
        }
    }

    private KlineEvent mapToKlineEvent(List<Object> row, String symbol, String interval) {
        return KlineEvent.newBuilder()
                .setEventType("kline")
                .setEventTime(System.currentTimeMillis())
                .setSymbol(symbol)
                .setInterval(interval)
                .setOpenTime(((Number) row.get(0)).longValue())
                .setOpen(Double.parseDouble((String) row.get(1)))
                .setHigh(Double.parseDouble((String) row.get(2)))
                .setLow(Double.parseDouble((String) row.get(3)))
                .setClose(Double.parseDouble((String) row.get(4)))
                .setVolume(Double.parseDouble((String) row.get(5)))
                .setCloseTime(((Number) row.get(6)).longValue())
                .build();
    }

}
