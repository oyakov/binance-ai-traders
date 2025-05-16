package com.oyakov.binance_data_storage.model.klines.binance.storage;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Embeddable
public class KlineFingerprint {
    private String symbol;
    private String interval;
    private long openTime;
    private long closeTime;

    public static KlineFingerprint fromKlineEvent(KlineEvent event) {
        return KlineFingerprint.builder()
                .symbol(event.getSymbol())
                .interval(event.getInterval())
                .openTime(event.getOpenTime())
                .closeTime(event.getCloseTime())
                .build();
    }
} 