package com.oyakov.binance_trader_macd.service.impl;

import com.oyakov.binance_trader_macd.domain.OrderSide;
import com.oyakov.binance_trader_macd.domain.OrderType;
import com.oyakov.binance_trader_macd.domain.TimeInForce;
import com.oyakov.binance_trader_macd.exception.OrderCapacityReachedException;
import com.oyakov.binance_trader_macd.model.order.binance.storage.OrderItem;
import com.oyakov.binance_trader_macd.repository.jpa.OrderPostgresRepository;
import com.oyakov.binance_trader_macd.rest.client.BinanceOrderClient;
import com.oyakov.binance_trader_macd.rest.dto.BinanceOcoOrderResponse;
import com.oyakov.binance_trader_macd.rest.dto.BinanceOrderResponse;
import com.oyakov.binance_trader_macd.service.api.OrderServiceApi;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.convert.ConversionService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Log4j2
@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderServiceApi {

    private final BinanceOrderClient binanceOrderClient;
    private final OrderPostgresRepository orderRepository;
    private final ConversionService conversionService;
    private static final double DEFAULT_QUANTITY = 0.05;

    @Override
    @Transactional
    public OrderItem createOrderGroup(String symbol,
                                      OrderType orderType,
                                      BigDecimal price,
                                      BigDecimal quantity,
                                      OrderSide orderSide,
                                      BigDecimal stopLoss,
                                      BigDecimal takeProfit) throws OrderCapacityReachedException {

        if (hasActiveOrder(symbol)) {
            log.warn("Cannot create new order - active order exists for symbol: %s".formatted(symbol));
            throw new IllegalStateException("Active order exists for symbol: %s".formatted(symbol));
        }

        // 1. Place the main limit order
        OrderItem entryOrder = placeMainOrder(symbol, price, quantity, orderSide);

        // 2. Place SLTP OCO order
        List<OrderItem> ocoOrders = placeSLTP_OCO(symbol, quantity, stopLoss, takeProfit, orderSide.oppositeSide(), entryOrder);

        // 3. Persist all the orders
        orderRepository.saveAll(ocoOrders);
        orderRepository.save(entryOrder);

        return entryOrder;
    }

    private List<OrderItem> placeSLTP_OCO(String symbol, BigDecimal quantity, BigDecimal stopLoss, BigDecimal takeProfit, OrderSide ocoSide, OrderItem entryOrder) {
        BinanceOcoOrderResponse ocoResponse = binanceOrderClient.placeOcoOrder(
                symbol,
                ocoSide,
                quantity,
                takeProfit,      // abovePrice
                takeProfit,      // aboveStopPrice
                stopLoss,        // belowStopPrice
                stopLoss         // belowLimitPrice
        );

        List<OrderItem> ocoOrders = new ArrayList<>(5);
        for (BinanceOcoOrderResponse.OrderReport oco : ocoResponse.getOrderReports()) {
            OrderItem ocoItem = conversionService.convert(oco, OrderItem.class);
            if (ocoItem != null) {
                ocoItem.setParentOrderId(entryOrder.getOrderId());
                log.debug("Linked OCO order {} created for parent {}", ocoItem.getOrderId(), entryOrder.getOrderId());
            }
        }
        log.debug("OCO orders created: {}", entryOrder);
        return ocoOrders;
    }

    private OrderItem placeMainOrder(String symbol, BigDecimal price, BigDecimal quantity, OrderSide orderSide) {
        BinanceOrderResponse mainOrderResponse = binanceOrderClient.placeOrder(
                symbol,
                OrderType.LIMIT,
                orderSide,
                quantity,
                price,
                null,
                TimeInForce.GTC
        );

        OrderItem entryOrder = conversionService.convert(mainOrderResponse, OrderItem.class);
        if (entryOrder == null) {
            throw new IllegalStateException("Failed to convert main order response");
        }
        log.debug("Main order created: {}", entryOrder);
        return entryOrder;
    }

    @Override
    @Transactional
    public void cancelOrder(Long orderId) {
        // Cancel main order
        orderRepository.deleteById(orderId);
        log.info("Cancelled order and associated SL/TP orders: {}", orderId);
    }

    @Override
    public Optional<OrderItem> getActiveOrder(String symbol) {
        return orderRepository.findBySymbolAndIsActiveTrue(symbol);
    }

    @Override
    @Transactional
    public void updateOrderStatus(Long orderId, String status) {
        orderRepository.findById(orderId).ifPresent(order -> {
            order.setStatus(status);
            orderRepository.save(order);
            log.info("Updated order status: {} -> {}", orderId, status);
        });
    }

    @Override
    public boolean hasActiveOrder(String symbol) {
        return orderRepository.findBySymbolAndIsActiveTrue(symbol).isPresent();
    }
}
