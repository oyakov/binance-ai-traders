package com.oyakov.binance_trader_macd.metrics;

import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.MeterRegistry;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class TradingMetricsBinder {

    private final TradingMetricsService tradingMetricsService;
    private final MeterRegistry meterRegistry;

    @PostConstruct
    void bindMetrics() {
        Gauge.builder("binance.trader.active.positions", tradingMetricsService,
                        service -> (double) service.countActivePositions())
                .description("Number of currently active (open) Binance MACD trader positions")
                .baseUnit("positions")
                .strongReference(true)
                .register(meterRegistry);

        Gauge.builder("binance.trader.realized.pnl", tradingMetricsService,
                        service -> service.calculateRealizedPnl().doubleValue())
                .description("Realized profit and loss expressed in quote asset for closed Binance MACD trader orders")
                .baseUnit("quote_asset")
                .strongReference(true)
                .register(meterRegistry);
    }
}
