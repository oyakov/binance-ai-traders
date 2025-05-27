package com.oyakov.binance_trader_macd.rest.client;

import com.oyakov.binance_trader_macd.domain.OrderSide;
import com.oyakov.binance_trader_macd.domain.OrderType;
import com.oyakov.binance_trader_macd.domain.TimeInForce;
import com.oyakov.binance_trader_macd.model.order.binance.storage.OrderItem;
import com.oyakov.binance_trader_macd.rest.dto.BinanceOcoOrderResponse;
import com.oyakov.binance_trader_macd.rest.dto.BinanceOrderResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.codec.binary.Hex;
import org.springframework.core.convert.ConversionService;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.math.BigDecimal;
import java.net.URI;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.LocalDateTime;
import java.util.*;

@Slf4j
@Component
@RequiredArgsConstructor
public class BinanceOrderClient {

    public static final String X_MBX_APIKEY = "X-MBX-APIKEY";
    private final RestTemplate restTemplate;
    private final String apiKey = "F4vS8U6mvUXST5TVbQbnMlUL4jOpQiI1Iy8QlVqXpVNMAxplu8pamFDZLB5mpOwU";
    private final String secretKey = "N26b6O6QlHmprRf40wEECqAEQjaD4ijMdIx5GRdBk0e34iTnVDRmFxZzrjgleT20";
    private final String mainnetBaseUrl = "https://api.binance.com";
    private final String testnetBaseUrl = "https://testnet.binance.vision";

    public BinanceOrderResponse placeOrder(String symbol, OrderType type, OrderSide side, BigDecimal quantity,
                                BigDecimal price, BigDecimal stopPrice, TimeInForce timeInForce) {
        try {
            long timestamp = Instant.now().toEpochMilli();
            if (timeInForce == null) timeInForce = TimeInForce.GTC;
            String clientOrderId = generateClientOrderId();

            Map<String, String> params = new LinkedHashMap<>();
            params.put("symbol", symbol);
            params.put("side", side.getValue());
            params.put("type", type.getValue());
            params.put("newClientOrderId", clientOrderId);
            
            // Add parameters based on order type
            switch (type) {
                case LIMIT:
                    params.put("timeInForce", timeInForce.getValue());
                    params.put("quantity", quantity.toString());
                    params.put("price", price.toString());
                    break;
                    
                case MARKET:
                    params.put("quantity", quantity.toString());
                    break;
                    
                case STOP_LOSS, TAKE_PROFIT:
                    params.put("quantity", quantity.toString());
                    params.put("stopPrice", stopPrice.toString());
                    break;
                    
                case STOP_LOSS_LIMIT, TAKE_PROFIT_LIMIT:
                    params.put("timeInForce", timeInForce.getValue());
                    params.put("quantity", quantity.toString());
                    params.put("price", price.toString());
                    params.put("stopPrice", stopPrice.toString());
                    break;
            }

            params.put("recvWindow", "5000");
            params.put("timestamp", String.valueOf(timestamp));

            String queryString = buildQueryString(params);
            String signature = sign(queryString, secretKey);
            String finalUrl = testnetBaseUrl + "/api/v3/order?" + queryString + "&signature=" + signature;

            HttpHeaders headers = new HttpHeaders();
            headers.set(X_MBX_APIKEY, apiKey);
            HttpEntity<String> entity = new HttpEntity<>(headers);

            BinanceOrderResponse response = restTemplate.exchange(
                    URI.create(finalUrl), HttpMethod.POST, entity, BinanceOrderResponse.class
            ).getBody();

            log.info("Order placed: {}", response);
            return response;
        } catch (Exception e) {
            log.error("Error placing order", e);
            return null;
        }
    }

