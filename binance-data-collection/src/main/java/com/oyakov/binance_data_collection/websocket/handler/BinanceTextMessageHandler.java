package com.oyakov.binance_data_collection.websocket.handler;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.oyakov.binance_data_collection.domain.kline.KlineStream;
import com.oyakov.binance_data_collection.domain.kline.KlineStreamCache;
import com.oyakov.binance_data_collection.kafka.producer.KafkaProducerService;
import com.oyakov.binance_data_collection.model.binance.BinanceWebsocketEventData;
import com.oyakov.binance_shared_model.avro.KlineEvent;
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

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        String payload = message.getPayload();
        log.debug("Received message: {} for session {}", payload, session.getId());
        BinanceWebsocketEventData binanceWebsocketEventData = MAPPER.readValue(payload, BinanceWebsocketEventData.class);
        log.debug("Parsed message: {}", binanceWebsocketEventData);

        klineStreamCache.findStreamSourceBySessionId(session.getId())
                .ifPresent(streamSource -> sendKlineEvent(streamSource, binanceWebsocketEventData));
    }

    private void sendKlineEvent(KlineStream klineStream, BinanceWebsocketEventData eventData) {
        long newOpenTime = eventData.getKline().getOpenTime();
        long newCloseTime = eventData.getKline().getCloseTime();

        KlineEvent klineEvent = null;
        if (newOpenTime != klineStream.lastOpenTime() || newCloseTime != klineStream.lastCloseTime()) {
            log.debug("New kline received");
            KlineStream updatedKlineStream = klineStream.withTimestamps(newOpenTime, newCloseTime);
            klineStreamCache.putStreamSource(updatedKlineStream);

            klineEvent = conversionService.convert(eventData, KlineEvent.class);

            kafkaProducerService.sendKlineEvent(klineEvent);
        } else {
            log.debug("Kline update received with already existing timestamp {}", klineEvent);
        }
    }

}
