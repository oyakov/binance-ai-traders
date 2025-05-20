package com.oyakov.binance_trader_macd.service.impl;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_trader_macd.domain.MacdCalculator;
import com.oyakov.binance_trader_macd.domain.OrderSide;
import com.oyakov.binance_trader_macd.domain.TradeSignal;
import com.oyakov.binance_trader_macd.service.api.OrderServiceApi;
import com.oyakov.binance_trader_macd.service.api.TraderServiceApi;
import lombok.extern.log4j.Log4j2;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.concurrent.ConcurrentLinkedQueue;

@Log4j2
@Service
public class TraderServiceImpl implements TraderServiceApi {

    private final MacdCalculator macdCalculator;
    private final OrderServiceApi orderService;
    private final ConcurrentLinkedQueue<KlineEvent> klineEvents;
    private static final int MIN_KLINES_FOR_SIGNAL = 27; // Need at least 26 periods for MACD calculation
    private static final double STOP_LOSS_PERCENTAGE = 0.02; // 2% stop loss
    private static final double TAKE_PROFIT_PERCENTAGE = 0.04; // 4% take profit

    @Autowired
    public TraderServiceImpl(OrderServiceApi orderService) {
        this.orderService = orderService;
        this.macdCalculator = new MacdCalculator();
        this.klineEvents = new ConcurrentLinkedQueue<>();
    }

    @Override
    public void onNewKline(KlineEvent klineEvent) {
        try {
            // Add new kline to the queue
            klineEvents.add(klineEvent);

            // Keep only the necessary number of klines
            while (klineEvents.size() > MIN_KLINES_FOR_SIGNAL) {
                klineEvents.poll();
            }

            // Log the new kline
            log.debug("New kline received: {}", klineEvent);

            // Check and update any existing positions
            BigDecimal currentPrice = BigDecimal.valueOf(klineEvent.getClose());
            orderService.checkAndUpdateStopLossTakeProfit(klineEvent.getSymbol(), currentPrice);

            // Only process if we have enough data points
            if (klineEvents.size() >= MIN_KLINES_FOR_SIGNAL) {
                processTradeSignals(klineEvent);
            } else {
                log.debug("Waiting for more klines. Current size: {}", klineEvents.size());
            }
        } catch (Exception e) {
            log.error("Error processing kline event", e);
        }
    }

    private void processTradeSignals(KlineEvent currentKline) {
        // Get MACD signal
        macdCalculator.update(currentKline)
                .ifPresent(signal -> {
                    try {
                        executeTradeSignal(signal, currentKline);
                    } catch (Exception e) {
                        log.error("Error executing trade signal", e);
                    }
                });
    }

    private void executeTradeSignal(TradeSignal signal, KlineEvent kline) {
        String symbol = kline.getSymbol();
        BigDecimal currentPrice = BigDecimal.valueOf(kline.getClose());

        switch (signal) {
            case BUY:
                if (!orderService.hasActiveOrder(symbol)) {
                    log.info("BUY Signal triggered for {} at price {}", symbol, currentPrice);
                    
                    // Calculate stop-loss and take-profit levels
                    BigDecimal stopLoss = currentPrice.multiply(BigDecimal.valueOf(1 - STOP_LOSS_PERCENTAGE));
                    BigDecimal takeProfit = currentPrice.multiply(BigDecimal.valueOf(1 + TAKE_PROFIT_PERCENTAGE));
                    
                    // Create order with stop-loss and take-profit
                    orderService.createOrder(symbol, currentPrice, OrderSide.BUY, stopLoss, takeProfit);
                }
                break;

            case SELL:
                orderService.getActiveOrder(symbol).ifPresent(order -> {
                    log.info("SELL Signal triggered for {} at price {}", symbol, currentPrice);
                    orderService.cancelOrder(order.getOrderId());
                });
                break;
        }
    }
}
