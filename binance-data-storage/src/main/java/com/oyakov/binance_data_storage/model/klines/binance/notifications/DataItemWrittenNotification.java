package com.oyakov.binance_data_storage.model.klines.binance.notifications;

import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineItem;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.context.ApplicationEvent;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class DataItemWrittenNotification<T> extends ApplicationEvent {
    private String eventType;
    private long eventTime;
    private T dataItem;
    private String errorMessage;
    Throwable error;

    public DataItemWrittenNotification(Object source, String eventType, long eventTime, T dataItem, String errorMessage, Throwable error) {
        super(source);
        this.eventType = eventType;
        this.eventTime = eventTime;
        this.dataItem = dataItem;
        this.errorMessage = errorMessage;
        this.error = error;
    }
}
