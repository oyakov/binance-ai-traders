package com.oyakov.binance_trader_macd.service.impl;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_trader_macd.config.MACDTraderConfig;
import com.oyakov.binance_trader_macd.domain.OrderState;
import com.oyakov.binance_trader_macd.domain.signal.MACDSignalAnalyzer;
import com.oyakov.binance_trader_macd.domain.OrderSide;
import com.oyakov.binance_trader_macd.domain.TradeSignal;
import com.oyakov.binance_trader_macd.model.order.binance.storage.OrderItem;
import com.oyakov.binance_trader_macd.service.api.OrderServiceApi;
import com.oyakov.binance_trader_macd.service.api.KlineEventListener;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

@Log4j2
@Service
@RequiredArgsConstructor
public class TraderServiceImpl implements KlineEventListener {


    private final MACDSignalAnalyzer MACDSignalAnalyzer;
    private final OrderServiceApi orderService;
    private final MACDTraderConfig traderConfig;

    private final ConcurrentLinkedQueue<KlineEvent> slidingWindow = new ConcurrentLinkedQueue<>();
    private final Lock eventQLock = new ReentrantLock();

    public static final BigDecimal QUANTITY = new BigDecimal("0.05");
    private static final int SLIDING_WINDOW_SIZE = 27; // Need at least 26 periods for MACD calculation
    private static final double STOP_LOSS_PERCENTAGE = 0.02; // 2% stop loss
    private static final double TAKE_PROFIT_PERCENTAGE = 0.04; // 4% take profit
    private final BigDecimal TAKE_PROFIT_THRESHOLD = BigDecimal.valueOf(1 + TAKE_PROFIT_PERCENTAGE);
    private final BigDecimal STOP_LOSS_THRESHOLD = BigDecimal.valueOf(1 - STOP_LOSS_PERCENTAGE);


    @Override
    public void onNewKline(KlineEvent klineEvent) {
        log.info("Kline event received for processing: %s".formatted(klineEvent));
        // Add new kline to the queue whatever happens
        slidingWindow.add(klineEvent);
        try {
            if (eventQLock.tryLock()) {
                log.info("Event Q lock acquired, processing the next event");
                // Keep only the necessary number of klines
                while (slidingWindow.size() > SLIDING_WINDOW_SIZE) {
                    log.info("Queue size = %s > %s. Remove oldest elements".formatted(slidingWindow.size(), SLIDING_WINDOW_SIZE));
                    slidingWindow.poll();
                }

                // Only process if we have enough data points
                if (slidingWindow.size() == SLIDING_WINDOW_SIZE) {
                    log.info("Queue size adjusted, process events");
                    processSlidingWindow(slidingWindow, klineEvent);
                } else {
                    log.debug("Waiting for more klines. Current size: %s".formatted(slidingWindow.size()));
                }
            } else {
                log.info("failed to acquire the Q lock, pass the invocation");
            }
        } catch (Exception e) {
            log.error("Error processing kline event", e);
        } finally {
            eventQLock.unlock();
        }
    }

    private void processSlidingWindow(Iterable<KlineEvent> data, KlineEvent triggerEvent) {
        // Get MACD signal
        MACDSignalAnalyzer.tryExtractSignal(data).ifPresentOrElse(
                signal -> executeTradeSignal(signal, triggerEvent),
                () -> executeKlineUpdate(triggerEvent));
    }

    private void executeKlineUpdate(KlineEvent klineEvent) {
        String symbol = klineEvent.getSymbol();
        BigDecimal currentPrice = BigDecimal.valueOf(klineEvent.getClose());
        log.info("Kline update [symbol %s, price %s]".formatted(symbol, currentPrice));
        orderService.getActiveOrder(symbol).ifPresentOrElse(
                orderItem -> {
                    log.info("Active order %s is present".formatted(orderItem.getOrderId()));
                    processOrderSLTP(orderItem.getOrderId(), orderItem.getPrice(), currentPrice);
                },
                () -> log.info("No active order detected, waiting for signal..."));
    }

    public void processOrderSLTP(Long orderId, BigDecimal entryPrice, BigDecimal currentPrice) {
        BigDecimal ratio = currentPrice.divide(entryPrice, RoundingMode.HALF_UP);
        log.info("SLTP - %s / %s = %s".formatted(entryPrice, currentPrice, ratio));

        // TODO: check if SLTP is handled automatically by OCO LIMIT, i.e. we shouldn't be cancelling any orders, just log the ratio for now
        // TODO: need to monitor order updates somehow to understand that the order has been closed, maybe also with websocket?
//        if (ratio.compareTo(TAKE_PROFIT_THRESHOLD) > 0) {
//            log.info("Close the deal, take profit threshold crossed");
//            orderService.closeOrderWithState(orderId, OrderState.CLOSED_TP);
//        } else {
//            log.info("Take profit threshold not reached yet");
//            if (ratio.compareTo(STOP_LOSS_THRESHOLD) < 0) {
//                log.warn("Stop loss threshold has been crossed for the order %s. Triggering order cancellation...".formatted(orderId));
//                orderService.closeOrderWithState(orderId, OrderState.CLOSED_SL);
//            }
//        }
    }

    private void processTradeSignalUpdate(Long orderId, OrderSide orderSide, OrderSide signalSide) {
        if(orderSide.equals(signalSide)) return;
        orderService.closeOrderWithState(orderId, OrderState.CLOSED_INVERTED_SIGNAL);
        // TODO: need to close OCO SLTP orders as well. maybe introduce order group notion and operate on order groups
    }

    private void executeTradeSignal(TradeSignal signal, KlineEvent klineEvent) {
        String symbol = klineEvent.getSymbol();
        BigDecimal currentPrice = BigDecimal.valueOf(klineEvent.getClose());
        log.info("%s signal is triggered for symbol %s at price %s".formatted(OrderSide.of(signal), symbol, currentPrice));
        orderService.getActiveOrder(symbol).ifPresentOrElse(
                orderItem -> {
                    log.info("Active order present: %s".formatted(orderItem));
                    processOrderSLTP(orderItem.getOrderId(), orderItem.getPrice(), currentPrice);
                    processTradeSignalUpdate(orderItem.getOrderId(), orderItem.getSide(), OrderSide.of(signal));
                },
                () -> {
                    log.info("No active order detected, creating a new one...");
                    // Create order with stop-loss and take-profit
                    OrderItem order = orderService.createOrderGroup(
                            symbol, currentPrice, QUANTITY, OrderSide.of(signal),
                            currentPrice.multiply(STOP_LOSS_THRESHOLD), // stop loss price
                            currentPrice.multiply(TAKE_PROFIT_THRESHOLD)); // take profit price
                    log.info("Order group created: %s".formatted(order));
                });
    }
}
