package com.oyakov.binance_shared_model.model.klines.binance;



import org.springframework.web.socket.WebSocketSession;

import java.net.URI;
import java.util.Objects;

public record StreamSource(StreamSourceFingerprint fingerprint,
                           long lastOpenTime,
                           long lastCloseTime,
                           WebSocketSession session) {

    public static URI formatURLTemplate(StreamSource streamSource,
                                        String baseUrl) {
        if (!baseUrl.contains("%s")) {
            throw new IllegalArgumentException("WebSocket base URL must contain two '%s' placeholders.");
        }
        return URI.create(String.format(baseUrl,
                streamSource.fingerprint.symbol(),
                streamSource.fingerprint.interval()));
    }

    public StreamSource withSession(WebSocketSession newSession) {
        return new StreamSource(this.fingerprint, this.lastOpenTime, this.lastCloseTime, newSession);
    }

    public StreamSource withTimestamps(long openTime, long closeTime) {
        return new StreamSource(this.fingerprint, openTime, closeTime, this.session);
    }

    public record StreamSourceFingerprint(String symbol, String interval) {
        public StreamSourceFingerprint {
            Objects.requireNonNull(symbol, "symbol must not be null");
            Objects.requireNonNull(interval, "interval must not be null");
        }
    }
}
