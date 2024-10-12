package com.oyakov.binance_data_storage.model.klines.binance.notifications;

import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineItem;
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
