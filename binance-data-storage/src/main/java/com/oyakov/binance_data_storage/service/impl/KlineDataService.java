package com.oyakov.binance_data_storage.service.impl;

import com.oyakov.binance_data_storage.mapper.KlineMapper;
import com.oyakov.binance_data_storage.metrics.DataStorageMetrics;
import com.oyakov.binance_data_storage.model.klines.binance.notifications.DataItemWrittenNotification;
import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineFingerprint;
import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineItem;
import com.oyakov.binance_data_storage.repository.elastic.KlineElasticRepository;
import com.oyakov.binance_data_storage.repository.jpa.KlinePostgresRepository;
import com.oyakov.binance_data_storage.service.api.KlineDataServiceApi;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import io.micrometer.core.instrument.Timer;
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

    private final List<CrudRepository<KlineItem, ?>> repositories;
    private final ApplicationEventPublisher eventPublisher;
    private final KlineMapper klineMapper;
    private final Optional<KlineElasticRepository> elasticRepository;
    private final Optional<KlinePostgresRepository> postgresRepository;
    private final DataStorageMetrics metrics;

    public KlineDataService(List<CrudRepository<KlineItem, ?>> repositories,
                          ApplicationEventPublisher eventPublisher,
                          KlineMapper klineMapper,
                          ObjectProvider<KlineElasticRepository> elasticRepositoryProvider,
                          ObjectProvider<KlinePostgresRepository> postgresRepositoryProvider,
                          DataStorageMetrics metrics) {
        this.repositories = repositories;
        this.eventPublisher = eventPublisher;
        this.klineMapper = klineMapper;
        this.elasticRepository = Optional.ofNullable(elasticRepositoryProvider.getIfAvailable());
        this.postgresRepository = Optional.ofNullable(postgresRepositoryProvider.getIfAvailable());
        this.metrics = metrics;
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
        Timer.Sample sample = metrics.startKlineEventProcessing();
        try {
            KlineItem klineItem = klineMapper.toItem(event);
            
            boolean persisted = false;
            boolean postgresSuccess = false;
            boolean elasticsearchSuccess = false;

            try {
                if (postgresRepository.isPresent()) {
                    Timer.Sample postgresSample = metrics.startPostgresSave();
                    try {
                        postgresRepository.get().upsertKline(klineItem);
                        postgresSuccess = true;
                        persisted = true;
                        metrics.incrementPostgresSaves();
                        metrics.setPostgresConnectionStatus(true);
                        log.debug("Successfully saved to PostgreSQL: {}", klineItem);
                    } catch (Exception e) {
                        metrics.incrementPostgresSaveFailures();
                        metrics.setPostgresConnectionStatus(false);
                        log.error("Failed to save to PostgreSQL: {}", klineItem, e);
                        throw e;
                    } finally {
                        metrics.recordPostgresSaveTime(postgresSample);
                    }
                } else {
                    log.warn("Postgres repository is unavailable; skipping persistence for {}", klineItem);
                    metrics.setPostgresConnectionStatus(false);
                }

                if (elasticRepository.isPresent()) {
                    Timer.Sample elasticsearchSample = metrics.startElasticsearchSave();
                    try {
                        elasticRepository.get().save(klineItem);
                        elasticsearchSuccess = true;
                        persisted = true;
                        metrics.incrementElasticsearchSaves();
                        metrics.setElasticsearchConnectionStatus(true);
                        log.debug("Successfully saved to Elasticsearch: {}", klineItem);
                    } catch (Exception e) {
                        metrics.incrementElasticsearchSaveFailures();
                        metrics.setElasticsearchConnectionStatus(false);
                        log.error("Failed to save to Elasticsearch: {}", klineItem, e);
                        throw e;
                    } finally {
                        metrics.recordElasticsearchSaveTime(elasticsearchSample);
                    }
                } else {
                    log.warn("Elasticsearch repository is unavailable; skipping persistence for {}", klineItem);
                    metrics.setElasticsearchConnectionStatus(false);
                }

                if (persisted) {
                    metrics.incrementKlineEventsSaved(event.getSymbol(), event.getInterval());
                    eventPublisher.publishEvent(new DataItemWrittenNotification<>(this, "KlineWritten", event.getEventTime(), klineItem, null, null));
                    log.info("Kline data saved successfully: {}", klineItem);
                } else {
                    String message = "No storage repositories available for kline data persistence";
                    log.error("{}: {}", message, klineItem);
                    metrics.incrementKlineEventsFailed(event.getSymbol(), event.getInterval(), "NoRepositories");
                    eventPublisher.publishEvent(new DataItemWrittenNotification<>(this, "KlineNotWritten", event.getEventTime(), klineItem, message, null));
                }
            } catch (Exception e) {
                log.error("Failed to save kline data: {}", klineItem, e);
                metrics.incrementKlineEventsFailed(event.getSymbol(), event.getInterval(), e.getClass().getSimpleName());
                eventPublisher.publishEvent(new DataItemWrittenNotification<>(this, "KlineNotWritten", event.getEventTime(), klineItem, e.getMessage(), e));
                throw e;
            }
        } finally {
            metrics.recordKlineEventProcessingTime(sample);
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
                    repository -> {
                        try {
                            repository.deleteByFingerprint(fingerprint);
                            log.debug("Successfully rolled back from Elasticsearch: {}", fingerprint);
                        } catch (Exception e) {
                            log.error("Failed to rollback from Elasticsearch: {}", fingerprint, e);
                            throw e;
                        }
                    },
                    () -> log.warn("Elasticsearch repository unavailable during rollback for {}", fingerprint)
            );

            postgresRepository.ifPresentOrElse(
                    repository -> {
                        try {
                            repository.deleteByFingerprint(fingerprint);
                            log.debug("Successfully rolled back from PostgreSQL: {}", fingerprint);
                        } catch (Exception e) {
                            log.error("Failed to rollback from PostgreSQL: {}", fingerprint, e);
                            throw e;
                        }
                    },
                    () -> log.warn("Postgres repository unavailable during rollback for {}", fingerprint)
            );

            if (elasticRepository.isPresent() || postgresRepository.isPresent()) {
                metrics.incrementKlineEventsCompensated();
                log.info("Successfully rolled back kline data with fingerprint: {}", fingerprint);
            } else {
                log.warn("No repositories available to rollback kline data for fingerprint: {}", fingerprint);
            }
        } catch (Exception e) {
            log.error("Failed to rollback kline data with fingerprint: {}", fingerprint, e);
            throw e; // Re-throw to trigger transaction rollback
        }
    }

    @Transactional
    public void compensateKlineDataItem(DataItemWrittenNotification<KlineItem> event) {
        if (event.getDataItem() == null) {
            log.warn("Cannot compensate null kline data");
            return;
        }

        KlineFingerprint fingerprint = event.getDataItem().getFingerprint();
        
        try {
            elasticRepository.ifPresentOrElse(
                    repository -> {
                        try {
                            repository.deleteByFingerprint(fingerprint);
                            log.debug("Successfully rolled back Elasticsearch data with fingerprint: {}", fingerprint);
                        } catch (Exception e) {
                            log.error("Failed to rollback Elasticsearch data with fingerprint: {}", fingerprint, e);
                        }
                    },
                    () -> log.debug("Elasticsearch repository not available for rollback")
            );

            postgresRepository.ifPresentOrElse(
                    repository -> {
                        try {
                            repository.deleteByFingerprint(fingerprint);
                            log.debug("Successfully rolled back PostgreSQL data with fingerprint: {}", fingerprint);
                        } catch (Exception e) {
                            log.error("Failed to rollback PostgreSQL data with fingerprint: {}", fingerprint, e);
                        }
                    },
                    () -> log.debug("PostgreSQL repository not available for rollback")
            );

            if (elasticRepository.isPresent() || postgresRepository.isPresent()) {
                metrics.incrementKlineEventsCompensated();
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
