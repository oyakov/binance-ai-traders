package com.oyakov.binance_data_storage.kafka.kafka.consumer;

import com.oyakov.binance_data_storage.kafka.consumer.KafkaConsumerService;
import com.oyakov.binance_data_storage.mapper.KlineMapper;
import com.oyakov.binance_data_storage.model.klines.binance.notifications.DataItemWrittenNotification;
import com.oyakov.binance_data_storage.repository.elastic.KlineElasticRepository;
import com.oyakov.binance_data_storage.service.impl.KlineDataService;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import java.math.BigDecimal;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.test.context.EmbeddedKafka;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.ContextConfiguration;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.Mockito.verify;

@ActiveProfiles("test")
@SpringBootTest
@EnableAutoConfiguration
@ContextConfiguration(classes = {KafkaTestConfig.class, KafkaConsumerService.class, KlineDataService.class, KlineMapper.class, KlineElasticRepository.class})
@EmbeddedKafka(partitions = 1, topics = {"binance-kline", "binance-notification"})
public class KafkaConsumerServiceIntegrationTest  {

    @Mock
    private ApplicationEventPublisher eventPublisher;

    @Autowired
    private KafkaTemplate<String, KlineEvent> kafkaTemplate;

    @Autowired
    @InjectMocks

    private KafkaConsumerService kafkaConsumerService;

    @Mock
    private KlineElasticRepository klineElasticRepository;

    @Mock
    private KlineMapper klineMapper;

    @Mock
    private KlineDataService klineDataService;

    @Test
    public void testKafkaListener() throws InterruptedException {
        KlineEvent command = KlineEvent.newBuilder()
                .setEventType("kline")
                .setEventTime(System.currentTimeMillis())
                .setSymbol("BTCUSDT")
                .setInterval("1m")
                .setOpenTime(System.currentTimeMillis())
                .setCloseTime(System.currentTimeMillis() + 60000)
                .setOpen(new BigDecimal("50000.0"))
                .setHigh(new BigDecimal("51000.0"))
                .setLow(new BigDecimal("49000.0"))
                .setClose(new BigDecimal("50500.0"))
                .setVolume(new BigDecimal("100.0"))
                .build();
        kafkaTemplate.send("binance-kline", command);

        // Add a delay to ensure the message is consumed
        Thread.sleep(2000);

        // Verify the event was published
        // The service publishes a DataItemWrittenNotification, not the original KlineEvent
        verify(eventPublisher).publishEvent(argThat(event -> 
            event instanceof DataItemWrittenNotification && 
            "KlineWritten".equals(((DataItemWrittenNotification<?>) event).getEventType())
        ));
    }
}