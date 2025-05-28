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
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
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

    @Override
    @Transactional
    public OrderItem createOrderGroup(String symbol,
                                      BigDecimal entryPrice,
                                      BigDecimal quantity,
                                      OrderSide orderSide,
                                      BigDecimal stopLossPrice,
                                      BigDecimal takeProfitPrice) throws OrderCapacityReachedException {

        if (hasActiveOrder(symbol)) {
            log.warn("Cannot create new order - active order exists for symbol: %s".formatted(symbol));
            throw new IllegalStateException("Active order exists for symbol: %s".formatted(symbol));
        }

        // 1. Place the main limit order
        OrderItem entryOrder = placeMainOrder(symbol, entryPrice, quantity, orderSide);

        // 2. Place SLTP OCO order
        List<OrderItem> ocoOrders = placeSLTP_OCO(symbol, quantity, stopLossPrice, takeProfitPrice, orderSide.oppositeSide(), entryOrder);

        // 3. Persist all the orders
        orderRepository.saveAll(ocoOrders);
        orderRepository.save(entryOrder);

        return entryOrder;
    }

    private List<OrderItem> placeSLTP_OCO(String symbol, BigDecimal quantity,
                                          BigDecimal stopLoss, BigDecimal takeProfit,
                                          OrderSide ocoSide, OrderItem entryOrder) {
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
        log.info("Placing main order for symbol %s price %s, quantity %s side %s".formatted(symbol, price, quantity, orderSide));
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
    public void closeOrderWithState(Long orderId, OrderState state) {
        orderRepository.findById(orderId).ifPresentOrElse(
                orderItem -> {
                    switch (orderItem.getStatus()) {
                        case NEW, ACTIVE, PENDING -> {
                            if (binanceOrderClient.cancelOrder(orderItem.getSymbol(), orderId)) {
                                orderRepository.updateOrderState(orderId, state);
                            }
                        }
                        default -> log.info("Tried to cancel the order that is already closed");
                    }
                },
                () -> log.warn("Order Id not found. Trying to close an unmanaged order")
        );
    }

    @Override
    public Optional<OrderItem> getActiveOrder(String symbol) {
        return orderRepository.findBySymbolAndStatusEquals(symbol, OrderState.ACTIVE);
    }

    @Override
    public boolean hasActiveOrder(String symbol) {
        return orderRepository.findBySymbolAndStatusEquals(symbol, OrderState.ACTIVE).isPresent();
    }
}
