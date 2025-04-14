package com.oyakov.binance_shared_model.kafka.command;


import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import com.oyakov.binance_shared_model.model.klines.binance.commands.ConfigureStreamSources;
import com.oyakov.binance_shared_model.model.klines.binance.commands.KlineCollectedCommand;

@JsonTypeInfo(
        use = JsonTypeInfo.Id.NAME,
        include = JsonTypeInfo.As.PROPERTY,
        property = "type" // must exist in JSON
)
@JsonSubTypes({
        @JsonSubTypes.Type(value = ConfigureStreamSources.class, name = "CONFIGURE_STREAM_SOURCES"),
        @JsonSubTypes.Type(value = KlineCollectedCommand.class, name = "KLINE_COLLECTED")
})
public interface CommandMarker {
    public String getType();
}
