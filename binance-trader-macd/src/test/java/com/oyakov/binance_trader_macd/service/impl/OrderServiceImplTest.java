package com.oyakov.binance_trader_macd.service.impl;

import com.oyakov.binance_trader_macd.domain.OrderSide;
import com.oyakov.binance_trader_macd.domain.OrderState;
import com.oyakov.binance_trader_macd.domain.OrderType;
import com.oyakov.binance_trader_macd.model.order.binance.storage.OrderItem;
import com.oyakov.binance_trader_macd.repository.jpa.OrderPostgresRepository;
import com.oyakov.binance_trader_macd.rest.client.BinanceOrderClient;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.core.convert.support.DefaultConversionService;
import org.springframework.test.context.ActiveProfiles;

import com.oyakov.binance_trader_macd.repository.elastic.OrderElasticRepository;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@DataJpaTest
@ActiveProfiles("test")
class OrderServiceImplTest {

    @Autowired
    private OrderPostgresRepository orderRepository;

    @MockBean
    private OrderElasticRepository orderElasticRepository;

    private BinanceOrderClient binanceOrderClient;

    private OrderServiceImpl orderService;

    @BeforeEach
    void setUp() {
        binanceOrderClient = Mockito.mock(BinanceOrderClient.class);
        orderService = new OrderServiceImpl(binanceOrderClient, orderRepository, new DefaultConversionService());
    }

    @Test
    void closeOrderWithStateCancelsOrderAndUpdatesPersistedState() {
        OrderItem persistedOrder = orderRepository.save(buildOrderItem());

        when(binanceOrderClient.cancelOrder(persistedOrder.getSymbol(), persistedOrder.getOrderId())).thenReturn(true);

        orderService.closeOrderWithState(persistedOrder.getOrderId(), OrderState.CLOSED_CANCELED);

        verify(binanceOrderClient).cancelOrder(persistedOrder.getSymbol(), persistedOrder.getOrderId());
        OrderItem updatedOrder = orderRepository.findByOrderId(persistedOrder.getOrderId()).orElseThrow();
        assertThat(updatedOrder.getStatus()).isEqualTo(OrderState.CLOSED_CANCELED);
    }

    private OrderItem buildOrderItem() {
        return OrderItem.builder()
                .symbol("BTCUSDT")
                .orderId(123456789L)
                .orderListId(1)
                .clientOrderId("test-client")
                .transactTime(1L)
                .displayTransactTime(LocalDateTime.now())
                .price(BigDecimal.TEN)
                .origQty(BigDecimal.ONE)
                .executedQty(BigDecimal.ZERO)
                .cummulativeQuoteQty(BigDecimal.ZERO)
                .status(OrderState.NEW)
                .timeInForce("GTC")
                .type(OrderType.LIMIT)
                .side(OrderSide.BUY)
                .workingTime(1L)
                .displayWorkingTime(LocalDateTime.now())
                .selfTradePreventionMode("NONE")
                .fills("[]")
                .build();
    }
}