    public BinanceOcoOrderResponse placeOcoOrder(
            String symbol,
            OrderSide side,
            BigDecimal quantity,
            BigDecimal abovePrice,
            BigDecimal aboveStopPrice,
            BigDecimal belowStopPrice,
            BigDecimal belowLimitPrice
    ) {
        try {
            long timestamp = Instant.now().toEpochMilli();
            String listClientOrderId = generateClientOrderId();

            Map<String, String> params = new LinkedHashMap<>();
            params.put("symbol", symbol);
            params.put("side", side.getValue());
            params.put("quantity", quantity.toPlainString());

            // Above order (e.g. TAKE_PROFIT_LIMIT)
            params.put("aboveType", "TAKE_PROFIT_LIMIT");
            params.put("aboveStopPrice", aboveStopPrice.toPlainString());
            params.put("abovePrice", abovePrice.toPlainString());
            params.put("aboveTimeInForce", "GTC");

            // Below order (e.g. STOP_LOSS_LIMIT)
            params.put("belowType", "STOP_LOSS_LIMIT");
            params.put("belowStopPrice", belowStopPrice.toPlainString());
            params.put("belowPrice", belowLimitPrice.toPlainString());
            params.put("belowTimeInForce", "GTC");

            params.put("listClientOrderId", listClientOrderId);
            params.put("recvWindow", "5000");
            params.put("timestamp", String.valueOf(timestamp));

            String queryString = buildQueryString(params);
            String signature = sign(queryString, secretKey);
            String finalUrl = testnetBaseUrl + "/api/v3/orderList/oco?" + queryString + "&signature=" + signature;

            HttpHeaders headers = new HttpHeaders();
            headers.set("X-MBX-APIKEY", apiKey);
            HttpEntity<String> entity = new HttpEntity<>(headers);

            ResponseEntity<BinanceOcoOrderResponse> response = restTemplate.exchange(
                    URI.create(finalUrl), HttpMethod.POST, entity, BinanceOcoOrderResponse.class
            );


            return response.getBody();
        } catch (Exception e) {
            log.error("Error placing OCO order (new endpoint)", e);
        }
        return null;
    }

    public boolean cancelOrder(String symbol, Long orderId) {
        try {
            long timestamp = Instant.now().toEpochMilli();

            Map<String, String> params = new LinkedHashMap<>();
            params.put("symbol", symbol);
            params.put("orderId", orderId.toString());
            params.put("timestamp", String.valueOf(timestamp));

            String queryString = buildQueryString(params);
            String signature = sign(queryString, secretKey);
            String finalUrl = testnetBaseUrl + "/api/v3/order?" + queryString + "&signature=" + signature;

            HttpHeaders headers = new HttpHeaders();
            headers.set("X-MBX-APIKEY", apiKey);
            HttpEntity<String> entity = new HttpEntity<>(headers);

            ResponseEntity<OrderItem> response = restTemplate.exchange(
                    URI.create(finalUrl), HttpMethod.DELETE, entity, OrderItem.class
            );

            return response.getStatusCode() == HttpStatus.OK;
        } catch (Exception e) {
            log.error("Error canceling order", e);
            return false;
        }
    }

    private String generateClientOrderId() {
        return "bot_%s".formatted(UUID.randomUUID().toString().substring(0, 20));
    }

    private String buildQueryString(Map<String, String> params) {
        StringBuilder sb = new StringBuilder();
        for (Map.Entry<String, String> entry : params.entrySet()) {
            if (entry.getValue() != null) {
                sb.append(URLEncoder.encode(entry.getKey(), StandardCharsets.UTF_8));
                sb.append("=");
                sb.append(URLEncoder.encode(entry.getValue(), StandardCharsets.UTF_8));
                sb.append("&");
            }
        }
        if (!sb.isEmpty()) {
            sb.setLength(sb.length() - 1); // remove trailing '&'
        }
        return sb.toString();
    }

    private String sign(String data, String key) throws Exception {
        Mac hmacSha256 = Mac.getInstance("HmacSHA256");
        SecretKeySpec secretKeySpec = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
        hmacSha256.init(secretKeySpec);
        byte[] hash = hmacSha256.doFinal(data.getBytes(StandardCharsets.UTF_8));
        return Hex.encodeHexString(hash);
    }
}
