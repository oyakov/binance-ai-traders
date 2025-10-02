package com.oyakov.binance_trader_macd.rest.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class BinanceOrderResponse {

    private String symbol;

    @JsonProperty("orderId")
    private Long orderId;

    @JsonProperty("orderListId")
    private Long orderListId;

    private String clientOrderId;

    private Long transactTime;

    private BigDecimal price;

    @JsonProperty("origQty")
    private BigDecimal origQty;

    @JsonProperty("executedQty")
    private BigDecimal executedQty;

    @JsonProperty("origQuoteOrderQty")
    private BigDecimal origQuoteOrderQty;

    @JsonProperty("cummulativeQuoteQty")
    private BigDecimal cummulativeQuoteQty;

    private String status;

    private String timeInForce;

    private String type;

    private String side;

    private Long workingTime;

    private String selfTradePreventionMode;

    private List<Fill> fills;
    
    private String error;

    public boolean isSuccess() {
        return error == null && status != null && "FILLED".equals(status);
    }

    @Data
    public static class Fill {
        private BigDecimal price;
        private BigDecimal qty;
        private BigDecimal commission;
        private String commissionAsset;
        private Long tradeId;
    }
}
