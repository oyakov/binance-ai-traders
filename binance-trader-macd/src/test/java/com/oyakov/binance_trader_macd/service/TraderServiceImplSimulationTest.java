package com.oyakov.binance_trader_macd.service;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_trader_macd.config.MACDTraderConfig;
import com.oyakov.binance_trader_macd.domain.OrderSide;
import com.oyakov.binance_trader_macd.domain.OrderState;
import com.oyakov.binance_trader_macd.domain.TradeSignal;
import com.oyakov.binance_trader_macd.domain.signal.MACDSignalAnalyzer;
import com.oyakov.binance_trader_macd.model.order.binance.storage.OrderItem;
import com.oyakov.binance_trader_macd.service.api.OrderServiceApi;
import com.oyakov.binance_trader_macd.service.impl.TraderServiceImpl;
import io.micrometer.core.instrument.simple.SimpleMeterRegistry;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class TraderServiceImplSimulationTest {

    private static final String SYMBOL = "BTCUSDT";

    @Mock
    private MACDSignalAnalyzer macdSignalAnalyzer;

    @Mock
    private OrderServiceApi orderService;

    private TraderServiceImpl traderService;
    private MACDTraderConfig traderConfig;

    @BeforeEach
    void setUp() {
        traderConfig = new MACDTraderConfig();
        MACDTraderConfig.Trader trader = new MACDTraderConfig.Trader();
        trader.setSlidingWindowSize(3);
        trader.setOrderQuantity(new BigDecimal("0.01"));
        trader.setStopLossPercentage(new BigDecimal("0.95"));
        trader.setTakeProfitPercentage(new BigDecimal("1.05"));
        traderConfig.setTrader(trader);

        traderService = new TraderServiceImpl(macdSignalAnalyzer, orderService, traderConfig, new SimpleMeterRegistry());
        ReflectionTestUtils.invokeMethod(traderService, "init");
    }

    @Test
    void createsOrderGroupWhenSignalDetectedAndNoActiveOrder() {
        when(macdSignalAnalyzer.tryExtractSignal(any())).thenReturn(Optional.of(TradeSignal.BUY));
        when(orderService.getActiveOrder(SYMBOL)).thenReturn(Optional.empty());
        when(orderService.createOrderGroup(anyString(), any(), any(), any(), any(), any()))
                .thenReturn(OrderItem.builder().orderId(777L).build());

        replayKlines(
                new BigDecimal("100.00"),
                new BigDecimal("101.00"),
                new BigDecimal("102.00"));

        ArgumentCaptor<BigDecimal> stopLossCaptor = ArgumentCaptor.forClass(BigDecimal.class);
        ArgumentCaptor<BigDecimal> takeProfitCaptor = ArgumentCaptor.forClass(BigDecimal.class);

        verify(orderService).createOrderGroup(
                eq(SYMBOL),
                eq(new BigDecimal("102.00")),
                eq(new BigDecimal("0.01")),
                eq(OrderSide.BUY),
                stopLossCaptor.capture(),
                takeProfitCaptor.capture());

        Assertions.assertThat(stopLossCaptor.getValue()).isEqualByComparingTo(new BigDecimal("96.90"));
        Assertions.assertThat(takeProfitCaptor.getValue()).isEqualByComparingTo(new BigDecimal("107.10"));
    }

    @Test
    void closesExistingOrderWhenSignalInverts() {
        OrderItem activeOrder = OrderItem.builder()
                .orderId(4242L)
                .price(new BigDecimal("100.00"))
                .side(OrderSide.BUY)
                .build();

        when(macdSignalAnalyzer.tryExtractSignal(any())).thenReturn(Optional.of(TradeSignal.SELL));
        when(orderService.getActiveOrder(SYMBOL)).thenReturn(Optional.of(activeOrder));

        replayKlines(
                new BigDecimal("100.00"),
                new BigDecimal("101.00"),
                new BigDecimal("99.50"));

        verify(orderService).closeOrderWithState(activeOrder.getOrderId(), OrderState.CLOSED_INVERTED_SIGNAL);
        verify(orderService, never()).createOrderGroup(anyString(), any(), any(), any(), any(), any());
    }

    @Test
    void closesOrderWhenStopLossIsHit() {
        OrderItem activeOrder = OrderItem.builder()
                .orderId(5150L)
                .price(new BigDecimal("100.00"))
                .side(OrderSide.BUY)
                .build();

        when(macdSignalAnalyzer.tryExtractSignal(any())).thenReturn(Optional.empty());
        when(orderService.getActiveOrder(SYMBOL)).thenReturn(Optional.of(activeOrder));

        replayKlines(
                new BigDecimal("100.00"),
                new BigDecimal("99.00"),
                new BigDecimal("94.00"));

        verify(orderService).closeOrderWithState(activeOrder.getOrderId(), OrderState.CLOSED_SL);
        verify(orderService, never()).createOrderGroup(anyString(), any(), any(), any(), any(), any());
    }

    private void replayKlines(BigDecimal... closes) {
        long baseTime = 1_000_000_000L;
        for (int i = 0; i < closes.length; i++) {
            traderService.onNewKline(klineEvent(baseTime + (i * 60_000L), closes[i]));
        }
    }

    private KlineEvent klineEvent(long closeTime, BigDecimal closePrice) {
        KlineEvent event = new KlineEvent();
        event.setEventType("kline");
        event.setEventTime(closeTime);
        event.setSymbol(SYMBOL);
        event.setInterval("15m");
        event.setOpenTime(closeTime - 60_000L);
        event.setCloseTime(closeTime);
        BigDecimal normalizedPrice = closePrice.setScale(2, RoundingMode.HALF_UP);
        event.setOpen(normalizedPrice);
        event.setHigh(normalizedPrice);
        event.setLow(normalizedPrice);
        event.setClose(normalizedPrice);
        event.setVolume(BigDecimal.ONE);
        return event;
    }
}
