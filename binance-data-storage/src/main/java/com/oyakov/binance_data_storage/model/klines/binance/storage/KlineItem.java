package com.oyakov.binance_data_storage.model.klines.binance.storage;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.elasticsearch.annotations.Document;

@Document(indexName = "kline")
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Data
public class KlineItem {

    @Id
    private String id;
    private String symbol;
    private String interval;
    private long openTime;
    private double open;
    private double high;
    private double low;
    private double close;
    private double volume;
    private long closeTime;
    private double quoteAssetVolume;
    private long numberOfTrades;
    private double takerBuyBaseAssetVolume;
    private double takerBuyQuoteAssetVolume;
    private long ignore;
}
