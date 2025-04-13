package com.oyakov.binance_data_storage.kafka;

import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import com.oyakov.binance_data_storage.model.klines.binance.commands.KlineCollectedCommand;

@JsonTypeInfo(
        use = JsonTypeInfo.Id.NAME,
        include = JsonTypeInfo.As.PROPERTY,
        property = "type" // must exist in JSON
)
@JsonSubTypes({
        @JsonSubTypes.Type(value = ConfigureSt.class, name = "CONFIGURE_STREAM_SOURCES"),
        @JsonSubTypes.Type(value = KlineCollectedCommand.class, name = "KLINE_COLLECTED")
})
public interface CommandMarker {}

