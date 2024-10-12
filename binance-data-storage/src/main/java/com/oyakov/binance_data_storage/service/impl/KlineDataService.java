package com.oyakov.binance_data_storage.service.impl;

import com.oyakov.binance_data_storage.model.klines.binance.commands.KlineCollectedCommand;
import com.oyakov.binance_data_storage.model.klines.binance.notifications.DataItemWrittenNotification;
import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineItem;
import com.oyakov.binance_data_storage.repository.elastic.KlineElasticRepository;
import com.oyakov.binance_data_storage.repository.jpa.KlinePostgresRepository;
import com.oyakov.binance_data_storage.service.api.KlineDataServiceApi;
import lombok.extern.log4j.Log4j2;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;

/**
 * Service for writing collected kline data to multiple data storage repositories.
 */
@Service
@Log4j2
public class KlineDataService implements KlineDataServiceApi {

    private final ApplicationEventPublisher eventPublisher;

    private final List<CrudRepository<KlineItem, Long>> repositories = new ArrayList<>();

    public KlineDataService(KlineElasticRepository klineElasticRepository, KlinePostgresRepository klinePostgresRepository, ApplicationEventPublisher eventPublisher) {
        this.eventPublisher = eventPublisher;
        repositories.add(klinePostgresRepository);
        repositories.add(klineElasticRepository);
    }

    @Override
    public void saveKlineData(KlineCollectedCommand command) {

        LocalDateTime eventDisplayTime =
                LocalDateTime.ofEpochSecond(
                        command.getEventTime() / 1000,
                        0,
                        ZoneOffset.UTC);

        KlineItem kline = KlineItem.builder()
                .symbol(command.getSymbol())
                .timestamp(command.getEventTime())
                .displayTime(eventDisplayTime)
                .interval(command.getInterval())
                .openTime(command.getOpenTime())
                .open(command.getOpen())
                .high(command.getHigh())
                .low(command.getLow())
                .close(command.getClose())
                .volume(command.getVolume())
                .closeTime(command.getCloseTime())
                .build();

        try {
            for (CrudRepository<KlineItem, Long> repository : repositories) {
                log.info("Saving kline data to repository: {}", repository);
                repository.save(kline);
            }
            log.info("Kline data saved: {}", kline);
            eventPublisher.publishEvent(DataItemWrittenNotification.<KlineItem>builder()
                    .eventType("KlineWritten")
                    .eventTime(command.getEventTime())
                    .dataItem(kline)
                    .errorMessage(null)
                    .build());
        } catch (Exception e) {
            log.error("Failed to save kline data: {}", kline, e);
            eventPublisher.publishEvent(DataItemWrittenNotification.<KlineItem>builder()
                    .eventType("KlineNotWritten")
                    .eventTime(command.getEventTime())
                    .dataItem(kline)
                    .errorMessage(e.getMessage())
                    .build());
        }
    }

    @Override
    public void compensateKlineData(DataItemWrittenNotification<KlineItem> event) {
        for (CrudRepository<KlineItem, Long> repository : repositories) {
            log.info("Rolling back kline data from repository: {}", repository.getClass().getSimpleName());
            repository.delete(event.getDataItem());
        }
    }
}
