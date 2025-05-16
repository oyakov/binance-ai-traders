package com.oyakov.binance_data_storage.service.impl;

import com.oyakov.binance_data_storage.mapper.KlineMapper;
import com.oyakov.binance_data_storage.model.klines.binance.notifications.DataItemWrittenNotification;
import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineFingerprint;
import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineItem;
import com.oyakov.binance_data_storage.repository.elastic.KlineElasticRepository;
import com.oyakov.binance_data_storage.repository.jpa.KlinePostgresRepository;
import com.oyakov.binance_data_storage.service.api.KlineDataServiceApi;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import jakarta.annotation.PostConstruct;
import lombok.extern.log4j.Log4j2;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.List;

/**
 * Service for writing collected kline data to multiple data storage repositories.
 */
@Service
@Log4j2
public class KlineDataService implements KlineDataServiceApi {

    private final List<CrudRepository<KlineItem, Long>> repositories;
    private final ApplicationEventPublisher eventPublisher;
    private final KlineMapper klineMapper;
    private final KlineElasticRepository elasticRepository;
    private final KlinePostgresRepository postgresRepository;

    public KlineDataService(List<CrudRepository<KlineItem, Long>> repositories,
                          ApplicationEventPublisher eventPublisher,
                          KlineMapper klineMapper,
                          KlineElasticRepository elasticRepository,
                          KlinePostgresRepository postgresRepository) {
        this.repositories = repositories;
        this.eventPublisher = eventPublisher;
        this.klineMapper = klineMapper;
        this.elasticRepository = elasticRepository;
        this.postgresRepository = postgresRepository;
    }

    @PostConstruct
    public void init() {
        log.info("KlineDataService initialized with repositories: {}", repositories);
        KlineFingerprint testFingerprint = KlineFingerprint.builder()
                .symbol("BTCUSDT")
                .interval("1m")
                .closeTime(1620000999000L)
                .openTime(1620000000000L)
                .build();

        KlineItem testItem = KlineItem.builder()
                .fingerprint(testFingerprint)
                .timestamp(1620000000000L)
                .displayTime(LocalDateTime.ofEpochSecond(1620000000, 0, ZoneOffset.UTC))
                .open(1000)
                .high(1100)
                .low(900)
                .close(1050)
                .volume(1000)
                .build();

        repositories.forEach(repository -> {
            try {
                repository.save(testItem);
                repository.delete(testItem);
            } catch (Exception e) {
                log.error("Failed to initialize repository: {}", repository, e);
            }
        });
    }

    @Override
    @Transactional
    public void saveKlineData(KlineEvent event) {
        KlineItem klineItem = klineMapper.toItem(event);
        
        try {
            postgresRepository.upsertKline(klineItem);
            elasticRepository.save(klineItem);
            eventPublisher.publishEvent(DataItemWrittenNotification.<KlineItem>builder()
                    .eventType("KlineWritten")
                    .eventTime(event.getEventTime())
                    .dataItem(klineItem)
                    .build());
            log.info("Kline data saved successfully: {}", klineItem);
        } catch (Exception e) {
            log.error("Failed to save kline data: {}", klineItem, e);
            eventPublisher.publishEvent(DataItemWrittenNotification.<KlineItem>builder()
                    .eventType("KlineNotWritten")
                    .eventTime(event.getEventTime())
                    .dataItem(klineItem)
                    .errorMessage(e.getMessage())
                    .build());
        }
    }

    @Override
    @Transactional
    public void compensateKlineData(DataItemWrittenNotification<KlineEvent> event) {
        if (event.getDataItem() == null) {
            log.warn("Cannot compensate null kline data");
            return;
        }

        KlineFingerprint fingerprint = KlineFingerprint.fromKlineEvent(event.getDataItem());
        
        try {
            elasticRepository.deleteByFingerprint(fingerprint);
            postgresRepository.deleteByFingerprint(fingerprint);
            
            log.info("Successfully rolled back kline data with fingerprint: {}", fingerprint);
        } catch (Exception e) {
            log.error("Failed to rollback kline data with fingerprint: {}", fingerprint, e);
            throw e; // Re-throw to trigger transaction rollback
        }
    }
}
