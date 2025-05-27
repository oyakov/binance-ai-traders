package com.oyakov.binance_trader_macd.domain.signal;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_trader_macd.domain.TradeSignal;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.stream.*;

@Component
@Log4j2
public class MACDSignalAnalyzer implements SignalAnalyzer<KlineEvent> {

    private static final int FAST_PERIOD = 12;
    private static final int SLOW_PERIOD = 26;
    private static final int SIGNAL_PERIOD = 9;

    @Override
    public Optional<TradeSignal> tryExtractSignal(Iterable<KlineEvent> klines) {
        List<KlineEvent> sorted = StreamSupport.stream(klines.spliterator(), false)
                .sorted(Comparator.comparingLong(KlineEvent::getCloseTime))
                .toList();

        if (sorted.size() < SLOW_PERIOD + SIGNAL_PERIOD) {
            return Optional.empty(); // Not enough data
        }

        List<Double> closes = sorted.stream()
                .map(KlineEvent::getClose)
                .toList();

        List<Double> emaFast = computeEMA(closes, FAST_PERIOD);
        List<Double> emaSlow = computeEMA(closes, SLOW_PERIOD);

        // Align slow EMA with fast EMA
        int offset = emaFast.size() - emaSlow.size();
        if (offset < 0) return Optional.empty(); // Should not happen

        List<Double> alignedEmaFast = emaFast.subList(offset, emaFast.size());

        List<Double> macd = IntStream.range(0, emaSlow.size())
                .mapToObj(i -> alignedEmaFast.get(i) - emaSlow.get(i))
                .toList();

        List<Double> signal = computeEMA(macd, SIGNAL_PERIOD);
        if (signal.size() < 2 || macd.size() < 2) {
            return Optional.empty();
        }

        int last = signal.size() - 1;
        double prevDiff = macd.get(last - 1) - signal.get(last - 1);
        double currDiff = macd.get(last) - signal.get(last);

        if (prevDiff < 0 && currDiff > 0) {
            return Optional.of(TradeSignal.BUY);
        } else if (prevDiff > 0 && currDiff < 0) {
            return Optional.of(TradeSignal.SELL);
        } else {
            return Optional.empty();
        }
    }

    private List<Double> computeEMA(List<Double> values, int period) {
        if (values.size() < period) return Collections.emptyList();

        List<Double> ema = new ArrayList<>();
        double multiplier = 2.0 / (period + 1);
        double previousEma = values.subList(0, period).stream()
                .mapToDouble(Double::doubleValue)
                .average()
                .orElse(0.0);
        ema.add(previousEma);

        for (int i = period; i < values.size(); i++) {
            double current = (values.get(i) - previousEma) * multiplier + previousEma;
            ema.add(current);
            previousEma = current;
        }

        return ema;
    }
}
