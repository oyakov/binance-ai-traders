package com.oyakov.binance_trader_macd.service.api;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import org.springframework.context.event.EventListener;

public interface KlineEventListener {

    @EventListener(KlineEvent.class)
    public void onNewKline(KlineEvent klineEvent);
}
