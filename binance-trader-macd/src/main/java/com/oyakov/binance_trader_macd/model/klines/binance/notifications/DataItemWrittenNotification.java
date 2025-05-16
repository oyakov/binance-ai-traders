package com.oyakov.binance_trader_macd.model.klines.binance.notifications;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class DataItemWrittenNotification<T> {
    private String eventType;
    private long eventTime;
    private T dataItem;
    private String errorMessage;
}
