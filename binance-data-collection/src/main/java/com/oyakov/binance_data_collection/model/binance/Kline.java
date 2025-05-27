package com.oyakov.binance_data_collection.model.binance;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@AllArgsConstructor
@NoArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class Kline {
    @JsonAlias("s")
    private String symbol;
    @JsonAlias("i")
    private String interval;
    @JsonAlias("t")
    private long openTime;
    @JsonAlias("o")
    private BigDecimal open;
    @JsonAlias("h")
    private BigDecimal high;
    @JsonAlias("l")
    private BigDecimal low;
    @JsonAlias("c")
    private BigDecimal close;
    @JsonAlias("v")
    private BigDecimal volume;
    @JsonAlias("T")
    private long closeTime;
    @JsonAlias("x")
    private boolean closed;
}
