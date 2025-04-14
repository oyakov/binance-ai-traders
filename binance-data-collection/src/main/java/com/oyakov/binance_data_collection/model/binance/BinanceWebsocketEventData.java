package com.oyakov.binance_data_collection.model.binance;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown = true)
public class BinanceWebsocketEventData {

    @JsonAlias("e")
    private String eventType;
    @JsonAlias("E")
    private long eventTime;
    @JsonAlias("s")
    private String symbol;
    @JsonAlias("k")
    private Kline kline;
}