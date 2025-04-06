package com.oyakov.binance_data_storage.broker.app;

import com.oyakov.binance_data_storage.broker.kafka.producer.KafkaProducerService;
import com.oyakov.binance_data_storage.model.klines.binance.commands.KlineCollectedCommand;
import com.oyakov.binance_data_storage.model.klines.binance.notifications.DataItemWrittenNotification;
import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineItem;
import com.oyakov.binance_data_storage.service.api.KlineDataServiceApi;
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
        KlineCollectedCommand command = new KlineCollectedCommand();
        klineEventBroker.handleKlineCollectedEvent(command);
        verify(dataServiceApi).saveKlineData(command);
    }

    @Test
    public void testHandleKlineWrittenEvent() {
        KlineItem klineItem = new KlineItem();
        DataItemWrittenNotification<KlineItem> notification =
                DataItemWrittenNotification.<KlineItem>builder()
                .dataItem(klineItem)
                .build();
        klineEventBroker.handleKlineWrittenEvent(notification);
        verify(kafkaProducerService).sendCommand("binance-notification", notification);
    }

}
