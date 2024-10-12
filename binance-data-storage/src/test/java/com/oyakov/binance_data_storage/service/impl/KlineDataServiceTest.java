package com.oyakov.binance_data_storage.service.impl;

import com.oyakov.binance_data_storage.model.klines.binance.commands.KlineCollectedCommand;
import com.oyakov.binance_data_storage.model.klines.binance.notifications.DataItemWrittenNotification;
import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineItem;
import com.oyakov.binance_data_storage.repository.elastic.KlineElasticRepository;
import com.oyakov.binance_data_storage.repository.jpa.KlinePostgresRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.test.context.ActiveProfiles;

import java.time.LocalDateTime;

import static org.mockito.Mockito.*;

@ActiveProfiles("test")
public class KlineDataServiceTest {

    @Mock
    private KlineElasticRepository klineElasticRepository;

    @Mock
    private KlinePostgresRepository klinePostgresRepository;

    @Mock
    private ApplicationEventPublisher eventPublisher;

    @InjectMocks
    private KlineDataService klineDataService;

    @BeforeEach
    public void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    public void testSaveKlineDataSuccess() {

        KlineCollectedCommand incomingCommand = KlineCollectedCommand.builder()
                .symbol("BTCUSDT")
                .interval("1m")
                .eventTime(1620000000000L)
                .openTime(1620000000000L)
                .open(1000)
                .high(1100)
                .low(900)
                .close(1050)
                .volume(1000)
                .closeTime(1620000999000L)
                .build();

        LocalDateTime eventDisplayTime = LocalDateTime.ofEpochSecond(
                incomingCommand.getEventTime() / 1000,
                0,
                java.time.ZoneOffset.UTC);

        KlineItem expectedItem = KlineItem.builder()
                .symbol(incomingCommand.getSymbol())
                .interval(incomingCommand.getInterval())
                .timestamp(incomingCommand.getEventTime())
                .displayTime(eventDisplayTime)
                .openTime(incomingCommand.getOpenTime())
                .open(incomingCommand.getOpen())
                .high(incomingCommand.getHigh())
                .low(incomingCommand.getLow())
                .close(incomingCommand.getClose())
                .volume(incomingCommand.getVolume())
                .closeTime(incomingCommand.getCloseTime())
                .build();

        when(klineElasticRepository.save(expectedItem)).thenReturn(expectedItem);
        when(klinePostgresRepository.save(expectedItem)).thenReturn(expectedItem);

        klineDataService.saveKlineData(incomingCommand);

        verify(klineElasticRepository, times(1)).save(expectedItem);
        verify(klinePostgresRepository, times(1)).save(expectedItem);

        DataItemWrittenNotification<KlineItem> expectedNotification =
                DataItemWrittenNotification.<KlineItem>builder()
                        .eventType("KlineWritten")
                        .eventTime(incomingCommand.getEventTime())
                        .dataItem(expectedItem)
                        .errorMessage(null)
                        .build();

        // check that eventPublisher.publishEvent was called with expectedNotification
        verify(eventPublisher, times(1)).publishEvent(expectedNotification);
    }

    @Test
    public void testCompensateKlineData() {

        KlineItem klineItem = KlineItem.builder()
                .symbol("BTCUSDT")
                .interval("1m")
                .openTime(1620000000000L)
                .open(1000)
                .high(1100)
                .low(900)
                .close(1050)
                .volume(1000)
                .closeTime(1620000999000L)
                .build();

        DataItemWrittenNotification<KlineItem> klineNotification =
                DataItemWrittenNotification.<KlineItem>builder()
                        .eventType("KlineNotWritten")
                        .eventTime(1620000000000L)
                        .dataItem(klineItem)
                        .errorMessage(null)
                        .build();

        klineDataService.compensateKlineData(klineNotification);

        verify(klineElasticRepository, times(1)).delete(klineItem);
        verify(klinePostgresRepository, times(1)).delete(klineItem);
    }

