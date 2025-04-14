package com.oyakov.binance_data_collection.kafka.service;

import com.oyakov.binance_shared_model.model.klines.binance.commands.ConfigureStreamSources;
import org.springframework.context.event.EventListener;

public interface ConfigurationEventBroker {

    @EventListener
    public void configureStreamSourcesEvent(ConfigureStreamSources event);
}
