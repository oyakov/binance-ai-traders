package com.oyakov.binance_data_collection.domain.kline;



import org.springframework.web.socket.WebSocketSession;

import java.util.Objects;

public record KlineStream(Key fingerprint,
                          long lastOpenTime,
                          long lastCloseTime,
                          WebSocketSession session) {

    public KlineStream withSession(WebSocketSession newSession) {
        return new KlineStream(this.fingerprint, this.lastOpenTime, this.lastCloseTime, newSession);
    }

    public KlineStream withTimestamps(long openTime, long closeTime) {
        return new KlineStream(this.fingerprint, openTime, closeTime, this.session);
    }

    public record Key(String symbol, String interval) {
        public Key {
            Objects.requireNonNull(symbol, "symbol must not be null");
            Objects.requireNonNull(interval, "interval must not be null");
        }
    }
}
