package com.oyakov.binance_data_storage.kafka.service;

import com.oyakov.binance_data_storage.kafka.producer.KafkaProducerService;
import com.oyakov.binance_data_storage.model.klines.binance.notifications.DataItemWrittenNotification;
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
        KlineEvent klineEvent = new KlineEvent();
        DataItemWrittenNotification<KlineEvent> notification =
                DataItemWrittenNotification.<KlineEvent>builder()
                .dataItem(klineEvent)
                .build();
        klineEventBroker.handleKlineWrittenEvent(notification);
        verify(kafkaProducerService).sendCommand("binance-notification", notification.getDataItem());
    }

}
