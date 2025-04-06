package com.oyakov.binance_data_storage.broker.kafka.consumer;

import com.oyakov.binance_data_storage.model.klines.binance.commands.KlineCollectedCommand;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.test.context.EmbeddedKafka;
import org.springframework.test.context.ContextConfiguration;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.verify;

@SpringBootTest
@ContextConfiguration(classes = {KafkaTestConfig.class, KafkaConsumerService.class})
@EmbeddedKafka(partitions = 1, topics = {"binance-kline", "binance-notification"})
public class KafkaConsumerServiceIntegrationTest {

    @Mock
    private ApplicationEventPublisher eventPublisher;

    @Autowired
    private KafkaTemplate<String, KlineCollectedCommand> kafkaTemplate;

    @Autowired
    private KafkaConsumerService kafkaConsumerService;

    @Test
    public void testKafkaListener() throws InterruptedException {
        KlineCollectedCommand command = new KlineCollectedCommand();
        kafkaTemplate.send("binance-kline", command);

        // Add a delay to ensure the message is consumed
        Thread.sleep(2000);

        // Verify the event was published
        // This part depends on how you handle the event in your application
        // For example, you can use a mock ApplicationEventPublisher and verify it was called
        verify(eventPublisher).publishEvent(command);
    }
}