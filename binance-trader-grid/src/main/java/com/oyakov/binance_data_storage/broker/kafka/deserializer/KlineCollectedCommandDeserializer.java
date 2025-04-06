package com.oyakov.binance_data_storage.broker.kafka.deserializer;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.oyakov.binance_data_storage.model.klines.binance.commands.KlineCollectedCommand;
import org.apache.kafka.common.serialization.Deserializer;

import java.util.Map;

public class KlineCollectedCommandDeserializer implements Deserializer<KlineCollectedCommand> {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public void configure(Map<String, ?> configs, boolean isKey) {
        // No configuration needed
    }

    @Override
    public KlineCollectedCommand deserialize(String topic, byte[] data) {
        try {
            return objectMapper.readValue(data, KlineCollectedCommand.class);
        } catch (Exception e) {
            throw new RuntimeException("Failed to deserialize message", e);
        }
    }

    @Override
    public void close() {
        // No resources to close
    }
}