package com.oyakov.binance_data_collection.kafka.deserializer;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.oyakov.binance_data_collection.commands.ConfigureStreamSources;
import com.oyakov.binance_data_collection.commands.KlineCollectedCommand;
import com.oyakov.binance_data_collection.kafka.CommandMarker;
import org.apache.kafka.common.errors.SerializationException;
import org.springframework.kafka.support.serializer.JsonDeserializer;

import java.io.IOException;

public class CommandMarkerDeserializer extends JsonDeserializer<CommandMarker> {

    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    public CommandMarker deserialize(String topic, byte[] data) {
        try {
            JsonNode root = mapper.readTree(data);
            String type = root.get("type").asText(); // or "eventType"

            return switch (type) {
                case "CONFIGURE_STREAM_SOURCES" -> mapper.treeToValue(root, ConfigureStreamSources.class);
                case "KLINE_COLLECTED" -> mapper.treeToValue(root, KlineCollectedCommand.class);
                default -> throw new IllegalArgumentException("Unknown command type: " + type);
            };
        } catch (IOException e) {
            throw new SerializationException("Failed to deserialize command", e);
        }
    }
}


