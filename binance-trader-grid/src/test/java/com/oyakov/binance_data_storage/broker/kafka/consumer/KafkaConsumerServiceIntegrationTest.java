package com.oyakov.binance_data_storage.broker.kafka.consumer;

import com.oyakov.binance_data_storage.model.klines.binance.commands.KlineCollectedCommand;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.ApplicationEventPublisher;

import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
public class KafkaConsumerServiceIntegrationTest {

    @Mock
    private ApplicationEventPublisher eventPublisher;

    private KafkaConsumerService kafkaConsumerService;

    @BeforeEach
    void setUp() {
        kafkaConsumerService = new KafkaConsumerService(eventPublisher);
    }

    @Test
    public void testKafkaListener() {
        KlineCollectedCommand command = new KlineCollectedCommand();
        kafkaConsumerService.listen(command);

        verify(eventPublisher).publishEvent(command);
    }
}