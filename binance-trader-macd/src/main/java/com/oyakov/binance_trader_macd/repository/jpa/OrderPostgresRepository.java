package com.oyakov.binance_trader_macd.repository.jpa;

import com.oyakov.binance_trader_macd.domain.OrderState;
import com.oyakov.binance_trader_macd.model.order.binance.storage.OrderItem;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.Collection;
import java.util.Optional;

@Repository
public interface OrderPostgresRepository extends JpaRepository<OrderItem, Long> {

    @Lock(LockModeType.PESSIMISTIC_READ)
    Optional<OrderItem> findBySymbolAndStatusEquals(String symbol, OrderState status);

    @Query(value = "update OrderItem set status = :state")
    void updateOrderState(Long id, @Param("state") OrderState state);

    long countByStatus(OrderState status);

    @Query("SELECT COALESCE(SUM(CASE WHEN o.side = com.oyakov.binance_trader_macd.domain.OrderSide.BUY " +
            "THEN -o.cummulativeQuoteQty ELSE o.cummulativeQuoteQty END), 0) " +
            "FROM OrderItem o WHERE o.status IN :statuses")
    BigDecimal calculateNetQuoteChangeByStatuses(@Param("statuses") Collection<OrderState> statuses);
}
