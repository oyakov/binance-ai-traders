package com.oyakov.binance_data_storage;

import com.oyakov.binance_data_storage.repository.elastic.KlineElasticRepository;
import com.oyakov.binance_data_storage.repository.jpa.KlinePostgresRepository;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest(properties = {
        "spring.kafka.bootstrap-servers=localhost:9092",
        "spring.kafka.listener.auto-startup=false"
})
@ActiveProfiles("test")
class BinanceDataStorageApplicationTests {

        @MockBean
        private KlineElasticRepository klineElasticRepository;

        @MockBean
        private KlinePostgresRepository klinePostgresRepository;

        @Test
        void contextLoads() {
                // This test will fail if the application context cannot start
        }

}
