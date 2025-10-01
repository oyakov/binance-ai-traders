package com.oyakov.binance_data_storage.service.impl;

import com.oyakov.binance_data_storage.mapper.KlineMapper;
import com.oyakov.binance_data_storage.model.klines.binance.notifications.DataItemWrittenNotification;
import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineFingerprint;
import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineItem;
import com.oyakov.binance_data_storage.repository.elastic.KlineElasticRepository;
import com.oyakov.binance_data_storage.repository.jpa.KlinePostgresRepository;
import com.oyakov.binance_data_storage.service.api.KlineDataServiceApi;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import org.springframework.beans.factory.ObjectProvider;
import jakarta.annotation.PostConstruct;
import lombok.extern.log4j.Log4j2;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Optional;

/**
 * Service for writing collected kline data to multiple data storage repositories.
 */
@Service
@Log4j2
public class KlineDataService implements KlineDataServiceApi {

    private final List<CrudRepository<KlineItem, Long>> repositories;
    private final ApplicationEventPublisher eventPublisher;
    private final KlineMapper klineMapper;
    private final Optional<KlineElasticRepository> elasticRepository;
    private final Optional<KlinePostgresRepository> postgresRepository;

    public KlineDataService(List<CrudRepository<KlineItem, Long>> repositories,
                          ApplicationEventPublisher eventPublisher,
                          KlineMapper klineMapper,
                          ObjectProvider<KlineElasticRepository> elasticRepositoryProvider,
                          ObjectProvider<KlinePostgresRepository> postgresRepositoryProvider) {
        this.repositories = repositories;
        this.eventPublisher = eventPublisher;
        this.klineMapper = klineMapper;
        this.elasticRepository = Optional.ofNullable(elasticRepositoryProvider.getIfAvailable());
        this.postgresRepository = Optional.ofNullable(postgresRepositoryProvider.getIfAvailable());
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
        
        boolean persisted = false;

        try {
            if (postgresRepository.isPresent()) {
                postgresRepository.get().upsertKline(klineItem);
                persisted = true;
            } else {
                log.warn("Postgres repository is unavailable; skipping persistence for {}", klineItem);
            }

            if (elasticRepository.isPresent()) {
                elasticRepository.get().save(klineItem);
                persisted = true;
            } else {
                log.warn("Elasticsearch repository is unavailable; skipping persistence for {}", klineItem);
            }

            if (persisted) {
                eventPublisher.publishEvent(new DataItemWrittenNotification<>(this, "KlineWritten", event.getEventTime(), klineItem, null, null));
                log.info("Kline data saved successfully: {}", klineItem);
            } else {
                String message = "No storage repositories available for kline data persistence";
                log.error("{}: {}", message, klineItem);
                eventPublisher.publishEvent(new DataItemWrittenNotification<>(this, "KlineNotWritten", event.getEventTime(), klineItem, message, null));
            }
        } catch (Exception e) {
            log.error("Failed to save kline data: {}", klineItem, e);
            eventPublisher.publishEvent(new DataItemWrittenNotification<>(this, "KlineNotWritten", event.getEventTime(), klineItem, e.getMessage(), e));
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
            elasticRepository.ifPresentOrElse(
                    repository -> repository.deleteByFingerprint(fingerprint),
                    () -> log.warn("Elasticsearch repository unavailable during rollback for {}", fingerprint)
            );

            postgresRepository.ifPresentOrElse(
                    repository -> repository.deleteByFingerprint(fingerprint),
                    () -> log.warn("Postgres repository unavailable during rollback for {}", fingerprint)
            );

            if (elasticRepository.isPresent() || postgresRepository.isPresent()) {
                log.info("Successfully rolled back kline data with fingerprint: {}", fingerprint);
            } else {
                log.warn("No repositories available to rollback kline data for fingerprint: {}", fingerprint);
            }
        } catch (Exception e) {
            log.error("Failed to rollback kline data with fingerprint: {}", fingerprint, e);
            throw e; // Re-throw to trigger transaction rollback
        }
    }
}
