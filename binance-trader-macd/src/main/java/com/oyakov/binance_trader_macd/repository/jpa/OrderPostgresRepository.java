package com.oyakov.binance_trader_macd.repository.jpa;

import com.oyakov.binance_trader_macd.domain.OrderState;
import com.oyakov.binance_trader_macd.model.order.binance.storage.OrderItem;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface OrderPostgresRepository extends JpaRepository<OrderItem, Long> {

    @Lock(LockModeType.PESSIMISTIC_READ)
    Optional<OrderItem> findBySymbolAndStatusEquals(String symbol, OrderState status);

    @Query(value = "update OrderItem set status = :state")
    void updateOrderState(Long id, @Param("state") OrderState state);
}
