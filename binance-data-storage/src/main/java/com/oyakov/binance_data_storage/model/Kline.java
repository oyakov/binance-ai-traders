package com.oyakov.binance_data_storage.model;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class Kline {
    @JsonAlias("t")
    private long openTime;
    @JsonAlias("o")
    private double open;
    @JsonAlias("h")
    private double high;
    @JsonAlias("l")
    private double low;
    @JsonAlias("c")
    private double close;
    @JsonAlias("v")
    private double volume;
    @JsonAlias("T")
    private long closeTime;
}
