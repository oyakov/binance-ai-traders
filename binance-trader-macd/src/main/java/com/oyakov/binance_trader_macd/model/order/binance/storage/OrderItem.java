package com.oyakov.binance_trader_macd.model.order.binance.storage;

import com.oyakov.binance_trader_macd.domain.OrderSide;
import com.oyakov.binance_trader_macd.domain.OrderType;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.elasticsearch.annotations.Document;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Document(indexName = "orders")
@Table(name = "orders")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OrderItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(length = 10, nullable = false)
    private String symbol;

    @Column(name = "order_id", nullable = false, unique = true)
    private Long orderId;

    @Column(name = "parent_order_id")
    private Long parentOrderId;

    @Column(name = "order_list_id", nullable = false)
    private Integer orderListId;

    @Column(name = "client_order_id", length = 50, nullable = false)
    private String clientOrderId;

    @Column(name = "transact_time")
    private Long transactTime;

    @Column(name = "display_transact_time")
    private LocalDateTime displayTransactTime;

    @Column(nullable = false)
    private BigDecimal price;

    @Column(name = "orig_qty", nullable = false)
    private BigDecimal origQty;

    @Column(name = "executed_qty", nullable = false)
    private BigDecimal executedQty;

    @Column(name = "cummulative_quote_qty", nullable = false)
    private BigDecimal cummulativeQuoteQty;

    @Column(length = 20, nullable = false)
    private String status;

    @Column(name = "time_in_force", length = 10, nullable = false)
    private String timeInForce;

    @Enumerated(EnumType.STRING)
    @Column(name = "\"type\"", length = 20, nullable = false)
    private OrderType type;

    @Enumerated(EnumType.STRING)
    @Column(name = "side", length = 10, nullable = false)
    private OrderSide side;

    @Column(name = "working_time", nullable = false)
    private Long workingTime;

    @Column(name = "display_working_time", nullable = false)
    private LocalDateTime displayWorkingTime;

    @Column(name = "self_trade_prevention_mode", length = 20, nullable = false)
    private String selfTradePreventionMode;

    @Column(columnDefinition = "json", nullable = false)
    private String fills;
}
