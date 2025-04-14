package com.oyakov.binance_data_collection.websocket.handler;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.oyakov.binance_data_collection.cache.StreamSourcesManager;
import com.oyakov.binance_data_collection.config.BinanceDataCollectionConfig;
import com.oyakov.binance_data_collection.kafka.producer.KafkaProducerService;
import com.oyakov.binance_data_collection.model.binance.BinanceWebsocketEventData;
import com.oyakov.binance_shared_model.model.klines.binance.StreamSource;
import com.oyakov.binance_shared_model.model.klines.binance.commands.KlineCollectedCommand;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

@Component
@Log4j2
@RequiredArgsConstructor
public class BinanceTextMessageHandler extends TextWebSocketHandler {

    private static final ObjectMapper MAPPER = new ObjectMapper();

    private final KafkaProducerService kafkaProducerService;
    private final BinanceDataCollectionConfig config;
    private final StreamSourcesManager streamSourcesManager;

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        log.debug("Received message: {} for session {}", message.getPayload(), session.getId());
        String payload = message.getPayload();
        BinanceWebsocketEventData binanceWebsocketEventData = MAPPER.readValue(payload, BinanceWebsocketEventData.class);
        log.debug("Parsed message: {}", binanceWebsocketEventData);

        streamSourcesManager.findStreamSourceBySessionId(session.getId())
                .ifPresent(streamSource -> sendKlineCollected(streamSource, binanceWebsocketEventData));
    }

    private void sendKlineCollected(StreamSource streamSource, BinanceWebsocketEventData eventData) {
        long newOpenTime = eventData.getKline().getOpenTime();
        long newCloseTime = eventData.getKline().getCloseTime();

        if (newOpenTime != streamSource.lastOpenTime() || newCloseTime != streamSource.lastCloseTime()) {
            StreamSource updatedStreamSource = streamSource.withTimestamps(newOpenTime, newCloseTime);
            streamSourcesManager.putStreamSource(updatedStreamSource);  // update the cache

            KlineCollectedCommand command = KlineCollectedCommand.builder()
                    .eventTime(eventData.getEventTime())
                    .eventType(eventData.getEventType())
                    .symbol(eventData.getSymbol())
                    .interval(streamSource.fingerprint().interval())
                    .openTime(eventData.getKline().getOpenTime())
                    .closeTime(eventData.getKline().getCloseTime())
                    .open(eventData.getKline().getOpen())
                    .high(eventData.getKline().getHigh())
                    .low(eventData.getKline().getLow())
                    .close(eventData.getKline().getClose())
                    .volume(eventData.getKline().getVolume())
                    .build();

            kafkaProducerService.sendCommand(config.getData().getKline().getKafkaTopic(), command);
        }
    }

}
