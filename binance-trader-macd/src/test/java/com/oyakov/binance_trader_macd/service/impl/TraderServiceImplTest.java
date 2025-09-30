package com.oyakov.binance_trader_macd.service.impl;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_trader_macd.config.MACDTraderConfig;
import com.oyakov.binance_trader_macd.domain.TradeSignal;
import com.oyakov.binance_trader_macd.domain.signal.MACDSignalAnalyzer;
import com.oyakov.binance_trader_macd.service.api.OrderServiceApi;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Optional;
import java.util.stream.StreamSupport;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class TraderServiceImplTest {

    private static final String SYMBOL = "BTCUSDT";

    @Mock
    private MACDSignalAnalyzer macdSignalAnalyzer;
    @Mock
    private OrderServiceApi orderService;

    private TraderServiceImpl traderService;

    @BeforeEach
    void setUp() {
        MACDTraderConfig config = new MACDTraderConfig();
        MACDTraderConfig.Trader trader = config.getTrader();
        trader.setSlidingWindowSize(5);
        trader.setOrderQuantity(BigDecimal.valueOf(0.1));
        trader.setStopLossPercentage(BigDecimal.valueOf(0.98));
        trader.setTakeProfitPercentage(BigDecimal.valueOf(1.05));

        traderService = new TraderServiceImpl(macdSignalAnalyzer, orderService, config);
        ReflectionTestUtils.invokeMethod(traderService, "init");
    }

    @Test
    void shouldNotAttemptSignalExtractionUntilWindowIsFilled() {
        for (int i = 0; i < 4; i++) {
            traderService.onNewKline(kline(i, BigDecimal.valueOf(100 + i)));
        }

        verifyNoInteractions(macdSignalAnalyzer);
        verifyNoInteractions(orderService);
    }

    @Test
    void shouldRequestSignalAndCheckActiveOrderOnFullWindow() {
        when(macdSignalAnalyzer.tryExtractSignal(any())).thenReturn(Optional.empty());
        when(orderService.getActiveOrder(SYMBOL)).thenReturn(Optional.empty());

        for (int i = 0; i < 5; i++) {
            traderService.onNewKline(kline(i, BigDecimal.valueOf(100 + i)));
        }

        ArgumentCaptor<Iterable<KlineEvent>> captor = ArgumentCaptor.forClass(Iterable.class);
        verify(macdSignalAnalyzer, times(1)).tryExtractSignal(captor.capture());
        long capturedSize = StreamSupport.stream(captor.getValue().spliterator(), false).count();
        assertThat(capturedSize).isEqualTo(5);

        verify(orderService).getActiveOrder(SYMBOL);
    }

    @Test
    void shouldSkipOrderLookupWhenSignalIsPresent() {
        when(macdSignalAnalyzer.tryExtractSignal(any())).thenReturn(Optional.of(TradeSignal.BUY));

        for (int i = 0; i < 5; i++) {
            traderService.onNewKline(kline(i, BigDecimal.valueOf(100 + i)));
        }

        verify(macdSignalAnalyzer, times(1)).tryExtractSignal(any());
        verify(orderService, never()).getActiveOrder(anyString());
    }

    private KlineEvent kline(int index, BigDecimal price) {
        BigDecimal rounded = price.setScale(8, RoundingMode.HALF_UP);
        return new KlineEvent(
                "kline",
                (long) index,
                SYMBOL,
                "1m",
                (long) index,
                (long) index,
                rounded,
                rounded,
                rounded,
                rounded,
                BigDecimal.ONE
        );
    }
}
