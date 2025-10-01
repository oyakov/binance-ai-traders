package com.oyakov.binance_trader_macd.service;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_trader_macd.config.MACDTraderConfig;
import com.oyakov.binance_trader_macd.domain.OrderSide;
import com.oyakov.binance_trader_macd.domain.OrderState;
import com.oyakov.binance_trader_macd.domain.TradeSignal;
import com.oyakov.binance_trader_macd.model.order.binance.storage.OrderItem;
import com.oyakov.binance_trader_macd.service.api.OrderServiceApi;
import com.oyakov.binance_trader_macd.domain.signal.MACDSignalAnalyzer;
import com.oyakov.binance_trader_macd.service.impl.TraderServiceImpl;
import io.micrometer.core.instrument.MeterRegistry;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mockito;
import org.springframework.context.annotation.Bean;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

@ExtendWith(SpringExtension.class)
@ContextConfiguration(classes = TraderServiceImplSimulationTest.TraderServiceTestConfig.class)
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_EACH_TEST_METHOD)
class TraderServiceImplSimulationTest {

    private static final String SYMBOL = "BTCUSDT";

    @TestConfiguration
    static class TraderServiceTestConfig {

        @Bean
        MACDTraderConfig traderConfig() {
            MACDTraderConfig config = new MACDTraderConfig();
            MACDTraderConfig.Trader trader = new MACDTraderConfig.Trader();
            trader.setSlidingWindowSize(3);
            trader.setOrderQuantity(new BigDecimal("0.01"));
            trader.setStopLossPercentage(new BigDecimal("0.95"));
            trader.setTakeProfitPercentage(new BigDecimal("1.05"));
            config.setTrader(trader);
            return config;
        }

        @Bean
        OrderServiceApi orderServiceApi() {
            return Mockito.mock(OrderServiceApi.class);
        }

        @Bean
        MACDSignalAnalyzer macdSignalAnalyzer() {
            return Mockito.mock(MACDSignalAnalyzer.class);
        }

        @Bean
        MeterRegistry meterRegistry() {
            return Mockito.mock(MeterRegistry.class);
        }

        @Bean
        TraderServiceImpl traderService(MACDSignalAnalyzer analyzer,
                                        OrderServiceApi orderServiceApi,
                                        MACDTraderConfig traderConfig,
                                        MeterRegistry meterRegistry) {
            return new TraderServiceImpl(analyzer, orderServiceApi, traderConfig, meterRegistry);
        }
    }

    private final TraderServiceImpl traderService;
    private final MACDSignalAnalyzer macdSignalAnalyzer;
    private final OrderServiceApi orderService;

    TraderServiceImplSimulationTest(TraderServiceImpl traderService,
                                    MACDSignalAnalyzer macdSignalAnalyzer,
                                    OrderServiceApi orderService) {
        this.traderService = traderService;
        this.macdSignalAnalyzer = macdSignalAnalyzer;
        this.orderService = orderService;
    }

    @BeforeEach
    void setUp() {
        Mockito.reset(macdSignalAnalyzer, orderService);
        Mockito.when(orderService.createOrderGroup(anyString(), any(), any(), any(), any(), any()))
                .thenReturn(OrderItem.builder().orderId(777L).build());
    }

    @Test
    void createsOrderGroupWhenSignalDetectedAndNoActiveOrder() {
        Mockito.when(macdSignalAnalyzer.tryExtractSignal(any()))
                .thenReturn(Optional.of(TradeSignal.BUY));
        Mockito.when(orderService.getActiveOrder(SYMBOL)).thenReturn(Optional.empty());

        replayKlines(
                new BigDecimal("100.00"),
                new BigDecimal("101.00"),
                new BigDecimal("102.00"));

        ArgumentCaptor<BigDecimal> stopLossCaptor = ArgumentCaptor.forClass(BigDecimal.class);
        ArgumentCaptor<BigDecimal> takeProfitCaptor = ArgumentCaptor.forClass(BigDecimal.class);

        verify(orderService).createOrderGroup(eq(SYMBOL), eq(new BigDecimal("102.00")),
                eq(new BigDecimal("0.01")), eq(OrderSide.BUY),
                stopLossCaptor.capture(), takeProfitCaptor.capture());

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

        Mockito.when(macdSignalAnalyzer.tryExtractSignal(any()))
                .thenReturn(Optional.of(TradeSignal.SELL));
        Mockito.when(orderService.getActiveOrder(SYMBOL)).thenReturn(Optional.of(activeOrder));

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

        Mockito.when(macdSignalAnalyzer.tryExtractSignal(any())).thenReturn(Optional.empty());
        Mockito.when(orderService.getActiveOrder(SYMBOL)).thenReturn(Optional.of(activeOrder));

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

