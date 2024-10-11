package com.oyakov.binance_data_collection.commands;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class KlineCollectedCommand {
    private String eventType;
    private long eventTime;
    private String symbol;
    private String interval;
    private long openTime;
    private long closeTime;
    private double open;
    private double high;
    private double low;
    private double close;
    private double volume;
}
