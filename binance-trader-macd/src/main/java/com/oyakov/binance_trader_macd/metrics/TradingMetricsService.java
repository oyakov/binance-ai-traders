package com.oyakov.binance_trader_macd.metrics;

import com.oyakov.binance_trader_macd.domain.OrderState;
import com.oyakov.binance_trader_macd.repository.jpa.OrderPostgresRepository;
import org.springframework.transaction.annotation.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.Collection;
import java.util.EnumSet;

@Service
@RequiredArgsConstructor
public class TradingMetricsService {

    private final OrderPostgresRepository orderRepository;

    @Transactional(readOnly = true)
    public long countActivePositions() {
        return orderRepository.countByStatus(OrderState.ACTIVE);
    }

    @Transactional(readOnly = true)
    public BigDecimal calculateRealizedPnl() {
        Collection<OrderState> closedStates = EnumSet.of(OrderState.CLOSED_TP, OrderState.CLOSED_SL,
                OrderState.CLOSED_CANCELED, OrderState.CLOSED_INVERTED_SIGNAL);
        BigDecimal pnl = orderRepository.calculateNetQuoteChangeByStatuses(closedStates);
        return pnl != null ? pnl : BigDecimal.ZERO;
    }
}
