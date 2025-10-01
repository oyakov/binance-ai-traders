package com.oyakov.binance_trader_macd.domain.signal;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_trader_macd.domain.TradeSignal;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import java.util.stream.StreamSupport;

@Component
@Log4j2
public class MACDSignalAnalyzer implements SignalAnalyzer<KlineEvent> {

    private static final int FAST_PERIOD = 12;
    private static final int SLOW_PERIOD = 26;
    private static final int SIGNAL_PERIOD = 9;
    private static final int SCALE = 10;

    private static final BigDecimal FAST_MULTIPLIER = BigDecimal.valueOf(2)
            .divide(BigDecimal.valueOf(FAST_PERIOD + 1), SCALE, RoundingMode.HALF_UP);
    private static final BigDecimal SLOW_MULTIPLIER = BigDecimal.valueOf(2)
            .divide(BigDecimal.valueOf(SLOW_PERIOD + 1), SCALE, RoundingMode.HALF_UP);
    private static final BigDecimal SIGNAL_MULTIPLIER = BigDecimal.valueOf(2)
            .divide(BigDecimal.valueOf(SIGNAL_PERIOD + 1), SCALE, RoundingMode.HALF_UP);

    @Override
    public Integer getMinDataPointCount() {
        return SLOW_PERIOD + SIGNAL_PERIOD;
    }

    @Override
    public Optional<TradeSignal> tryExtractSignal(Iterable<KlineEvent> klines) {
        List<KlineEvent> sorted = StreamSupport.stream(klines.spliterator(), false)
                .sorted(Comparator.comparingLong(KlineEvent::getCloseTime))
                .toList();

        if (sorted.size() < getMinDataPointCount()) return Optional.empty();

        List<BigDecimal> closes = sorted.stream()
                .map(KlineEvent::getClose)
                .collect(Collectors.toList());

        List<BigDecimal> emaFast = calculateEMA(closes, FAST_PERIOD, FAST_MULTIPLIER);
        List<BigDecimal> emaSlow = calculateEMA(closes, SLOW_PERIOD, SLOW_MULTIPLIER);

        int offset = emaFast.size() - emaSlow.size();
        if (offset < 0) {
            log.error("EMA size mismatch: fast={} slow={}", emaFast.size(), emaSlow.size());
            throw new IllegalStateException("EMA size mismatch");
        }

        List<BigDecimal> alignedFast = emaFast.stream()
                .skip(offset)
                .toList();

        List<BigDecimal> macd = IntStream.range(0, emaSlow.size())
                .mapToObj(i -> alignedFast.get(i)
                        .subtract(emaSlow.get(i))
                        .setScale(SCALE, RoundingMode.HALF_UP))
                .collect(Collectors.toList());

        List<BigDecimal> signalLine = calculateEMA(macd, SIGNAL_PERIOD, SIGNAL_MULTIPLIER);

        if (signalLine.size() < 2 || macd.size() < 2)
            throw new IllegalStateException("Signal size calculated is < 2, can't derive signal");

        int last = signalLine.size() - 1;
        BigDecimal prevDiff = macd.get(last - 1).subtract(signalLine.get(last - 1));
        BigDecimal currDiff = macd.get(last).subtract(signalLine.get(last));
        if (log.isDebugEnabled()) {
            log.debug("Prev diff: {}, Curr diff: {}", prevDiff, currDiff);
        }

        if (prevDiff.compareTo(BigDecimal.ZERO) <= 0 && currDiff.compareTo(BigDecimal.ZERO) > 0) {
            return Optional.of(TradeSignal.BUY);
        } else if (prevDiff.compareTo(BigDecimal.ZERO) >= 0 && currDiff.compareTo(BigDecimal.ZERO) < 0) {
            return Optional.of(TradeSignal.SELL);
        } else {
            return Optional.empty();
        }
    }

    private List<BigDecimal> calculateEMA(List<BigDecimal> values, int period, BigDecimal multiplier) {
        if (values.size() < period) return Collections.emptyList();

        BigDecimal initialAvg = values.stream()
                .limit(period)
                .reduce(BigDecimal.ZERO, BigDecimal::add)
                .divide(BigDecimal.valueOf(period), SCALE, RoundingMode.HALF_UP);

        List<BigDecimal> ema = new ArrayList<>(values.size() - period + 1);
        ema.add(initialAvg);

        values.stream()
                .skip(period)
                .forEach(value -> {
                    BigDecimal prev = ema.getLast();
                    BigDecimal next = value.subtract(prev)
                            .multiply(multiplier)
                            .add(prev)
                            .setScale(SCALE, RoundingMode.HALF_UP);
                    ema.add(next);
                });

        return ema;
    }
}
