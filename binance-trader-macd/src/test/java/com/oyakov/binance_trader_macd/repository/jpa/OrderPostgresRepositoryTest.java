package com.oyakov.binance_trader_macd.repository.jpa;

import com.oyakov.binance_trader_macd.converter.BinanceOcoOrderReportToOrderConverter;
import com.oyakov.binance_trader_macd.domain.OrderSide;
import com.oyakov.binance_trader_macd.domain.OrderState;
import com.oyakov.binance_trader_macd.domain.OrderType;
import com.oyakov.binance_trader_macd.domain.TimeInForce;
import com.oyakov.binance_trader_macd.model.order.binance.storage.OrderItem;
import com.oyakov.binance_trader_macd.rest.dto.BinanceOcoOrderResponse;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.TestPropertySource;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@TestPropertySource(properties = {
        "spring.jpa.hibernate.ddl-auto=create-drop",
        "spring.flyway.enabled=false"
})
class OrderPostgresRepositoryTest {

    @Autowired
    private OrderPostgresRepository orderRepository;

    private final BinanceOcoOrderReportToOrderConverter converter = new BinanceOcoOrderReportToOrderConverter();

    @Test
    void shouldPersistOcoChildWithParentOrderId() {
        OrderItem parentOrder = orderRepository.save(buildParentOrder(321L, 7));

        BinanceOcoOrderResponse.OrderReport report = new BinanceOcoOrderResponse.OrderReport();
        report.setSymbol("BTCUSDT");
        report.setOrderId(654L);
        report.setOrderListId(8L);
        report.setClientOrderId("child-client-654");
        report.setTransactTime(1_700_000_500_000L);
        report.setPrice(new BigDecimal("24950.00"));
        report.setOrigQty(new BigDecimal("0.010"));
        report.setExecutedQty(BigDecimal.ZERO);
        report.setCummulativeQuoteQty(BigDecimal.ZERO);
        report.setStatus("ACTIVE");
        report.setTimeInForce("GTC");
        report.setType("STOP_LOSS_LIMIT");
        report.setSide("SELL");
        report.setWorkingTime(1_700_000_500_000L);
        report.setSelfTradePreventionMode("NONE");

        OrderItem childOrder = converter.convert(report);
        assertThat(childOrder).isNotNull();
        childOrder.setParentOrderId(parentOrder.getOrderId());

        OrderItem savedChild = orderRepository.save(childOrder);
        OrderItem persistedChild = orderRepository.findById(savedChild.getId()).orElseThrow();

        assertThat(persistedChild.getParentOrderId()).isEqualTo(parentOrder.getOrderId());
        assertThat(persistedChild.getOrderListId()).isEqualTo(8);
    }

    private static OrderItem buildParentOrder(Long orderId, int orderListId) {
        long baseTime = 1_700_000_000_000L;
        LocalDateTime displayTime = Instant.ofEpochMilli(baseTime).atZone(ZoneOffset.UTC).toLocalDateTime();

        return OrderItem.builder()
                .symbol("BTCUSDT")
                .orderId(orderId)
                .orderListId(orderListId)
                .clientOrderId("parent-client-" + orderId)
                .transactTime(baseTime)
                .displayTransactTime(displayTime)
                .price(new BigDecimal("25000.00"))
                .origQty(new BigDecimal("0.010"))
                .executedQty(BigDecimal.ZERO)
                .cummulativeQuoteQty(BigDecimal.ZERO)
                .status(OrderState.ACTIVE)
                .timeInForce(TimeInForce.GTC.name())
                .type(OrderType.LIMIT)
                .side(OrderSide.BUY)
                .workingTime(baseTime)
                .displayWorkingTime(displayTime)
                .selfTradePreventionMode("NONE")
                .fills("[]")
                .build();
    }
}
