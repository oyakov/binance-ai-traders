package com.oyakov.binance_trader_macd.rest.client;

import com.oyakov.binance_trader_macd.domain.OrderSide;
import com.oyakov.binance_trader_macd.domain.OrderType;
import com.oyakov.binance_trader_macd.domain.TimeInForce;
import com.oyakov.binance_trader_macd.rest.dto.BinanceOrderResponse;
import org.hamcrest.Matchers;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.ExpectedCount;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.header;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.queryParam;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

@Tag("manual")
class BinanceOrderClientManualTest {

    private RestTemplate restTemplate;
    private MockRestServiceServer server;
    private BinanceOrderClient client;

    @BeforeEach
    void setUp() {
        this.restTemplate = new RestTemplate();
        this.server = MockRestServiceServer.createServer(restTemplate);
        this.client = new BinanceOrderClient(restTemplate);
    }

    @Test
    void placesLimitOrderAgainstTestnetEndpoint() {
        server.expect(ExpectedCount.once(),
                        requestTo(Matchers.startsWith("https://testnet.binance.vision/api/v3/order?")))
                .andExpect(method(HttpMethod.POST))
                .andExpect(header(BinanceOrderClient.X_MBX_APIKEY, Matchers.not(Matchers.isEmptyOrNullString())))
                .andExpect(queryParam("symbol", "BTCUSDT"))
                .andExpect(queryParam("side", OrderSide.BUY.getValue()))
                .andExpect(queryParam("type", OrderType.LIMIT.getValue()))
                .andRespond(withSuccess(mockOrderResponse(), MediaType.APPLICATION_JSON));

        BinanceOrderResponse response = client.placeOrder(
                "BTCUSDT",
                OrderType.LIMIT,
                OrderSide.BUY,
                new BigDecimal("0.01000000"),
                new BigDecimal("50000.00"),
                null,
                TimeInForce.GTC
        );

        assertThat(response).isNotNull();
        assertThat(response.getSymbol()).isEqualTo("BTCUSDT");
        assertThat(response.getSide()).isEqualTo(OrderSide.BUY.getValue());
        assertThat(response.getOrderId()).isEqualTo(123456789L);

        server.verify();
    }

    private String mockOrderResponse() {
        return """
                {
                  "symbol": "BTCUSDT",
                  "orderId": 123456789,
                  "orderListId": 1,
                  "clientOrderId": "bot_123",
                  "transactTime": 1720000000000,
                  "price": "50000.00",
                  "origQty": "0.01000000",
                  "executedQty": "0.00000000",
                  "cummulativeQuoteQty": "0.00000000",
                  "origQuoteOrderQty": "0.00000000",
                  "status": "NEW",
                  "timeInForce": "GTC",
                  "type": "LIMIT",
                  "side": "BUY",
                  "workingTime": 1720000000000,
                  "selfTradePreventionMode": "NONE",
                  "fills": []
                }
                """;
    }
}

