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
import java.util.stream.Stream;
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
                .collect(Collectors.toList());

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
                .collect(Collectors.toList());

        List<BigDecimal> macd = IntStream.range(0, emaSlow.size())
                .mapToObj(i -> alignedFast.get(i)
                        .subtract(emaSlow.get(i))
                        .setScale(SCALE, RoundingMode.HALF_UP))
                .collect(Collectors.toList());

        List<BigDecimal> signalLine = calculateEMA(macd, SIGNAL_PERIOD, SIGNAL_MULTIPLIER);

        if (signalLine.size() < 2 || macd.size() < 2) return Optional.empty();

        int last = signalLine.size() - 1;
        BigDecimal prevDiff = macd.get(last - 1).subtract(signalLine.get(last - 1));
        BigDecimal currDiff = macd.get(last).subtract(signalLine.get(last));

        return Stream.of(
                        new AbstractMap.SimpleEntry<>(prevDiff, currDiff)
                ).map(entry -> {
                    BigDecimal pd = entry.getKey();
                    BigDecimal cd = entry.getValue();
                    if (pd.compareTo(BigDecimal.ZERO) <= 0 && cd.compareTo(BigDecimal.ZERO) > 0) {
                        return TradeSignal.BUY;
                    } else if (pd.compareTo(BigDecimal.ZERO) >= 0 && cd.compareTo(BigDecimal.ZERO) < 0) {
                        return TradeSignal.SELL;
                    } else {
                        return null;
                    }
                }).filter(Objects::nonNull)
                .findFirst();
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
                    BigDecimal prev = ema.get(ema.size() - 1);
                    BigDecimal next = value.subtract(prev)
                            .multiply(multiplier)
                            .add(prev)
                            .setScale(SCALE, RoundingMode.HALF_UP);
                    ema.add(next);
                });

        return ema;
    }
}
