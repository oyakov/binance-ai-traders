package com.oyakov.binance_data_storage.service.impl;

import com.oyakov.binance_data_storage.mapper.KlineMapper;
import com.oyakov.binance_data_storage.model.klines.binance.notifications.DataItemWrittenNotification;
import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineFingerprint;
import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineItem;
import com.oyakov.binance_data_storage.repository.elastic.KlineElasticRepository;
import com.oyakov.binance_data_storage.repository.jpa.KlinePostgresRepository;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;
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

    @Spy
    private KlineMapper klineMapper;

    @InjectMocks
    private KlineDataService klineDataService;

    @BeforeEach
    public void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    public void testSaveKlineDataSuccess() {

        KlineEvent incomingCommand = KlineEvent.newBuilder()
                .setSymbol("BTCUSDT")
                .setInterval("1m")
                .setEventType("test")
                .setEventTime(1620000000000L)
                .setOpenTime(1620000000000L)
                .setOpen(1000.0)
                .setHigh(1100.0)
                .setLow(900.0)
                .setClose(1050.0)
                .setVolume(1000.0)
                .setCloseTime(1620000999000L)
                .build();

        LocalDateTime eventDisplayTime = LocalDateTime.ofEpochSecond(
                incomingCommand.getEventTime() / 1000,
                0,
                java.time.ZoneOffset.UTC);


        KlineFingerprint fingerprint = KlineFingerprint.fromKlineEvent(incomingCommand);

        KlineItem expectedItem = KlineItem.builder()
                .fingerprint(fingerprint)
                .timestamp(incomingCommand.getEventTime())
                .displayTime(eventDisplayTime)
                .open(incomingCommand.getOpen())
                .high(incomingCommand.getHigh())
                .low(incomingCommand.getLow())
                .close(incomingCommand.getClose())
                .volume(incomingCommand.getVolume())
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
        KlineEvent klineEvent = KlineEvent.newBuilder()
                .setSymbol("BTCUSDT")
                .setInterval("1m")
                .setEventType("test")
                .setEventTime(1620000000000L)
                .setOpenTime(1620000000000L)
                .setOpen(1000.0)
                .setHigh(1100.0)
                .setLow(900.0)
                .setClose(1050.0)
                .setVolume(1000.0)
                .setCloseTime(1620000999000L)
                .build();

        DataItemWrittenNotification<KlineEvent> klineNotification =
                DataItemWrittenNotification.<KlineEvent>builder()
                        .eventType("KlineNotWritten")
                        .eventTime(1620000000000L)
                        .dataItem(klineEvent)
                        .errorMessage(null)
                        .build();

        klineDataService.compensateKlineData(klineNotification);

        KlineFingerprint expectedFingerprint = KlineFingerprint.fromKlineEvent(klineEvent);

        verify(klineElasticRepository, times(1)).deleteByFingerprint(expectedFingerprint);
        verify(klinePostgresRepository, times(1)).deleteByFingerprint(expectedFingerprint);
    }

    @Test
    public void testSaveKlineDataElasticFailure() {
            KlineEvent incomingCommand = KlineEvent.newBuilder()
                    .setSymbol("BTCUSDT")
                    .setInterval("1m")
                    .setEventType("test")
                    .setEventTime(1620000000000L)
                    .setOpenTime(1620000000000L)
                    .setOpen(1000.0)
                    .setHigh(1100.0)
                    .setLow(900.0)
                    .setClose(1050.0)
                    .setVolume(1000.0)
                    .setCloseTime(1620000999000L)
                    .build();

            KlineFingerprint fingerprint = KlineFingerprint.fromKlineEvent(incomingCommand);

            KlineItem expectedItem = KlineItem.builder()
                    .fingerprint(fingerprint)
                    .timestamp(incomingCommand.getEventTime())
                    .displayTime(LocalDateTime.ofEpochSecond(incomingCommand.getEventTime() / 1000, 0, java.time.ZoneOffset.UTC))
                    .open(incomingCommand.getOpen())
                    .high(incomingCommand.getHigh())
                    .low(incomingCommand.getLow())
                    .close(incomingCommand.getClose())
                    .volume(incomingCommand.getVolume())
                    .build();

            when(klineElasticRepository.save(expectedItem)).thenThrow(new RuntimeException("Elasticsearch is down"));
            when(klinePostgresRepository.save(expectedItem)).thenReturn(expectedItem);

            klineDataService.saveKlineData(incomingCommand);

            verify(klineElasticRepository, times(1)).save(expectedItem);
            verify(klinePostgresRepository, times(0)).save(expectedItem);

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
            KlineEvent incomingCommand = KlineEvent.newBuilder()
                    .setSymbol("BTCUSDT")
                    .setInterval("1m")
                    .setEventType("test")
                    .setEventTime(1620000000000L)
                    .setOpenTime(1620000000000L)
                    .setOpen(1000.0)
                    .setHigh(1100.0)
                    .setLow(900.0)
                    .setClose(1050.0)
                    .setVolume(1000.0)
                    .setCloseTime(1620000999000L)
                    .build();

        KlineFingerprint fingerprint = KlineFingerprint.fromKlineEvent(incomingCommand);

            KlineItem expectedItem = KlineItem.builder()
                    .fingerprint(fingerprint)
                    .timestamp(incomingCommand.getEventTime())
                    .displayTime(LocalDateTime.ofEpochSecond(incomingCommand.getEventTime() / 1000, 0, java.time.ZoneOffset.UTC))
                    .open(incomingCommand.getOpen())
                    .high(incomingCommand.getHigh())
                    .low(incomingCommand.getLow())
                    .close(incomingCommand.getClose())
                    .volume(incomingCommand.getVolume())
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
