package com.oyakov.binance_data_collection.domain.kline;

import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.locks.ReentrantReadWriteLock;

@Component
@Log4j2
public class KlineStreamCache {
    private final Map<KlineStream.Key, KlineStream> activeStreamSources = new ConcurrentHashMap<>();
    private final ReentrantReadWriteLock streamLock = new ReentrantReadWriteLock();

    public Optional<KlineStream> findStreamSourceBySessionId(String sessionId) {
        streamLock.readLock().lock();
        try {
            return activeStreamSources.values().stream()
                    .filter(ss -> ss.session() != null &&
                            ss.session().getId().equals(sessionId))
                    .findFirst();
        } finally {
            streamLock.readLock().unlock();
        }
    }

    public void putStreamSource(KlineStream klineStream) {
        streamLock.writeLock().lock();
        try {
            activeStreamSources.put(klineStream.fingerprint(), klineStream);
        } finally {
            streamLock.writeLock().unlock();
        }
    }

    public Set<KlineStream.Key> getActiveSSFingerprints() {
        streamLock.readLock().lock();
        try {
            return new HashSet<>(activeStreamSources.keySet());
        } finally {
            streamLock.readLock().unlock();
        }
    }

    public void closeAllCurrentStreamSources() {
        streamLock.writeLock().lock();
        try {
            activeStreamSources.forEach((_, ss) -> {
                try {
                    ss.session().close();
                } catch (IOException e) {
                    log.error("Failed to close websocket session", e);
                }
            });
            activeStreamSources.clear();
        } finally {
            streamLock.writeLock().unlock();
        }
    }

    /**
     * Closes the given stream sources and returns the session IDs that were closed.
     */
    public Set<String> closeStreamSources(Set<KlineStream.Key> fingerprints) {
        Set<String> closedSessionIds = new HashSet<>();
        streamLock.writeLock().lock();
        try {
            for (KlineStream.Key fingerprint : fingerprints) {
                KlineStream removed = activeStreamSources.remove(fingerprint);
                if (removed != null && removed.session() != null) {
                    try {
                        removed.session().close();
                        closedSessionIds.add(removed.session().getId());
                    } catch (IOException e) {
                        log.error("Failed to close websocket session", e);
                    }
                }
            }
        } finally {
            streamLock.writeLock().unlock();
        }
        return closedSessionIds;
    }
}
