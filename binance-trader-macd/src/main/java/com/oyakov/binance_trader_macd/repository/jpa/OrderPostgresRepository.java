package com.oyakov.binance_trader_macd.repository.jpa;

import com.oyakov.binance_trader_macd.model.order.binance.storage.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface OrderPostgresRepository extends JpaRepository<OrderItem, Long> {
    Optional<OrderItem> findBySymbolAndIsActiveTrue(String symbol);
}
