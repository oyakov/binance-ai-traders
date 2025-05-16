package com.oyakov.binance_data_collection;

import com.oyakov.binance_data_collection.config.BinanceDataCollectionConfig;
import com.oyakov.binance_data_collection.domain.kline.KlineStream;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.net.URI;

@Component
@RequiredArgsConstructor
public class URLFormatter {

    private final BinanceDataCollectionConfig config;

    public URI formatWebsocketKlineURLTemplate(KlineStream klineStream) {
        String urlTemplate = config.getWebsocket().getBaseUrl() + config.getWebsocket().getKlineUrlTemplate();
        if (!urlTemplate.contains("%s")) {
            throw new IllegalArgumentException("WebSocket base URL must contain two '%s' placeholders.");
        }
        return URI.create(String.format(urlTemplate,
                klineStream.fingerprint().symbol(),
                klineStream.fingerprint().interval()));
    }
}
