package com.oyakov.binance_data_storage.model.klines.binance.notifications;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class KlineWrittenNotification {
    private String eventType;
    private long eventTime;
    private String symbol;
    private String interval;
}
