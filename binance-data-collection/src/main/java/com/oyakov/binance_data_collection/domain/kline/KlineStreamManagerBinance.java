package com.oyakov.binance_data_collection.domain.kline;

import com.oyakov.binance_data_collection.URLFormatter;
import com.oyakov.binance_data_collection.config.BinanceDataCollectionConfig;
import com.oyakov.binance_data_collection.kafka.producer.KafkaProducerService;
import com.oyakov.binance_data_collection.rest.client.binance.BinanceRestKlineClient;
import com.oyakov.binance_data_collection.websocket.handler.BinanceTextMessageHandler;
import com.oyakov.binance_shared_model.avro.KlineEvent;
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
public class KlineStreamManagerBinance {

    private final BinanceDataCollectionConfig config;
    private final KlineStreamCache klineStreamCache;
    private final BinanceTextMessageHandler textMessageHandler;
    private final StandardWebSocketClient client = new StandardWebSocketClient();
    private final BinanceRestKlineClient restKlineClient;
    private final URLFormatter urlFormatter;
    private final KafkaProducerService kafkaProducerService;

    @PostConstruct
    public void init() {
        if (config.getWebsocket().getAutoConnect()) {
            connect(fetchDefaultStreamSources());
        }
    }

    private List<KlineStream> fetchDefaultStreamSources() {
        List<String> intervals = config.getData().getKline().getIntervals();
        List<String> symbols = config.getData().getKline().getSymbols();
        List<KlineStream> klineStreams = new ArrayList<>();

        for (String symbol : symbols) {
            for (String interval : intervals) {
                klineStreams.add(new KlineStream(new KlineStream.KlineStreamKey(symbol, interval), -1, -1, null));
            }
        }

        return klineStreams;
    }


    public void connect(List<KlineStream> klineStreams) {
        log.info("Binance data collection streaming reconfiguration...");
        WebSocketHttpHeaders headers = new WebSocketHttpHeaders();

        Set<KlineStream.KlineStreamKey> updatedFingerprints =
                klineStreams.stream().map(KlineStream::fingerprint).collect(Collectors.toSet());

        Set<KlineStream.KlineStreamKey> activeFingerprints = klineStreamCache.getActiveSSFingerprints();

        log.info("Existing connections: {}", activeFingerprints);
        log.info("Updated configuration: {}", updatedFingerprints);

        log.info("Closing obsolete sessions...");
        Set<KlineStream.KlineStreamKey> toClose =
                activeFingerprints.stream()
                        .filter(fingerprint -> !updatedFingerprints.contains(fingerprint))
                        .collect(Collectors.toSet());
        Set<String> closedSessions = klineStreamCache.closeStreamSources(toClose);
        log.info("Closed sessions: {}", closedSessions);

        log.info("Opening new sessions...");
        List<CompletableFuture<Void>> futures = klineStreams.stream()
                .filter(streamSource -> !activeFingerprints.contains(streamSource.fingerprint()))
                .map(streamSource -> {
                    log.info("New stream source to be added {}", streamSource);
                    List<KlineEvent> warmupKlines = restKlineClient.fetchWarmupKlines(streamSource, 50);
                    kafkaProducerService.sendKlineEvents(config.getData().getKline().getKafkaTopic(), warmupKlines);
                    URI uri = urlFormatter.formatWebsocketKlineURLTemplate(streamSource);
                    log.info("Connecting to Websocket URI {}", uri);
                    return client.execute(textMessageHandler, headers, uri)
                            .thenAccept(session -> {
                        log.info("Connected: session {} is opened for {} at {} with headers: {}",
                                session.getId(), streamSource, System.currentTimeMillis() / 1000, headers);
                        klineStreamCache.putStreamSource(streamSource.withSession(session));
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