package com.oyakov.binance_trader_macd.backtest;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_trader_macd.config.MACDTraderConfig;
import com.oyakov.binance_trader_macd.domain.OrderSide;
import com.oyakov.binance_trader_macd.domain.OrderState;
import com.oyakov.binance_trader_macd.domain.TradeSignal;
import com.oyakov.binance_trader_macd.domain.signal.MACDSignalAnalyzer;
import com.oyakov.binance_trader_macd.exception.OrderCapacityReachedException;
import com.oyakov.binance_trader_macd.model.order.binance.storage.OrderItem;
import com.oyakov.binance_trader_macd.service.api.OrderServiceApi;
import lombok.extern.log4j.Log4j2;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayDeque;
import java.util.Deque;

@Log4j2
public class BacktestTraderEngine {

    private final MACDSignalAnalyzer macdSignalAnalyzer;
    private final OrderServiceApi orderService;
    private final int slidingWindowSize;
    private final BigDecimal takeProfitThreshold;
    private final BigDecimal stopLossThreshold;
    private final BigDecimal quantity;
    private final Deque<KlineEvent> slidingWindow = new ArrayDeque<>();

    public BacktestTraderEngine(MACDSignalAnalyzer macdSignalAnalyzer,
                                OrderServiceApi orderService,
                                MACDTraderConfig.Trader traderConfig) {
        this.macdSignalAnalyzer = macdSignalAnalyzer;
        this.orderService = orderService;
        this.slidingWindowSize = traderConfig.getSlidingWindowSize();
        this.takeProfitThreshold = traderConfig.getTakeProfitPercentage();
        this.stopLossThreshold = traderConfig.getStopLossPercentage();
        this.quantity = traderConfig.getOrderQuantity();
    }

    public void onNewKline(KlineEvent klineEvent) {
        if (orderService instanceof BacktestOrderContext context) {
            context.onKline(klineEvent);
        }
        slidingWindow.addLast(klineEvent);
        while (slidingWindow.size() > slidingWindowSize) {
            slidingWindow.removeFirst();
        }

        if (slidingWindow.size() == slidingWindowSize) {
            processSlidingWindow(klineEvent);
        }
    }

    private void processSlidingWindow(KlineEvent triggerEvent) {
        macdSignalAnalyzer.tryExtractSignal(slidingWindow).ifPresentOrElse(
                signal -> executeTradeSignal(signal, triggerEvent),
                () -> executeKlineUpdate(triggerEvent));
    }

    private void executeKlineUpdate(KlineEvent klineEvent) {
        String symbol = klineEvent.getSymbol();
        BigDecimal currentPrice = klineEvent.getClose();
        orderService.getActiveOrder(symbol)
                .ifPresent(orderItem -> processOrderSLTP(orderItem.getOrderId(), orderItem.getPrice(), currentPrice));
    }

    private void processOrderSLTP(Long orderId, BigDecimal entryPrice, BigDecimal currentPrice) {
        BigDecimal ratio = currentPrice.divide(entryPrice, RoundingMode.HALF_UP);
        if (ratio.compareTo(takeProfitThreshold) > 0) {
            orderService.closeOrderWithState(orderId, OrderState.CLOSED_TP);
        } else if (ratio.compareTo(stopLossThreshold) < 0) {
            orderService.closeOrderWithState(orderId, OrderState.CLOSED_SL);
        }
    }

    private void processTradeSignalUpdate(Long orderId, OrderSide orderSide, OrderSide signalSide) {
        if (orderSide.equals(signalSide)) {
            return;
        }
        orderService.closeOrderWithState(orderId, OrderState.CLOSED_INVERTED_SIGNAL);
    }

    private void executeTradeSignal(TradeSignal signal, KlineEvent klineEvent) {
        String symbol = klineEvent.getSymbol();
        BigDecimal currentPrice = klineEvent.getClose();
        orderService.getActiveOrder(symbol).ifPresentOrElse(orderItem -> {
                    processOrderSLTP(orderItem.getOrderId(), orderItem.getPrice(), currentPrice);
                    processTradeSignalUpdate(orderItem.getOrderId(), orderItem.getSide(), OrderSide.of(signal));
                },
                () -> createOrder(signal, symbol, currentPrice));
    }

    private void createOrder(TradeSignal signal, String symbol, BigDecimal currentPrice) {
        BigDecimal stopLossPrice = currentPrice.multiply(stopLossThreshold)
                .setScale(currentPrice.scale(), RoundingMode.HALF_UP);
        BigDecimal takeProfitPrice = currentPrice.multiply(takeProfitThreshold)
                .setScale(currentPrice.scale(), RoundingMode.HALF_UP);
        try {
            OrderItem orderItem = orderService.createOrderGroup(
                    symbol,
                    currentPrice,
                    quantity,
                    OrderSide.of(signal),
                    stopLossPrice,
                    takeProfitPrice);
            log.debug("Created simulated order {}", orderItem);
        } catch (OrderCapacityReachedException e) {
            log.warn("Order capacity reached for symbol {}", symbol, e);
        }
    }
}
