package com.oyakov.binance_data_storage.model.klines.binance.notifications;

import lombok.Data;
import org.springframework.context.ApplicationEvent;

@Data
public class DataItemWrittenNotification<T> extends ApplicationEvent {
    private String eventType;
    private long eventTime;
    private T dataItem;
    private String errorMessage;
    private Throwable error;

    public DataItemWrittenNotification(Object source, String eventType, long eventTime, T dataItem, String errorMessage, Throwable error) {
        super(source);
        this.eventType = eventType;
        this.eventTime = eventTime;
        this.dataItem = dataItem;
        this.errorMessage = errorMessage;
        this.error = error;
    }

    public DataItemWrittenNotification(Object source) {
        super(source);
    }

    public static <T> Builder<T> builder() {
        return new Builder<>();
    }

    public static class Builder<T> {
        private Object source;
        private String eventType;
        private long eventTime;
        private T dataItem;
        private String errorMessage;
        private Throwable error;

        public Builder<T> source(Object source) {
            this.source = source;
            return this;
        }

        public Builder<T> eventType(String eventType) {
            this.eventType = eventType;
            return this;
        }

        public Builder<T> eventTime(long eventTime) {
            this.eventTime = eventTime;
            return this;
        }

        public Builder<T> dataItem(T dataItem) {
            this.dataItem = dataItem;
            return this;
        }

        public Builder<T> errorMessage(String errorMessage) {
            this.errorMessage = errorMessage;
            return this;
        }

        public Builder<T> error(Throwable error) {
            this.error = error;
            return this;
        }

        public DataItemWrittenNotification<T> build() {
            return new DataItemWrittenNotification<>(source != null ? source : this, eventType, eventTime, dataItem, errorMessage, error);
        }
    }
}
