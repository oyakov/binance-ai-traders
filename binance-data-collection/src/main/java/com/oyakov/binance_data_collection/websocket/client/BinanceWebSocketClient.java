package com.oyakov.binance_data_collection.websocket.client;

import com.oyakov.binance_data_collection.cache.StreamSource;
import com.oyakov.binance_data_collection.cache.StreamSourcesManager;
import com.oyakov.binance_data_collection.config.BinanceDataCollectionConfig;
import com.oyakov.binance_data_collection.websocket.handler.BinanceTextMessageHandler;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketHttpHeaders;
import org.springframework.web.socket.client.standard.StandardWebSocketClient;

import java.net.URI;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

@Component
@Log4j2
@RequiredArgsConstructor
public class BinanceWebSocketClient {

    private final BinanceDataCollectionConfig config;
    private final StreamSourcesManager streamSourcesManager;
    private final BinanceTextMessageHandler textMessageHandler;
    private final StandardWebSocketClient client = new StandardWebSocketClient();


    @PostConstruct
    public void init() {
        if (config.getWebsocket().getAutoConnect()) {
            connect(fetchDefaultStreamSources());
        }
    }

    private List<StreamSource> fetchDefaultStreamSources() {
        List<String> intervals = config.getData().getKline().getIntervals();
        List<String> symbols = config.getData().getKline().getSymbols();
        List<StreamSource> streamSources = new ArrayList<>();

        for (String symbol : symbols) {
            for (String interval : intervals) {
                streamSources.add(new StreamSource(new StreamSource.StreamSourceFingerprint(symbol, interval), -1, -1, null));
            }
        }

        return streamSources;
    }


    public void connect(List<StreamSource> streamSources) {
        log.info("Binance data collection streaming reconfiguration...");
        WebSocketHttpHeaders headers = new WebSocketHttpHeaders();

        Set<StreamSource.StreamSourceFingerprint> updatedFingerprints =
                streamSources.stream().map(StreamSource::fingerprint).collect(Collectors.toSet());

        Set<StreamSource.StreamSourceFingerprint> activeFingerprints = streamSourcesManager.getActiveSSFingerprints();

        log.info("Existing connections: {}", activeFingerprints);
        log.info("Updated configuration: {}", updatedFingerprints);

        log.info("Closing obsolete sessions...");
        Set<StreamSource.StreamSourceFingerprint> toClose =
                activeFingerprints.stream()
                        .filter(fingerprint -> !updatedFingerprints.contains(fingerprint))
                        .collect(Collectors.toSet());
        Set<String> closedSessions = streamSourcesManager.closeStreamSources(toClose);
        log.info("Closed sessions: {}", closedSessions);

        log.info("Opening new sessions...");
        List<CompletableFuture<Void>> futures = streamSources.stream()
                .filter(streamSource -> !activeFingerprints.contains(streamSource.fingerprint()))
                .map(streamSource -> {
                    log.info("New stream source to be added {}", streamSource);
                    URI uri = StreamSource.formatURLTemplate(streamSource, config.getWebsocket().getBaseUrl());
                    log.info("Connecting to URI {}", uri);
                    return client.execute(textMessageHandler, headers, uri)
                            .thenAccept(session -> {
                        log.info("Connected: session {} is opened for {} at {} with headers: {}",
                                session.getId(), streamSource, System.currentTimeMillis() / 1000, headers);
                        streamSourcesManager.putStreamSource(streamSource.withSession(session));
                    }).exceptionally(throwable -> {
                        log.error("Failed to connect to Binance WebSocket {}", streamSource, throwable);
                        return null;
                    });
                })
                .toList();

        // Wait for all to complete
        CompletableFuture.allOf(futures.toArray(new CompletableFuture[0])).orTimeout(15, TimeUnit.SECONDS).join();
    }
}