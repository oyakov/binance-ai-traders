package com.oyakov.binance_trader_macd.service.impl;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_trader_macd.config.MACDTraderConfig;
import com.oyakov.binance_trader_macd.domain.OrderSide;
import com.oyakov.binance_trader_macd.domain.OrderState;
import com.oyakov.binance_trader_macd.domain.TradeSignal;
import com.oyakov.binance_trader_macd.domain.signal.MACDSignalAnalyzer;
import com.oyakov.binance_trader_macd.model.order.binance.storage.OrderItem;
import com.oyakov.binance_trader_macd.service.api.OrderServiceApi;
import io.micrometer.core.instrument.MeterRegistry;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class TraderServiceImplTest {

    private static final String SYMBOL = "BTCUSDT";
    private static final BigDecimal ENTRY_PRICE = BigDecimal.valueOf(100);
    private static final BigDecimal ORDER_QUANTITY = BigDecimal.valueOf(0.1);
    private static final BigDecimal STOP_LOSS_THRESHOLD = BigDecimal.valueOf(0.95);
    private static final BigDecimal TAKE_PROFIT_THRESHOLD = BigDecimal.valueOf(1.05);

    @Mock
    private MACDSignalAnalyzer macdSignalAnalyzer;

    @Mock
    private OrderServiceApi orderServiceApi;

    @Mock
    private MeterRegistry meterRegistry;

    private TraderServiceImpl traderService;

    @BeforeEach
    void setUp() {
        MACDTraderConfig config = new MACDTraderConfig();
        config.getTrader().setSlidingWindowSize(1);
        config.getTrader().setOrderQuantity(ORDER_QUANTITY);
        config.getTrader().setStopLossPercentage(STOP_LOSS_THRESHOLD);
        config.getTrader().setTakeProfitPercentage(TAKE_PROFIT_THRESHOLD);

        traderService = new TraderServiceImpl(macdSignalAnalyzer, orderServiceApi, config, meterRegistry);
        ReflectionTestUtils.invokeMethod(traderService, "init");
    }

    @Test
    void shouldCreateOrderGroupWhenSignalEmittedAndNoActiveOrder() {
        BigDecimal currentPrice = BigDecimal.valueOf(110);
        when(macdSignalAnalyzer.tryExtractSignal(any())).thenReturn(Optional.of(TradeSignal.BUY));
        when(orderServiceApi.getActiveOrder(SYMBOL)).thenReturn(Optional.empty());

        traderService.onNewKline(buildKlineEvent(currentPrice));

        verify(orderServiceApi).createOrderGroup(
                eq(SYMBOL),
                eq(currentPrice),
                eq(ORDER_QUANTITY),
                eq(OrderSide.BUY),
                eq(currentPrice.multiply(STOP_LOSS_THRESHOLD).setScale(currentPrice.scale(), RoundingMode.HALF_UP)),
                eq(currentPrice.multiply(TAKE_PROFIT_THRESHOLD).setScale(currentPrice.scale(), RoundingMode.HALF_UP))
        );
        verify(orderServiceApi, never()).closeOrderWithState(anyLong(), any(OrderState.class));
    }

    @Test
    void shouldCloseOrderWhenSignalOppositeToActiveOrder() {
        BigDecimal currentPrice = ENTRY_PRICE;
        OrderItem orderItem = new OrderItem();
        orderItem.setOrderId(1L);
        orderItem.setPrice(ENTRY_PRICE);
        orderItem.setSide(OrderSide.SELL);

        when(macdSignalAnalyzer.tryExtractSignal(any())).thenReturn(Optional.of(TradeSignal.BUY));
        when(orderServiceApi.getActiveOrder(SYMBOL)).thenReturn(Optional.of(orderItem));

        traderService.onNewKline(buildKlineEvent(currentPrice));

        verify(orderServiceApi).closeOrderWithState(1L, OrderState.CLOSED_INVERTED_SIGNAL);
        verify(orderServiceApi, never()).createOrderGroup(
                anyString(), any(BigDecimal.class), any(BigDecimal.class), any(OrderSide.class), any(BigDecimal.class), any(BigDecimal.class));
    }

    @Test
    void shouldCloseOrderWithTakeProfitWhenThresholdBreached() {
        BigDecimal takeProfitPrice = ENTRY_PRICE.multiply(TAKE_PROFIT_THRESHOLD.add(BigDecimal.valueOf(0.01)));

        traderService.processOrderSLTP(1L, ENTRY_PRICE, takeProfitPrice);

        verify(orderServiceApi).closeOrderWithState(1L, OrderState.CLOSED_TP);
    }

    @Test
    void shouldCloseOrderWithStopLossWhenThresholdBreached() {
        BigDecimal stopLossPrice = ENTRY_PRICE.multiply(STOP_LOSS_THRESHOLD.subtract(BigDecimal.valueOf(0.05)));

        traderService.processOrderSLTP(2L, ENTRY_PRICE, stopLossPrice);

        verify(orderServiceApi).closeOrderWithState(2L, OrderState.CLOSED_SL);
    }

    @Test
    void shouldNotCloseOrderWhenThresholdsNotBreached() {
        BigDecimal neutralPrice = ENTRY_PRICE;

        traderService.processOrderSLTP(3L, ENTRY_PRICE, neutralPrice);

        verify(orderServiceApi, never()).closeOrderWithState(anyLong(), any(OrderState.class));
    }

    private KlineEvent buildKlineEvent(BigDecimal closePrice) {
        long now = Instant.now().toEpochMilli();
        return KlineEvent.newBuilder()
                .setEventType("kline")
                .setEventTime(now)
                .setSymbol(SYMBOL)
                .setInterval("1m")
                .setOpenTime(now - 60_000)
                .setCloseTime(now)
                .setOpen(closePrice)
                .setHigh(closePrice)
                .setLow(closePrice)
                .setClose(closePrice)
                .setVolume(BigDecimal.ONE)
                .build();
    }
}
