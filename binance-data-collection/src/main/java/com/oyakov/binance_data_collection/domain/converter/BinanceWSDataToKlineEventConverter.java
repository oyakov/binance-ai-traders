package com.oyakov.binance_data_collection.domain.converter;

import com.oyakov.binance_data_collection.model.binance.BinanceWebsocketEventData;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import lombok.RequiredArgsConstructor;
import org.springframework.core.convert.converter.Converter;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class BinanceWSDataToKlineEventConverter implements Converter<BinanceWebsocketEventData, KlineEvent> {
    @Override
    public KlineEvent convert(BinanceWebsocketEventData eventData) {
        return KlineEvent.newBuilder()
                .setEventType(eventData.getEventType())
                .setEventTime(eventData.getEventTime())
                .setSymbol(eventData.getSymbol())
                .setInterval(eventData.getKline().getInterval())
                .setOpenTime(eventData.getKline().getOpenTime())
                .setCloseTime(eventData.getKline().getCloseTime())
                .setOpen(eventData.getKline().getOpen())
                .setHigh(eventData.getKline().getHigh())
                .setLow(eventData.getKline().getLow())
                .setClose(eventData.getKline().getClose())
                .setVolume(eventData.getKline().getVolume())
                .build();
    }
}
