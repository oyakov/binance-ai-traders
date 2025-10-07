package com.oyakov.binance_data_collection.websocket.handler;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.oyakov.binance_data_collection.domain.kline.KlineStream;
import com.oyakov.binance_data_collection.domain.kline.KlineStreamCache;
import com.oyakov.binance_data_collection.kafka.producer.KafkaProducerService;
import com.oyakov.binance_data_collection.metrics.DataCollectionMetrics;
import com.oyakov.binance_data_collection.model.binance.BinanceWebsocketEventData;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import io.micrometer.core.instrument.Timer;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.core.convert.ConversionService;
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
    private final KlineStreamCache klineStreamCache;
    private final ConversionService conversionService;
    private final DataCollectionMetrics metrics;

    @Override
    protected void handleTextMessage(WebSocketSession session, @NonNull TextMessage message) {
        klineStreamCache.findStreamSourceBySessionId(session.getId())
                .ifPresentOrElse(
                        streamSource -> handleKlineUpdate(streamSource, message),
                        () -> log.warn("Received kline update for unknown session {}", session.getId()));
    }

    private void handleKlineUpdate(KlineStream klineStream, TextMessage message) {
        Timer.Sample sample = metrics.startKlineEventProcessing();
        try {
            String payload = message.getPayload();
            log.debug("Received message: {} for session {}", payload, klineStream.session().getId());
            BinanceWebsocketEventData eventData;
            try {
                eventData = MAPPER.readValue(payload, BinanceWebsocketEventData.class);
            } catch (JsonProcessingException e) {
                log.error("Error decoding binance kline event data", e);
                throw new RuntimeException(e);
            }

            log.debug("Parsed message: {}", eventData);
            long newOpenTime = eventData.getKline().getOpenTime();
            long newCloseTime = eventData.getKline().getCloseTime();

            if (newOpenTime != klineStream.lastOpenTime() || newCloseTime != klineStream.lastCloseTime()) {
                log.debug("New kline received");
                KlineStream updatedKlineStream = klineStream.withTimestamps(newOpenTime, newCloseTime);
                klineStreamCache.putStreamSource(updatedKlineStream);

                KlineEvent klineEvent = conversionService.convert(eventData, KlineEvent.class);
                
                // Record metrics for the received kline event
                metrics.incrementKlineEventsReceived(
                    klineEvent.getSymbol(), 
                    klineEvent.getInterval()
                );
                
                kafkaProducerService.sendKlineEvent(klineEvent);
            } else {
                log.debug("Kline update received with already existing timestamp {}", eventData);
            }
        } finally {
            metrics.recordKlineEventProcessingTime(sample);
        }
    }

}
