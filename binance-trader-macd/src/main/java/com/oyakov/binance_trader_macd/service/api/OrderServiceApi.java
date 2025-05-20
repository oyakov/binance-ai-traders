package com.oyakov.binance_trader_macd.service.api;

import com.oyakov.binance_trader_macd.domain.OrderSide;
import com.oyakov.binance_trader_macd.domain.OrderType;
import com.oyakov.binance_trader_macd.exception.OrderCapacityReachedException;
import com.oyakov.binance_trader_macd.model.order.binance.storage.OrderItem;

import java.math.BigDecimal;
import java.util.Optional;

public interface OrderServiceApi {

    public OrderItem createOrderGroup(String symbol, OrderType orderType, BigDecimal price, BigDecimal quantity, OrderSide orderSide,
                                      BigDecimal stopLoss, BigDecimal takeProfit) throws OrderCapacityReachedException;

    void cancelOrder(Long orderId);

    Optional<OrderItem> getActiveOrder(String symbol);

    void updateOrderStatus(Long orderId, String status);

    //void checkAndUpdateStopLossTakeProfit(String symbol, BigDecimal currentPrice);

    boolean hasActiveOrder(String symbol);
}
