package com.oyakov.binance_trader_macd.domain.signal;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_trader_macd.domain.TradeSignal;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.stream.StreamSupport;

@Component
@Log4j2
public class MACDSignalAnalyzer implements SignalAnalyzer<KlineEvent> {

    private static final int FAST_PERIOD = 12;
    private static final int SLOW_PERIOD = 26;
    private static final int SIGNAL_PERIOD = 9;

    private static final double FAST_MULTIPLIER = 2.0 / (FAST_PERIOD + 1);
    private static final double SLOW_MULTIPLIER = 2.0 / (SLOW_PERIOD + 1);
    private static final double SIGNAL_MULTIPLIER = 2.0 / (SIGNAL_PERIOD + 1);

    @Override
    public Integer getMinDataPointCount() {
        return SLOW_PERIOD + SIGNAL_PERIOD;
    }

    @Override
    public Optional<TradeSignal> tryExtractSignal(Iterable<KlineEvent> klines) {
        List<KlineEvent> sorted = sortByCloseTime(klines);
        if (sorted.size() < getMinDataPointCount()) {
            return Optional.empty();
        }

        List<Double> closes = extractCloses(sorted);
        List<Double> emaFast = calculateEMA(closes, FAST_PERIOD, FAST_MULTIPLIER);
        List<Double> emaSlow = calculateEMA(closes, SLOW_PERIOD, SLOW_MULTIPLIER);

        int offset = emaFast.size() - emaSlow.size();
        if (offset < 0) {
            log.error("EMA size mismatch: fast={} slow={}", emaFast.size(), emaSlow.size());
            throw new IllegalStateException("EMA size mismatch");
        }

        List<Double> alignedFast = emaFast.subList(offset, emaFast.size());
        List<Double> macd = calculateMACD(emaSlow, alignedFast);
        List<Double> signalLine = calculateEMA(macd, SIGNAL_PERIOD, SIGNAL_MULTIPLIER);

        if (signalLine.size() < 2 || macd.size() < 2) {
            return Optional.empty();
        }

        return detectCrossover(macd, signalLine);
    }

    private List<KlineEvent> sortByCloseTime(Iterable<KlineEvent> klines) {
        return StreamSupport.stream(klines.spliterator(), false)
                .sorted(Comparator.comparingLong(KlineEvent::getCloseTime))
                .toList();
    }

    private List<Double> extractCloses(List<KlineEvent> data) {
        return data.stream()
                .map(KlineEvent::getClose)
                .toList();
    }

    private List<Double> calculateEMA(List<Double> values, int period, double multiplier) {
        if (values.size() < period) {
            return Collections.emptyList();
        }

        List<Double> ema = new ArrayList<>(values.size() - period + 1);
        double prev = values.subList(0, period).stream()
                .mapToDouble(Double::doubleValue)
                .average()
                .orElse(0.0);
        ema.add(prev);

        for (int i = period; i < values.size(); i++) {
            prev = (values.get(i) - prev) * multiplier + prev;
            ema.add(prev);
        }

        return ema;
    }

    private List<Double> calculateMACD(List<Double> emaSlow, List<Double> alignedFast) {
        int size = emaSlow.size();
        List<Double> macd = new ArrayList<>(size);
        for (int i = 0; i < size; i++) {
            macd.add(alignedFast.get(i) - emaSlow.get(i));
        }
        return macd;
    }

    private Optional<TradeSignal> detectCrossover(List<Double> macd, List<Double> signalLine) {
        int last = signalLine.size() - 1;
        double prevDiff = macd.get(last - 1) - signalLine.get(last - 1);
        double currDiff = macd.get(last) - signalLine.get(last);
        boolean crossesAbove = prevDiff <= 0 && currDiff > 0;
        boolean crossesBelow = prevDiff >= 0 && currDiff < 0;

        if (crossesAbove) {
            return Optional.of(TradeSignal.BUY);
        } else if (crossesBelow) {
            return Optional.of(TradeSignal.SELL);
        } else {
            return Optional.empty();
        }
    }

    // TODO: for higher precision, switch to BigDecimal-based EMAs and adjust KlineEvent schema accordingly
}
