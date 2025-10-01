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
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.repository.CrudRepository;
import org.springframework.test.context.ActiveProfiles;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.*;

@ActiveProfiles("test")
public class KlineDataServiceTest {

    private static BigDecimal decimal(double value) {
        return BigDecimal.valueOf(value);
    }

    @Mock
    private KlineElasticRepository klineElasticRepository;

    @Mock
    private KlinePostgresRepository klinePostgresRepository;

    @Mock
    private ApplicationEventPublisher eventPublisher;

    @Spy
    private KlineMapper klineMapper;

    @Mock
    private ObjectProvider<KlineElasticRepository> elasticRepositoryProvider;

    @Mock
    private ObjectProvider<KlinePostgresRepository> postgresRepositoryProvider;

    private KlineDataService klineDataService;

    @BeforeEach
    public void setUp() {
        MockitoAnnotations.openMocks(this);
        when(elasticRepositoryProvider.getIfAvailable()).thenReturn(klineElasticRepository);
        when(postgresRepositoryProvider.getIfAvailable()).thenReturn(klinePostgresRepository);

        klineDataService = new KlineDataService(
                List.of(),
                eventPublisher,
                klineMapper,
                elasticRepositoryProvider,
                postgresRepositoryProvider
        );
    }

    @Test
    public void testSaveKlineDataSuccess() {

        KlineEvent incomingCommand = KlineEvent.newBuilder()
                .setSymbol("BTCUSDT")
                .setInterval("1m")
                .setEventType("test")
                .setEventTime(1620000000000L)
                .setOpenTime(1620000000000L)
                .setOpen(decimal(1000.0))
                .setHigh(decimal(1100.0))
                .setLow(decimal(900.0))
                .setClose(decimal(1050.0))
                .setVolume(decimal(1000.0))
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
                .open(incomingCommand.getOpen().doubleValue())
                .high(incomingCommand.getHigh().doubleValue())
                .low(incomingCommand.getLow().doubleValue())
                .close(incomingCommand.getClose().doubleValue())
                .volume(incomingCommand.getVolume().doubleValue())
                .build();

        when(klineElasticRepository.save(expectedItem)).thenReturn(expectedItem);
        doNothing().when(klinePostgresRepository).upsertKline(expectedItem);

        klineDataService.saveKlineData(incomingCommand);

        verify(klineElasticRepository, times(1)).save(expectedItem);
        verify(klinePostgresRepository, times(1)).upsertKline(expectedItem);

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
                .setOpen(decimal(1000.0))
                .setHigh(decimal(1100.0))
                .setLow(decimal(900.0))
                .setClose(decimal(1050.0))
                .setVolume(decimal(1000.0))
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
                .setOpen(decimal(1000.0))
                .setHigh(decimal(1100.0))
                .setLow(decimal(900.0))
                .setClose(decimal(1050.0))
                .setVolume(decimal(1000.0))
                .setCloseTime(1620000999000L)
                .build();

        KlineFingerprint fingerprint = KlineFingerprint.fromKlineEvent(incomingCommand);

        KlineItem expectedItem = KlineItem.builder()
                .fingerprint(fingerprint)
                .timestamp(incomingCommand.getEventTime())
                .displayTime(LocalDateTime.ofEpochSecond(incomingCommand.getEventTime() / 1000, 0, java.time.ZoneOffset.UTC))
                .open(incomingCommand.getOpen().doubleValue())
                .high(incomingCommand.getHigh().doubleValue())
                .low(incomingCommand.getLow().doubleValue())
                .close(incomingCommand.getClose().doubleValue())
                .volume(incomingCommand.getVolume().doubleValue())
                .build();

        when(klineElasticRepository.save(expectedItem)).thenThrow(new RuntimeException("Elasticsearch is down"));
        doNothing().when(klinePostgresRepository).upsertKline(expectedItem);

        klineDataService.saveKlineData(incomingCommand);

        verify(klineElasticRepository, times(1)).save(expectedItem);
        verify(klinePostgresRepository, times(1)).upsertKline(expectedItem);

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
                .setOpen(decimal(1000.0))
                .setHigh(decimal(1100.0))
                .setLow(decimal(900.0))
                .setClose(decimal(1050.0))
                .setVolume(decimal(1000.0))
                .setCloseTime(1620000999000L)
                .build();

        KlineFingerprint fingerprint = KlineFingerprint.fromKlineEvent(incomingCommand);

        KlineItem expectedItem = KlineItem.builder()
                .fingerprint(fingerprint)
                .timestamp(incomingCommand.getEventTime())
                .displayTime(LocalDateTime.ofEpochSecond(incomingCommand.getEventTime() / 1000, 0, java.time.ZoneOffset.UTC))
                .open(incomingCommand.getOpen().doubleValue())
                .high(incomingCommand.getHigh().doubleValue())
                .low(incomingCommand.getLow().doubleValue())
                .close(incomingCommand.getClose().doubleValue())
                .volume(incomingCommand.getVolume().doubleValue())
                .build();

        when(klineElasticRepository.save(expectedItem)).thenReturn(expectedItem);
        doThrow(new RuntimeException("Postgres is down")).when(klinePostgresRepository).upsertKline(expectedItem);

        klineDataService.saveKlineData(incomingCommand);

        verify(klinePostgresRepository, times(1)).upsertKline(expectedItem);
        verify(klineElasticRepository, times(0)).save(expectedItem);

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

    @Test
    public void testSaveKlineDataWithoutRepositoriesPublishesFailure() {
        when(elasticRepositoryProvider.getIfAvailable()).thenReturn(null);
        when(postgresRepositoryProvider.getIfAvailable()).thenReturn(null);

        KlineDataService serviceWithoutRepositories = new KlineDataService(
                List.of(),
                eventPublisher,
                klineMapper,
                elasticRepositoryProvider,
                postgresRepositoryProvider
        );

        KlineEvent incomingCommand = KlineEvent.newBuilder()
                .setSymbol("BTCUSDT")
                .setInterval("1m")
                .setEventType("test")
                .setEventTime(1620000000000L)
                .setOpenTime(1620000000000L)
                .setOpen(decimal(1000.0))
                .setHigh(decimal(1100.0))
                .setLow(decimal(900.0))
                .setClose(decimal(1050.0))
                .setVolume(decimal(1000.0))
                .setCloseTime(1620000999000L)
                .build();

        serviceWithoutRepositories.saveKlineData(incomingCommand);

        verifyNoInteractions(klineElasticRepository, klinePostgresRepository);
        ArgumentCaptor<Object> eventCaptor = ArgumentCaptor.forClass(Object.class);
        verify(eventPublisher).publishEvent(eventCaptor.capture());

        Object publishedEvent = eventCaptor.getValue();
        assertTrue(
                publishedEvent instanceof DataItemWrittenNotification<?> dataNotification &&
                        dataNotification.getEventType().equals("KlineNotWritten") &&
                        Optional.ofNullable(dataNotification.getErrorMessage())
                                .orElse("").contains("No storage repositories")
        );
    }
}
