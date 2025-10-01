package com.oyakov.binance_trader_macd.backtest;

import com.oyakov.binance_trader_macd.domain.OrderSide;
import com.oyakov.binance_trader_macd.domain.OrderState;
import com.oyakov.binance_trader_macd.domain.OrderType;
import com.oyakov.binance_trader_macd.domain.TimeInForce;
import com.oyakov.binance_trader_macd.exception.OrderCapacityReachedException;
import com.oyakov.binance_trader_macd.model.order.binance.storage.OrderItem;
import com.oyakov.binance_trader_macd.service.api.OrderServiceApi;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import lombok.Getter;
import lombok.extern.log4j.Log4j2;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicLong;

@Log4j2
public class BacktestOrderService implements OrderServiceApi, BacktestOrderContext {

    private final AtomicLong idSequence = new AtomicLong(1L);
    private final Map<Long, OrderItem> activeOrders = new HashMap<>();
    private final Map<Long, SimulatedTrade> openTrades = new HashMap<>();
    @Getter
    private final List<SimulatedTrade> closedTrades = new ArrayList<>();
    private KlineEvent currentKline;

    @Override
    public void onKline(KlineEvent klineEvent) {
        this.currentKline = klineEvent;
    }

    @Override
    public synchronized OrderItem createOrderGroup(String symbol, BigDecimal entryPrice, BigDecimal quantity,
                                      OrderSide orderSide, BigDecimal stopLossPrice, BigDecimal takeProfitPrice)
            throws OrderCapacityReachedException {
        if (hasActiveOrder(symbol)) {
            log.warn("Active order already present for symbol {}", symbol);
            throw new OrderCapacityReachedException();
        }

        long orderId = idSequence.getAndIncrement();
        long eventTime = currentKline != null ? currentKline.getCloseTime() : System.currentTimeMillis();
        Instant eventInstant = Instant.ofEpochMilli(eventTime);
        OrderItem orderItem = OrderItem.builder()
                .symbol(symbol)
                .orderId(orderId)
                .orderListId(0)
                .clientOrderId("BACKTEST-" + orderId)
                .transactTime(eventTime)
                .displayTransactTime(LocalDateTime.ofInstant(eventInstant, ZoneOffset.UTC))
                .price(entryPrice)
                .origQty(quantity)
                .executedQty(quantity)
                .cummulativeQuoteQty(entryPrice.multiply(quantity))
                .status(OrderState.ACTIVE)
                .timeInForce(TimeInForce.GTC.getValue())
                .type(OrderType.LIMIT)
                .side(orderSide)
                .workingTime(eventTime)
                .displayWorkingTime(LocalDateTime.ofInstant(eventInstant, ZoneOffset.UTC))
                .selfTradePreventionMode("NONE")
                .fills("[]")
                .build();

        activeOrders.put(orderId, orderItem);
        SimulatedTrade trade = SimulatedTrade.builder()
                .orderId(orderId)
                .symbol(symbol)
                .side(orderSide)
                .quantity(quantity)
                .entryPrice(entryPrice)
                .entryTime(eventInstant)
                .build();
        openTrades.put(orderId, trade);
        log.debug("Created simulated order {} for {} {} @ {}", orderId, orderSide, symbol, entryPrice);
        return orderItem;
    }

    @Override
    public synchronized boolean hasActiveOrder(String symbol) {
        return activeOrders.values().stream()
                .anyMatch(order -> order.getSymbol().equalsIgnoreCase(symbol) && order.getStatus() == OrderState.ACTIVE);
    }

    @Override
    public synchronized void closeOrderWithState(Long orderId, OrderState state) {
        OrderItem orderItem = activeOrders.remove(orderId);
        SimulatedTrade trade = openTrades.remove(orderId);
        if (orderItem == null || trade == null) {
            log.warn("Attempted to close unknown simulated order {}", orderId);
            return;
        }

        if (currentKline == null) {
            throw new IllegalStateException("Current kline is not set while closing order " + orderId);
        }

        BigDecimal exitPrice = currentKline.getClose();
        Instant exitTime = Instant.ofEpochMilli(currentKline.getCloseTime());
        BigDecimal priceDiff = exitPrice.subtract(trade.getEntryPrice());
        BigDecimal direction = trade.getSide() == OrderSide.BUY ? BigDecimal.ONE : BigDecimal.valueOf(-1);
        BigDecimal profit = priceDiff.multiply(trade.getQuantity()).multiply(direction);
        BigDecimal denominator = trade.getEntryPrice().multiply(trade.getQuantity());
        BigDecimal returnPct = denominator.compareTo(BigDecimal.ZERO) == 0
                ? BigDecimal.ZERO
                : profit.divide(denominator, 8, RoundingMode.HALF_UP);

        trade.setExitPrice(exitPrice);
        trade.setExitTime(exitTime);
        trade.setExitState(state);
        trade.setProfit(profit);
        trade.setReturnPercentage(returnPct);

        orderItem.setStatus(state);
        closedTrades.add(trade);
        log.debug("Closed simulated order {} with state {} and PnL {}", orderId, state, profit);
    }

    @Override
    public synchronized Optional<OrderItem> getActiveOrder(String symbol) {
        return activeOrders.values().stream()
                .filter(order -> order.getSymbol().equalsIgnoreCase(symbol) && order.getStatus() == OrderState.ACTIVE)
                .findFirst();
    }
}
