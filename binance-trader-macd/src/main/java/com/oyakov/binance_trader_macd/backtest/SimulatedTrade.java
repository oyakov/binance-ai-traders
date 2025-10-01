package com.oyakov.binance_trader_macd.backtest;

import com.oyakov.binance_trader_macd.domain.OrderSide;
import com.oyakov.binance_trader_macd.domain.OrderState;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.Instant;

@Data
@Builder
public class SimulatedTrade {

    private long orderId;
    private String symbol;
    private OrderSide side;
    private BigDecimal quantity;
    private BigDecimal entryPrice;
    private Instant entryTime;
    private BigDecimal exitPrice;
    private Instant exitTime;
    private OrderState exitState;
    private BigDecimal profit;
    private BigDecimal returnPercentage;
}
