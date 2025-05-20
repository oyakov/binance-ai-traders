package com.oyakov.binance_trader_macd.rest.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class BinanceOcoOrderResponse {

    private Long orderListId;
    private String contingencyType;
    private String listStatusType;
    private String listOrderStatus;
    private String listClientOrderId;
    private Long transactionTime;
    private String symbol;

    private List<SimpleOrder> orders;

    @JsonProperty("orderReports")
    private List<OrderReport> orderReports;

    @Data
    public static class SimpleOrder {
        private String symbol;
        private Long orderId;
        private String clientOrderId;
    }

    @Data
    public static class OrderReport {
        private String symbol;
        private Long orderId;
        private Long orderListId;
        private String clientOrderId;
        private Long transactTime;
        private BigDecimal price;
        private BigDecimal origQty;
        private BigDecimal executedQty;
        private BigDecimal origQuoteOrderQty;
        private BigDecimal cummulativeQuoteQty;
        private String status;
        private String timeInForce;
        private String type;
        private String side;
        private BigDecimal stopPrice;
        private Long workingTime;
        private BigDecimal icebergQty;
        private String selfTradePreventionMode;
    }
}
