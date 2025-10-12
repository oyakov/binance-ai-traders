package com.oyakov.binance_trader_macd.testnet;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import java.util.stream.StreamSupport;

/**
 * Helper class to calculate MACD values and intermediate EMAs
 */
public class MACDCalculationHelper {

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

    @Data
    @Builder
    public static class MACDValues {
        private BigDecimal emaFast;
        private BigDecimal emaSlow;
        private BigDecimal macdLine;
        private BigDecimal signalLine;
        private BigDecimal histogram;
        private BigDecimal currentPrice;
        private String signalStrength;
    }

    /**
     * Calculate MACD values from kline data
     */
    public static MACDValues calculateMACD(List<KlineEvent> klines) {
        if (klines == null || klines.isEmpty()) {
            return null;
        }

        List<KlineEvent> sorted = klines.stream()
                .sorted(Comparator.comparingLong(KlineEvent::getCloseTime))
                .toList();

        if (sorted.size() < SLOW_PERIOD + SIGNAL_PERIOD) {
            return null;
        }

        List<BigDecimal> closes = sorted.stream()
                .map(KlineEvent::getClose)
                .collect(Collectors.toList());

        List<BigDecimal> emaFast = calculateEMA(closes, FAST_PERIOD, FAST_MULTIPLIER);
        List<BigDecimal> emaSlow = calculateEMA(closes, SLOW_PERIOD, SLOW_MULTIPLIER);

        int offset = emaFast.size() - emaSlow.size();
        if (offset < 0) {
            return null;
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

        if (signalLine.isEmpty() || macd.isEmpty()) {
            return null;
        }

        int last = signalLine.size() - 1;
        BigDecimal macdValue = macd.get(last);
        BigDecimal signalValue = signalLine.get(last);
        BigDecimal histogram = macdValue.subtract(signalValue);
        BigDecimal currentPrice = sorted.get(sorted.size() - 1).getClose();

        // Get the latest EMA values
        BigDecimal latestEmaFast = emaFast.get(emaFast.size() - 1);
        BigDecimal latestEmaSlow = emaSlow.get(emaSlow.size() - 1);

        return MACDValues.builder()
                .emaFast(latestEmaFast)
                .emaSlow(latestEmaSlow)
                .macdLine(macdValue)
                .signalLine(signalValue)
                .histogram(histogram)
                .currentPrice(currentPrice)
                .signalStrength(calculateSignalStrength(histogram))
                .build();
    }

    private static String calculateSignalStrength(BigDecimal histogram) {
        if (histogram == null) {
            return "NONE";
        }

        double absHistogram = histogram.abs().doubleValue();

        if (absHistogram > 100) {
            return "STRONG";
        } else if (absHistogram > 50) {
            return "MODERATE";
        } else if (absHistogram > 10) {
            return "WEAK";
        } else {
            return "NONE";
        }
    }

    private static List<BigDecimal> calculateEMA(List<BigDecimal> values, int period, BigDecimal multiplier) {
        if (values.size() < period) {
            return List.of();
        }

        BigDecimal initialAvg = values.stream()
                .limit(period)
                .reduce(BigDecimal.ZERO, BigDecimal::add)
                .divide(BigDecimal.valueOf(period), SCALE, RoundingMode.HALF_UP);

        List<BigDecimal> ema = new ArrayList<>(values.size() - period + 1);
        ema.add(initialAvg);

        values.stream()
                .skip(period)
                .forEach(value -> {
                    BigDecimal previousEma = ema.get(ema.size() - 1);
                    BigDecimal newEma = value.subtract(previousEma)
                            .multiply(multiplier)
                            .add(previousEma)
                            .setScale(SCALE, RoundingMode.HALF_UP);
                    ema.add(newEma);
                });

        return ema;
    }
}

