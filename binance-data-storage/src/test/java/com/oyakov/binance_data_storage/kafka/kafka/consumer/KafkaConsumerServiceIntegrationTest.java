package com.oyakov.binance_data_storage.kafka.kafka.consumer;

import com.oyakov.binance_data_storage.kafka.consumer.KafkaConsumerService;
import com.oyakov.binance_data_storage.service.api.KlineDataServiceApi;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.ActiveProfiles;

import static org.mockito.Mockito.verify;

@ActiveProfiles("test")
@SpringBootTest(classes = KafkaConsumerService.class, properties = {
        "spring.kafka.listener.auto-startup=false",
        "binance.data.kline.kafka-topic=binance-kline",
        "binance.data.kline.kafka-consumer-group=test-group"
})
public class KafkaConsumerServiceIntegrationTest {

    @Autowired
    private KafkaConsumerService kafkaConsumerService;

    @MockBean
    private KlineDataServiceApi klineDataService;

    @Test
    public void testKafkaListener() {
        KlineEvent command = new KlineEvent();
        kafkaConsumerService.listen(command);

        verify(klineDataService).saveKlineData(command);
    }
}