    @Test
    public void testSaveKlineDataElasticFailure() {

            KlineCollectedCommand incomingCommand = KlineCollectedCommand.builder()
                    .symbol("BTCUSDT")
                    .interval("1m")
                    .eventTime(1620000000000L)
                    .openTime(1620000000000L)
                    .open(1000)
                    .high(1100)
                    .low(900)
                    .close(1050)
                    .volume(1000)
                    .closeTime(1620000999000L)
                    .build();

            KlineItem expectedItem = KlineItem.builder()
                    .symbol(incomingCommand.getSymbol())
                    .interval(incomingCommand.getInterval())
                    .timestamp(incomingCommand.getEventTime())
                    .displayTime(LocalDateTime.ofEpochSecond(incomingCommand.getEventTime() / 1000, 0, java.time.ZoneOffset.UTC))
                    .openTime(incomingCommand.getOpenTime())
                    .open(incomingCommand.getOpen())
                    .high(incomingCommand.getHigh())
                    .low(incomingCommand.getLow())
                    .close(incomingCommand.getClose())
                    .volume(incomingCommand.getVolume())
                    .closeTime(incomingCommand.getCloseTime())
                    .build();

            when(klineElasticRepository.save(expectedItem)).thenThrow(new RuntimeException("Elasticsearch is down"));
            when(klinePostgresRepository.save(expectedItem)).thenReturn(expectedItem);

            klineDataService.saveKlineData(incomingCommand);

            verify(klineElasticRepository, times(1)).save(expectedItem);
            verify(klinePostgresRepository, times(1)).save(expectedItem);

            DataItemWrittenNotification<KlineItem> expectedNotification =
                    DataItemWrittenNotification.<KlineItem>builder()
                            .eventType("KlineNotWritten")
                            .eventTime(incomingCommand.getEventTime())
                            .dataItem(expectedItem)
                            .errorMessage("Elasticsearch is down")
                            .build();

            // check that eventPublisher.publishEvent was called with expectedNotification
            verify(eventPublisher, times(1)).publishEvent(expectedNotification);
    }

    @Test
    public void testSaveKlineDataPostgresFailure() {

            KlineCollectedCommand incomingCommand = KlineCollectedCommand.builder()
                    .symbol("BTCUSDT")
                    .interval("1m")
                    .eventTime(1620000000000L)
                    .openTime(1620000000000L)
                    .open(1000)
                    .high(1100)
                    .low(900)
                    .close(1050)
                    .volume(1000)
                    .closeTime(1620000999000L)
                    .build();

            KlineItem expectedItem = KlineItem.builder()
                    .symbol(incomingCommand.getSymbol())
                    .interval(incomingCommand.getInterval())
                    .timestamp(incomingCommand.getEventTime())
                    .displayTime(LocalDateTime.ofEpochSecond(incomingCommand.getEventTime() / 1000, 0, java.time.ZoneOffset.UTC))
                    .openTime(incomingCommand.getOpenTime())
                    .open(incomingCommand.getOpen())
                    .high(incomingCommand.getHigh())
                    .low(incomingCommand.getLow())
                    .close(incomingCommand.getClose())
                    .volume(incomingCommand.getVolume())
                    .closeTime(incomingCommand.getCloseTime())
                    .build();

            when(klineElasticRepository.save(expectedItem)).thenReturn(expectedItem);
            when(klinePostgresRepository.save(expectedItem)).thenThrow(new RuntimeException("Postgres is down"));

            klineDataService.saveKlineData(incomingCommand);

            verify(klinePostgresRepository, times(1)).save(expectedItem);

            DataItemWrittenNotification<KlineItem> expectedNotification =
                    DataItemWrittenNotification.<KlineItem>builder()
                            .eventType("KlineNotWritten")
                            .eventTime(incomingCommand.getEventTime())
                            .dataItem(expectedItem)
                            .errorMessage("Postgres is down")
                            .build();

            // check that eventPublisher.publishEvent was called with expectedNotification
            verify(eventPublisher, times(1)).publishEvent(expectedNotification);
    }
}
