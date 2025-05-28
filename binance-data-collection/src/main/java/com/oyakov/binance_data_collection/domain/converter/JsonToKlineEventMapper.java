package com.oyakov.binance_data_collection.domain.converter;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Component
@RequiredArgsConstructor
public class JsonToKlineEventMapper {

    private final ObjectMapper objectMapper;

    public List<KlineEvent> mapJsonToKlineEvents(String json, String symbol, String interval) throws JsonProcessingException {
        List<List<Object>> rawList = objectMapper.readValue(json, new TypeReference<>() {});
        List<KlineEvent> events = new ArrayList<>();
        for (List<Object> row : rawList) {
            events.add(mapToKlineEvent(row, symbol, interval));
        }
        return events;
    }

    private KlineEvent mapToKlineEvent(List<Object> row, String symbol, String interval) {
        return KlineEvent.newBuilder()
                .setEventType("kline")
                .setEventTime(System.currentTimeMillis())
                .setSymbol(symbol)
                .setInterval(interval)
                .setOpenTime(((Number) row.get(0)).longValue())
                .setCloseTime(((Number) row.get(6)).longValue())
                .setOpen(new BigDecimal((String) row.get(1)))
                .setHigh(new BigDecimal((String) row.get(2)))
                .setLow(new BigDecimal((String) row.get(3)))
                .setClose(new BigDecimal((String) row.get(4)))
                .setVolume(new BigDecimal((String) row.get(5)))
                .build();
    }
}
