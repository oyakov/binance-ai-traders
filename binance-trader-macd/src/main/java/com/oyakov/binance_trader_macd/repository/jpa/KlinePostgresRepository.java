package com.oyakov.binance_trader_macd.repository.jpa;

import com.oyakov.binance_trader_macd.model.klines.binance.storage.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface KlinePostgresRepository extends JpaRepository<OrderItem, Long> {
}
