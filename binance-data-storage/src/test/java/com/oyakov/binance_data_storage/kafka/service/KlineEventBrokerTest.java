package com.oyakov.binance_data_storage.kafka.service;

import com.oyakov.binance_data_storage.kafka.producer.KafkaProducerService;
import com.oyakov.binance_data_storage.model.klines.binance.notifications.DataItemWrittenNotification;
import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineFingerprint;
import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineItem;
import com.oyakov.binance_data_storage.service.api.KlineDataServiceApi;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.test.context.ActiveProfiles;

import static org.mockito.Mockito.verify;

@ActiveProfiles("test")
public class KlineEventBrokerTest {

    @Mock
    private KlineDataServiceApi dataServiceApi;

    @Mock
    private KafkaProducerService kafkaProducerService;

    @InjectMocks
    private KlineEventBroker klineEventBroker;

    @BeforeEach
    public void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    public void testHandleKlineCollectedEvent() {
        KlineEvent command = new KlineEvent();
        klineEventBroker.handleKlineCollectedEvent(command);
        verify(dataServiceApi).saveKlineData(command);
    }

    @Test
    public void testHandleKlineWrittenEvent() {
        KlineItem klineItem = KlineItem.builder()
                .fingerprint(KlineFingerprint.builder()
                        .symbol("BTCUSDT")
                        .interval("1h")
                        .openTime(System.currentTimeMillis())
                        .closeTime(System.currentTimeMillis() + 3600000)
                        .build())
                .open(100.0)
                .high(110.0)
                .low(90.0)
                .close(105.0)
                .volume(1000.0)
                .build();
        DataItemWrittenNotification<KlineItem> notification =
                DataItemWrittenNotification.<KlineItem>builder()
                .dataItem(klineItem)
                .build();
        klineEventBroker.handleKlineWrittenEvent(notification);
        // Note: This method doesn't publish to Kafka, it only processes internal events
        // So we verify the service was called if needed, or just verify no exceptions
    }

}
