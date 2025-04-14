package com.oyakov.binance_data_collection.cache;

import com.oyakov.binance_shared_model.model.klines.binance.StreamSource;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.locks.ReentrantReadWriteLock;

@Component
@Log4j2
public class StreamSourcesManager {
    private final Map<StreamSource.StreamSourceFingerprint, StreamSource> activeStreamSources = new ConcurrentHashMap<>();
    private final ReentrantReadWriteLock streamLock = new ReentrantReadWriteLock();

    public Optional<StreamSource> findStreamSourceBySessionId(String sessionId) {
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

    public void putStreamSource(StreamSource streamSource) {
        streamLock.writeLock().lock();
        try {
            activeStreamSources.put(streamSource.fingerprint(), streamSource);
        } finally {
            streamLock.writeLock().unlock();
        }
    }

    public Set<StreamSource.StreamSourceFingerprint> getActiveSSFingerprints() {
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
    public Set<String> closeStreamSources(Set<StreamSource.StreamSourceFingerprint> fingerprints) {
        Set<String> closedSessionIds = new HashSet<>();
        streamLock.writeLock().lock();
        try {
            for (StreamSource.StreamSourceFingerprint fingerprint : fingerprints) {
                StreamSource removed = activeStreamSources.remove(fingerprint);
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
