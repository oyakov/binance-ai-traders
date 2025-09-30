package com.oyakov.binance_trader_macd.service.impl;

import com.oyakov.binance_trader_macd.domain.OrderSide;
import com.oyakov.binance_trader_macd.domain.OrderState;
import com.oyakov.binance_trader_macd.domain.OrderType;
import com.oyakov.binance_trader_macd.domain.TimeInForce;
import com.oyakov.binance_trader_macd.exception.OrderCapacityReachedException;
import com.oyakov.binance_trader_macd.model.order.binance.storage.OrderItem;
import com.oyakov.binance_trader_macd.repository.jpa.OrderPostgresRepository;
import com.oyakov.binance_trader_macd.rest.client.BinanceOrderClient;
import com.oyakov.binance_trader_macd.rest.dto.BinanceOcoOrderResponse;
import com.oyakov.binance_trader_macd.rest.dto.BinanceOrderResponse;
import com.oyakov.binance_trader_macd.service.api.OrderServiceApi;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.core.convert.ConversionService;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class OrderServiceImplTest {

    private static final String SYMBOL = "BTCUSDT";

    @Mock
    private BinanceOrderClient binanceOrderClient;
    @Mock
    private OrderPostgresRepository orderRepository;
    @Mock
    private ConversionService conversionService;

    private OrderServiceApi orderService;

    @BeforeEach
    void setUp() {
        orderService = new OrderServiceImpl(binanceOrderClient, orderRepository, conversionService);
    }

    @Test
    void shouldThrowWhenActiveOrderAlreadyExists() {
        OrderItem existing = OrderItem.builder().symbol(SYMBOL).status(OrderState.ACTIVE).build();
        when(orderRepository.findBySymbolAndStatusEquals(SYMBOL, OrderState.ACTIVE)).thenReturn(Optional.of(existing));

        assertThatThrownBy(() -> orderService.createOrderGroup(
                SYMBOL,
                BigDecimal.TEN,
                BigDecimal.ONE,
                OrderSide.BUY,
                BigDecimal.valueOf(9),
                BigDecimal.valueOf(11)
        )).isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("Active order exists");

        verify(binanceOrderClient, never()).placeOrder(any(), any(), any(), any(), any(), any(), any());
    }

    @Test
    void shouldCreateOrderGroupAndPersistOrders() throws OrderCapacityReachedException {
        when(orderRepository.findBySymbolAndStatusEquals(SYMBOL, OrderState.ACTIVE)).thenReturn(Optional.empty());

        BinanceOrderResponse mainResponse = new BinanceOrderResponse();
        mainResponse.setSymbol(SYMBOL);
        mainResponse.setOrderId(123L);
        mainResponse.setType(OrderType.LIMIT.name());
        mainResponse.setSide(OrderSide.BUY.name());
        OrderItem entryOrder = OrderItem.builder().orderId(123L).symbol(SYMBOL).status(OrderState.NEW).build();
        when(binanceOrderClient.placeOrder(SYMBOL, OrderType.LIMIT, OrderSide.BUY,
                BigDecimal.ONE, BigDecimal.TEN, null, TimeInForce.GTC)).thenReturn(mainResponse);
        when(conversionService.convert(mainResponse, OrderItem.class)).thenReturn(entryOrder);

        BinanceOcoOrderResponse.OrderReport report = new BinanceOcoOrderResponse.OrderReport();
        report.setOrderId(456L);
        BinanceOcoOrderResponse ocoResponse = new BinanceOcoOrderResponse();
        ocoResponse.setOrderReports(List.of(report));
        when(binanceOrderClient.placeOcoOrder(eq(SYMBOL), eq(OrderSide.SELL), eq(BigDecimal.ONE),
                any(), any(), any(), any())).thenReturn(ocoResponse);
        OrderItem ocoOrder = OrderItem.builder().orderId(456L).symbol(SYMBOL).status(OrderState.NEW).build();
        when(conversionService.convert(report, OrderItem.class)).thenReturn(ocoOrder);

        OrderItem result = orderService.createOrderGroup(
                SYMBOL,
                BigDecimal.TEN,
                BigDecimal.ONE,
                OrderSide.BUY,
                BigDecimal.valueOf(9),
                BigDecimal.valueOf(11)
        );

        assertThat(result).isSameAs(entryOrder);
        verify(orderRepository).save(entryOrder);
        verify(orderRepository).saveAll(any());
    }

    @Test
    void shouldCancelAndUpdateOrderStateWhenClosing() {
        OrderItem storedOrder = OrderItem.builder()
                .orderId(321L)
                .symbol(SYMBOL)
                .status(OrderState.NEW)
                .build();
        when(orderRepository.findById(321L)).thenReturn(Optional.of(storedOrder));
        when(binanceOrderClient.cancelOrder(SYMBOL, 321L)).thenReturn(true);

        orderService.closeOrderWithState(321L, OrderState.CLOSED_SL);

        verify(binanceOrderClient).cancelOrder(SYMBOL, 321L);
        verify(orderRepository).updateOrderState(321L, OrderState.CLOSED_SL);
    }

    @Test
    void shouldNotUpdateStateWhenCancelFails() {
        OrderItem storedOrder = OrderItem.builder()
                .orderId(999L)
                .symbol(SYMBOL)
                .status(OrderState.NEW)
                .build();
        when(orderRepository.findById(999L)).thenReturn(Optional.of(storedOrder));
        when(binanceOrderClient.cancelOrder(SYMBOL, 999L)).thenReturn(false);

        orderService.closeOrderWithState(999L, OrderState.CLOSED_TP);

        verify(orderRepository, never()).updateOrderState(anyLong(), any());
    }

    @Test
    void shouldDelegateActiveOrderLookups() {
        OrderItem active = OrderItem.builder().orderId(777L).symbol(SYMBOL).status(OrderState.ACTIVE).build();
        when(orderRepository.findBySymbolAndStatusEquals(SYMBOL, OrderState.ACTIVE)).thenReturn(Optional.of(active));

        assertThat(orderService.getActiveOrder(SYMBOL)).contains(active);
        assertThat(orderService.hasActiveOrder(SYMBOL)).isTrue();

        verify(orderRepository, times(2)).findBySymbolAndStatusEquals(SYMBOL, OrderState.ACTIVE);
    }
}
