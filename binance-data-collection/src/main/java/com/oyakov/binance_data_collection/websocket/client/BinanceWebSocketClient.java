package com.oyakov.binance_data_collection.websocket.client;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.oyakov.binance_data_collection.commands.KlineCollectedCommand;
import com.oyakov.binance_data_collection.kafka.producer.KafkaProducerService;
import com.oyakov.binance_data_collection.model.BinanceWebsocketEventData;
import jakarta.annotation.PostConstruct;
import lombok.extern.log4j.Log4j2;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.lang.NonNullApi;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketHttpHeaders;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.client.standard.StandardWebSocketClient;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.net.URI;
import java.util.concurrent.CompletableFuture;

@Component
@Log4j2
public class BinanceWebSocketClient extends TextWebSocketHandler {

    private static final String BINANCE_WS_URL = "wss://stream.binance.com:9443/ws/ethusdt@kline_1m";
    private final KafkaProducerService kafkaProducerService;
    private long lastOpenTime = -1;
    private long lastCloseTime = -1;

    @Value("${binance.api.websocket.kline.topic}")
    private final String klineTopic = "binance-kline";

    public BinanceWebSocketClient(KafkaProducerService kafkaProducerService) {
        this.kafkaProducerService = kafkaProducerService;
    }

    @PostConstruct
    public void connect() {
        StandardWebSocketClient client = new StandardWebSocketClient();
        WebSocketHttpHeaders headers = new WebSocketHttpHeaders();
        CompletableFuture<WebSocketSession> future =
                client.execute(this, headers, URI.create(BINANCE_WS_URL));
        future.thenAccept(session -> {
            System.out.println("Connected: " + session.getId() + " to " + BINANCE_WS_URL + " at " + System.currentTimeMillis()
            + " with headers: " + headers);
        }).exceptionally(throwable -> {
            log.error("Failed to connect to Binance WebSocket", throwable);
            return null;
        });
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        log.debug("Received message: {}", message.getPayload());
        String payload = message.getPayload();
        BinanceWebsocketEventData binanceWebsocketEventData = new ObjectMapper().readValue(payload, BinanceWebsocketEventData.class);
        log.debug("Parsed message: {}", binanceWebsocketEventData);

        long newOpenTime = binanceWebsocketEventData.getKline().getOpenTime();
        long newCloseTime = binanceWebsocketEventData.getKline().getCloseTime();

        if (newOpenTime != lastOpenTime || newCloseTime != lastCloseTime) {
            lastOpenTime = newOpenTime;
            lastCloseTime = newCloseTime;
            KlineCollectedCommand command = KlineCollectedCommand.builder()
                    .eventTime(binanceWebsocketEventData.getEventTime())
                    .symbol(binanceWebsocketEventData.getSymbol())
                    .openTime(binanceWebsocketEventData.getKline().getOpenTime())
                    .closeTime(binanceWebsocketEventData.getKline().getCloseTime())
                    .open(binanceWebsocketEventData.getKline().getOpen())
                    .high(binanceWebsocketEventData.getKline().getHigh())
                    .low(binanceWebsocketEventData.getKline().getLow())
                    .close(binanceWebsocketEventData.getKline().getClose())
                    .volume(binanceWebsocketEventData.getKline().getVolume())
                    .build();
            kafkaProducerService.sendCommand(klineTopic, command);
        }
    }
}