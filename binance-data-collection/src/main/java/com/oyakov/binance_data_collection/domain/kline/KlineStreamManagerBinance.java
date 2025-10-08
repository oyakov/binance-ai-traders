package com.oyakov.binance_data_collection.domain.kline;

import com.oyakov.binance_data_collection.URLFormatter;
import com.oyakov.binance_data_collection.config.BinanceDataCollectionConfig;
import com.oyakov.binance_data_collection.kafka.producer.KafkaProducerService;
import com.oyakov.binance_data_collection.metrics.DataCollectionMetrics;
import com.oyakov.binance_data_collection.rest.client.binance.BinanceRestKlineClient;
import com.oyakov.binance_data_collection.websocket.handler.BinanceTextMessageHandler;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import io.micrometer.core.instrument.Timer;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketHttpHeaders;
import org.springframework.web.socket.client.standard.StandardWebSocketClient;

import java.net.URI;
import java.time.LocalDateTime;
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
    private final DataCollectionMetrics metrics;

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
                klineStreams.add(new KlineStream(new KlineStream.Key(symbol, interval), -1, -1, null));
            }
        }

        return klineStreams;
    }


    public void connect(List<KlineStream> klineStreams) {
        log.info("Binance kline streaming reconfiguration...");
        WebSocketHttpHeaders headers = new WebSocketHttpHeaders();

        Set<KlineStream.Key> updatedFingerprints =
                klineStreams.stream().map(KlineStream::fingerprint).collect(Collectors.toSet());

        Set<KlineStream.Key> activeFingerprints = klineStreamCache.getActiveSSFingerprints();

        log.info("Existing kline streams: {}", activeFingerprints);
        log.info("Updated kline streams: {}", updatedFingerprints);

        log.info("Closing obsolete sessions...");
        Set<KlineStream.Key> toClose =
                activeFingerprints.stream()
                        .filter(fingerprint -> !updatedFingerprints.contains(fingerprint))
                        .collect(Collectors.toSet());
        toClose.forEach(key -> {
            metrics.incrementWebsocketConnectionsClosed(key.symbol(), key.interval());
            metrics.decrementActiveKlineStreams();
        });

        Set<String> closedSessions = klineStreamCache.closeStreamSources(toClose);
        log.info("Closed sessions: {}", closedSessions);

        log.info("Opening new sessions...");
        List<CompletableFuture<Void>> futures = klineStreams.stream()
                .filter(streamSource -> !activeFingerprints.contains(streamSource.fingerprint()))
                .map(streamSource -> {
                    log.info("New stream source to be added {}", streamSource);
                    
                    // Fetch warmup klines with metrics
                    String symbol = streamSource.fingerprint().symbol();
                    String interval = streamSource.fingerprint().interval();
                    String operation = "warmup";
                    metrics.incrementRestApiCallsTotal(symbol, interval, operation);
                    Timer.Sample restApiSample = metrics.startRestApiCall();
                    boolean restSuccess = false;
                    try {
                        List<KlineEvent> warmupKlines = restKlineClient.fetchWarmupKlines(streamSource,
                                config.getData().getKline().getWarmupKlineCount());
                        restSuccess = true;
                        
                        kafkaProducerService.sendKlineEvents(config.getData().getKline().getKafkaTopic(), warmupKlines);
                    } catch (Exception e) {
                        metrics.incrementRestApiCallsFailed(symbol, interval, operation, e.getClass().getSimpleName());
                        log.error("Failed to fetch warmup klines for {}", streamSource, e);
                    } finally {
                        metrics.recordRestApiCallTime(restApiSample, symbol, interval, operation, restSuccess ? "success" : "failure");
                    }

                    URI uri = urlFormatter.formatWebsocketKlineURLTemplate(streamSource);
                    log.info("Connecting to Websocket URI {}", uri);

                    Timer.Sample connectionSample = metrics.startWebsocketConnection();
                    return client.execute(textMessageHandler, headers, uri)
                            .thenAccept(session -> {
                        metrics.recordWebsocketConnectionTime(connectionSample, symbol, interval, "success");
                        metrics.incrementWebsocketConnectionsEstablished(symbol, interval);
                        metrics.incrementActiveKlineStreams();

                        log.info("Connected: session {} is open for {} at {} with headers: {}",
                                session.getId(), streamSource, LocalDateTime.now(), headers);
                        klineStreamCache.putStreamSource(streamSource.withSession(session));
                    }).exceptionally(throwable -> {
                        metrics.recordWebsocketConnectionTime(connectionSample, symbol, interval, "failure");
                        metrics.incrementWebsocketConnectionsFailed(symbol, interval,
                                throwable != null ? throwable.getClass().getSimpleName() : "unknown");
                        log.error("Failed to connect to Binance WebSocket {}", streamSource, throwable);
                        return null;
                    });
                })
                .toList();

        // Wait for all to complete
        CompletableFuture.allOf(futures.toArray(new CompletableFuture[0])).orTimeout(15, TimeUnit.SECONDS).join();
        
        // Update total active streams count
        metrics.setActiveKlineStreams(klineStreams.size());
    }
}