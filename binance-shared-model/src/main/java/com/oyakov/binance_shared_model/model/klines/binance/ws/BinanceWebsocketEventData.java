package com.oyakov.binance_shared_model.model.klines.binance.ws;

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

    private String id;
    @JsonAlias("e")
    private String eventType;
    @JsonAlias("E")
    private long eventTime;
    @JsonAlias("s")
    private String symbol;
    @JsonAlias("k")
    private Kline kline;
}