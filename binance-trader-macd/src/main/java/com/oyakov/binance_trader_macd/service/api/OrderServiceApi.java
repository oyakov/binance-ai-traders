package com.oyakov.binance_trader_macd.service.api;

import com.oyakov.binance_trader_macd.domain.OrderSide;
import com.oyakov.binance_trader_macd.domain.OrderState;
import com.oyakov.binance_trader_macd.exception.OrderCapacityReachedException;
import com.oyakov.binance_trader_macd.model.order.binance.storage.OrderItem;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Optional;

public interface OrderServiceApi {

    @Transactional
    OrderItem createOrderGroup(String symbol, BigDecimal entryPrice, BigDecimal quantity, OrderSide orderSide,
                               BigDecimal stopLossPrice, BigDecimal takeProfitPrice) throws OrderCapacityReachedException;

    @Lock(LockModeType.PESSIMISTIC_READ)
    boolean hasActiveOrder(String symbol);

    void closeOrderWithState(Long orderId, OrderState state);

    @Transactional
    @Lock(LockModeType.PESSIMISTIC_READ)
    Optional<OrderItem> getActiveOrder(String symbol);
}
