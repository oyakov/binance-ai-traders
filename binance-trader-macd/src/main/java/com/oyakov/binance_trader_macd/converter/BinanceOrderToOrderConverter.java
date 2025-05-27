package com.oyakov.binance_trader_macd.converter;

import com.oyakov.binance_trader_macd.domain.OrderSide;
import com.oyakov.binance_trader_macd.domain.OrderState;
import com.oyakov.binance_trader_macd.domain.OrderType;
import com.oyakov.binance_trader_macd.model.order.binance.storage.OrderItem;
import com.oyakov.binance_trader_macd.rest.dto.BinanceOrderResponse;
import org.springframework.core.convert.converter.Converter;
import org.springframework.stereotype.Component;

@Component
public class BinanceOrderToOrderConverter implements Converter<BinanceOrderResponse, OrderItem> {
    @Override
    public OrderItem convert(BinanceOrderResponse response) {
        return OrderItem.builder()
                .symbol(response.getSymbol())
                .orderId(response.getOrderId())
                .clientOrderId(response.getClientOrderId())
                .type(OrderType.valueOf(response.getType()))
                .side(OrderSide.valueOf(response.getSide()))
                .price(response.getPrice())
                .origQty(response.getOrigQty())
                .status(OrderState.ofBinanceState(response.getStatus()))
                .timeInForce(response.getTimeInForce())
                .transactTime(response.getTransactTime())
                .build();
    }
}
