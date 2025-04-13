package com.oyakov.binance_data_collection.kafka.deserializer;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.oyakov.binance_data_collection.commands.ConfigureStreamSources;
import org.apache.kafka.common.serialization.Deserializer;

public class ConfigureStreamSourcesCommandDeserializer implements Deserializer<ConfigureStreamSources> {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public ConfigureStreamSources deserialize(String s, byte[] bytes) {
        try {
            return objectMapper.readValue(bytes, ConfigureStreamSources.class);
        } catch (Exception e) {
            throw new RuntimeException("Failed to deserialize message", e);
        }
    }
}
