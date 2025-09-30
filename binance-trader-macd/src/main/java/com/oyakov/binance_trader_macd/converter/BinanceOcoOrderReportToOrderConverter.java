package com.oyakov.binance_trader_macd.converter;

import com.oyakov.binance_trader_macd.domain.OrderSide;
import com.oyakov.binance_trader_macd.domain.OrderState;
import com.oyakov.binance_trader_macd.domain.OrderType;
import com.oyakov.binance_trader_macd.domain.TimeInForce;
import com.oyakov.binance_trader_macd.model.order.binance.storage.OrderItem;
import com.oyakov.binance_trader_macd.rest.dto.BinanceOcoOrderResponse;
import org.springframework.core.convert.converter.Converter;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.Optional;

@Component
public class BinanceOcoOrderReportToOrderConverter implements Converter<BinanceOcoOrderResponse.OrderReport, OrderItem> {

    private static final String EMPTY_JSON_ARRAY = "[]";

    @Override
    public OrderItem convert(BinanceOcoOrderResponse.OrderReport source) {
        if (source == null) {
            return null;
        }

        Long transactTime = Optional.ofNullable(source.getTransactTime()).orElse(0L);
        Long workingTime = Optional.ofNullable(source.getWorkingTime()).orElse(transactTime);

        return OrderItem.builder()
                .symbol(Optional.ofNullable(source.getSymbol()).orElse(""))
                .orderId(source.getOrderId())
                .orderListId(Optional.ofNullable(source.getOrderListId()).map(Math::toIntExact).orElse(0))
                .clientOrderId(Optional.ofNullable(source.getClientOrderId()).orElse(""))
                .transactTime(transactTime)
                .displayTransactTime(toLocalDateTime(transactTime))
                .price(defaultBigDecimal(source.getPrice()))
                .origQty(defaultBigDecimal(source.getOrigQty()))
                .executedQty(defaultBigDecimal(source.getExecutedQty()))
                .cummulativeQuoteQty(defaultBigDecimal(source.getCummulativeQuoteQty()))
                .status(resolveOrderState(source.getStatus()))
                .timeInForce(Optional.ofNullable(source.getTimeInForce()).orElse(TimeInForce.GTC.name()))
                .type(resolveOrderType(source.getType()))
                .side(resolveOrderSide(source.getSide()))
                .workingTime(workingTime)
                .displayWorkingTime(toLocalDateTime(workingTime))
                .selfTradePreventionMode(Optional.ofNullable(source.getSelfTradePreventionMode()).orElse("NONE"))
                .fills(EMPTY_JSON_ARRAY)
                .build();
    }

    private static LocalDateTime toLocalDateTime(Long epochMillis) {
        return Instant.ofEpochMilli(epochMillis).atZone(ZoneOffset.UTC).toLocalDateTime();
    }

    private static BigDecimal defaultBigDecimal(BigDecimal value) {
        return value != null ? value : BigDecimal.ZERO;
    }

    private static OrderState resolveOrderState(String status) {
        return Optional.ofNullable(OrderState.ofBinanceState(status)).orElse(OrderState.NEW);
    }

    private static OrderType resolveOrderType(String type) {
        return Optional.ofNullable(type).map(OrderType::valueOf).orElse(OrderType.LIMIT);
    }

    private static OrderSide resolveOrderSide(String side) {
        return Optional.ofNullable(side).map(OrderSide::valueOf).orElse(OrderSide.BUY);
    }
}
