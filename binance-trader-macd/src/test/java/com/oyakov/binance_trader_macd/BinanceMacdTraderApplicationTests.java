package com.oyakov.binance_trader_macd;

import com.oyakov.binance_trader_macd.repository.elastic.OrderElasticRepository;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@ActiveProfiles("test")
class BinanceMacdTraderApplicationTests {

        @MockBean
        private OrderElasticRepository orderElasticRepository;

        @Test
        void contextLoads() {
                // This test will fail if the application context cannot start
        }

}
