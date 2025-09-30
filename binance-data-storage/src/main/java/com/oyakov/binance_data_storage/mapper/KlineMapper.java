package com.oyakov.binance_data_storage.mapper;

import com.oyakov.binance_data_storage.model.klines.binance.commands.KlineCollectedCommand;
import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineFingerprint;
import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineItem;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.time.ZoneOffset;

@Component
public class KlineMapper {
    
    public KlineCollectedCommand toCommand(KlineEvent event) {
        return KlineCollectedCommand.builder()
                .eventType(event.getEventType())
                .eventTime(event.getEventTime())
                .symbol(event.getSymbol())
                .interval(event.getInterval())
                .openTime(event.getOpenTime())
                .closeTime(event.getCloseTime())
                .open(toDouble(event.getOpen()))
                .high(toDouble(event.getHigh()))
                .low(toDouble(event.getLow()))
                .close(toDouble(event.getClose()))
                .volume(toDouble(event.getVolume()))
                .build();
    }

    public KlineItem toItem(KlineEvent event) {
        KlineFingerprint fingerprint = KlineFingerprint.fromKlineEvent(event);

        return KlineItem.builder()
                .timestamp(event.getEventTime())
                .fingerprint(fingerprint)
                .displayTime(LocalDateTime.ofEpochSecond(event.getEventTime() / 1000, 0, ZoneOffset.UTC))
                .open(toDouble(event.getOpen()))
                .high(toDouble(event.getHigh()))
                .low(toDouble(event.getLow()))
                .close(toDouble(event.getClose()))
                .volume(toDouble(event.getVolume()))
                .build();
    }
    
    public KlineItem toItem(KlineCollectedCommand command) {
        KlineFingerprint fingerprint = KlineFingerprint.builder()
                .symbol(command.getSymbol())
                .interval(command.getInterval())
                .openTime(command.getOpenTime())
                .closeTime(command.getEventTime())
                .build();

        return KlineItem.builder()
                .fingerprint(fingerprint)
                .displayTime(LocalDateTime.ofEpochSecond(command.getEventTime() / 1000, 0, ZoneOffset.UTC))
                .open(command.getOpen())
                .high(command.getHigh())
                .low(command.getLow())
                .close(command.getClose())
                .volume(command.getVolume())
                .build();
    }

    private double toDouble(java.math.BigDecimal value) {
        return value != null ? value.doubleValue() : 0.0d;
    }

}