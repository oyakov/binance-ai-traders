package com.oyakov.binance_trader_macd.backtest;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_shared_model.backtest.BacktestDataset;
import com.oyakov.binance_trader_macd.config.MACDTraderConfig;
import com.oyakov.binance_trader_macd.domain.signal.MACDSignalAnalyzer;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@Log4j2
@RequiredArgsConstructor
public class BacktestEngine {

    private final MACDSignalAnalyzer macdSignalAnalyzer;
    private final MACDTraderConfig traderConfig;
    private final BacktestMetricsCalculator metricsCalculator;

    public BacktestMetrics run(BacktestDataset dataset) {
        log.info("Running backtest for dataset {}", dataset.getName());
        BacktestOrderService orderService = new BacktestOrderService();
        BacktestTraderEngine traderEngine = new BacktestTraderEngine(
                macdSignalAnalyzer,
                orderService,
                traderConfig.getTrader());

        List<KlineEvent> klines = dataset.getKlines();
        klines.forEach(traderEngine::onNewKline);

        List<SimulatedTrade> trades = orderService.getClosedTrades();
        log.info("Backtest finished for dataset {} - trades executed: {}", dataset.getName(), trades.size());
        return metricsCalculator.calculate(dataset.getName(), trades);
    }
}
