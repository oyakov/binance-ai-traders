package com.oyakov.binance_trader_macd.rest.client;

import com.oyakov.binance_trader_macd.config.MACDTraderConfig;
import com.oyakov.binance_trader_macd.domain.OrderSide;
import com.oyakov.binance_trader_macd.domain.OrderType;
import com.oyakov.binance_trader_macd.domain.TimeInForce;
import com.oyakov.binance_trader_macd.rest.dto.BinanceOcoOrderResponse;
import com.oyakov.binance_trader_macd.rest.dto.BinanceOrderResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.codec.binary.Hex;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestTemplate;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.math.BigDecimal;
import java.net.URI;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;

@Slf4j
@RequiredArgsConstructor
public class BinanceOrderClient {

    public static final String X_MBX_APIKEY = "X-MBX-APIKEY";
    private static final String ORDER_PATH = "/api/v3/order";
    private static final String ORDER_TEST_PATH = "/api/v3/order/test";
    private static final String OCO_PATH = "/api/v3/orderList/oco";

    private final RestTemplate restTemplate;
    private final MACDTraderConfig traderConfig;

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

            boolean testMode = Boolean.TRUE.equals(traderConfig.getTrader().getTestOrderModeEnabled());
            String path = testMode ? ORDER_TEST_PATH : ORDER_PATH;

            BinanceOrderResponse response;
            if (testMode) {
                executeSignedPost(path, params, String.class);
                response = buildTestOrderResponse(symbol, type, side, quantity, price, timeInForce, clientOrderId);
                log.info("Validated order in test mode: {}", response);
            } else {
                ResponseEntity<BinanceOrderResponse> exchange = executeSignedPost(path, params, BinanceOrderResponse.class);
                response = Objects.requireNonNull(exchange.getBody(), "Binance order response must not be null");
                log.info("Order placed: {}", response);
            }
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

            boolean testMode = Boolean.TRUE.equals(traderConfig.getTrader().getTestOrderModeEnabled());
            if (testMode) {
                log.info("Test order mode enabled, skipping live OCO placement for symbol {}", symbol);
                return buildTestOcoOrderResponse(symbol, side, quantity, abovePrice, aboveStopPrice, belowStopPrice, belowLimitPrice);
            }

            ResponseEntity<BinanceOcoOrderResponse> response = executeSignedPost(OCO_PATH, params, BinanceOcoOrderResponse.class);
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

            boolean testMode = Boolean.TRUE.equals(traderConfig.getTrader().getTestOrderModeEnabled());
            if (testMode) {
                log.info("Test order mode enabled, skipping cancel for {}:{}", symbol, orderId);
                return true;
            }

            ResponseEntity<String> response = executeSignedDelete(ORDER_PATH, params);

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

    private <T> ResponseEntity<T> executeSignedPost(String path, Map<String, String> params, Class<T> responseType) throws Exception {
        return executeSignedRequest(HttpMethod.POST, path, params, responseType);
    }

    private ResponseEntity<String> executeSignedDelete(String path, Map<String, String> params) throws Exception {
        return executeSignedRequest(HttpMethod.DELETE, path, params, String.class);
    }

    private <T> ResponseEntity<T> executeSignedRequest(HttpMethod method, String path, Map<String, String> params, Class<T> responseType) throws Exception {
        MACDTraderConfig.Rest rest = traderConfig.getRest();
        String queryString = buildQueryString(params);
        String secret = Objects.requireNonNull(rest.getSecretApiToken(), "Binance API secret must be configured");
        String signature = sign(queryString, secret);
        String baseUrl = Objects.requireNonNull(rest.getBaseUrl(), "Binance REST base URL must be configured");
        String finalUrl = baseUrl + path + "?" + queryString + "&signature=" + signature;

        HttpHeaders headers = new HttpHeaders();
        String apiKey = Objects.requireNonNull(rest.getApiToken(), "Binance API key must be configured");
        headers.set(X_MBX_APIKEY, apiKey);
        HttpEntity<String> entity = new HttpEntity<>(headers);

        return restTemplate.exchange(URI.create(finalUrl), method, entity, responseType);
    }

    private BinanceOrderResponse buildTestOrderResponse(String symbol, OrderType type, OrderSide side,
                                                        BigDecimal quantity, BigDecimal price, TimeInForce timeInForce,
                                                        String clientOrderId) {
        long now = Instant.now().toEpochMilli();
        BinanceOrderResponse response = new BinanceOrderResponse();
        response.setSymbol(symbol);
        response.setOrderId(0L);
        response.setOrderListId(0L);
        response.setClientOrderId(clientOrderId);
        response.setTransactTime(now);
        response.setPrice(price);
        response.setOrigQty(quantity);
        response.setExecutedQty(BigDecimal.ZERO);
        response.setOrigQuoteOrderQty(BigDecimal.ZERO);
        response.setCummulativeQuoteQty(BigDecimal.ZERO);
        response.setStatus("ACTIVE");
        response.setTimeInForce(timeInForce.getValue());
        response.setType(type.getValue());
        response.setSide(side.getValue());
        response.setWorkingTime(now);
        response.setSelfTradePreventionMode("NONE");
        response.setFills(List.of());
        return response;
    }

    private BinanceOcoOrderResponse buildTestOcoOrderResponse(String symbol, OrderSide side,
                                                              BigDecimal quantity, BigDecimal abovePrice,
                                                              BigDecimal aboveStopPrice, BigDecimal belowStopPrice,
                                                              BigDecimal belowLimitPrice) {
        BinanceOcoOrderResponse response = new BinanceOcoOrderResponse();
        long now = Instant.now().toEpochMilli();
        response.setOrderListId(0L);
        response.setContingencyType("OCO");
        response.setListStatusType("EXEC_STARTED");
        response.setListOrderStatus("EXECUTING");
        response.setListClientOrderId(generateClientOrderId());
        response.setTransactionTime(now);
        response.setSymbol(symbol);
        response.setOrders(List.of());
        response.setOrderReports(List.of());

        log.info("Simulated OCO order in test mode for symbol {} with quantity {}", symbol, quantity);
        log.debug("Test OCO parameters: side={}, abovePrice={}, aboveStopPrice={}, belowStopPrice={}, belowLimitPrice={}",
                side, abovePrice, aboveStopPrice, belowStopPrice, belowLimitPrice);
        return response;
    }
}
