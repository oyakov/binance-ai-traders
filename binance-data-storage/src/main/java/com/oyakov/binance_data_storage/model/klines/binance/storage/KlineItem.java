package com.oyakov.binance_data_storage.model.klines.binance.storage;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.elasticsearch.annotations.Document;
import org.springframework.data.elasticsearch.annotations.Field;
import org.springframework.data.elasticsearch.annotations.FieldType;

import java.time.LocalDateTime;

@Entity
@Document(indexName = "kline")
@Table(name = "kline")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class KlineItem {

    @Id
    @Field(type = FieldType.Keyword)
    private String id; // Elasticsearch doc ID

    @Embedded
    private KlineFingerprint fingerprint;

    private long timestamp;
    private LocalDateTime displayTime;
    private double open;
    private double high;
    private double low;
    private double close;
    private double volume;

    @PrePersist
    @PreUpdate
    public void updateFingerprint() {
        if (fingerprint == null) {
            fingerprint = KlineFingerprint.builder()
                    .symbol(fingerprint.getSymbol())
                    .interval(fingerprint.getInterval())
                    .closeTime(fingerprint.getCloseTime())
                    .openTime(fingerprint.getOpenTime())
                    .build();
        }

        if (fingerprint != null) {
            this.id = "%s-%s-%d".formatted(
                    fingerprint.getSymbol(),
                    fingerprint.getInterval(),
                    fingerprint.getOpenTime()
            );
        }
    }

    // Convenience getters that delegate to fingerprint
    public String getSymbol() {
        return fingerprint != null ? fingerprint.getSymbol() : null;
    }

    public String getInterval() {
        return fingerprint != null ? fingerprint.getInterval() : null;
    }

    public long getCloseTime() { return fingerprint != null ? fingerprint.getCloseTime() : 0; }

    public long getOpenTime() {
        return fingerprint != null ? fingerprint.getOpenTime() : 0;
    }
}
