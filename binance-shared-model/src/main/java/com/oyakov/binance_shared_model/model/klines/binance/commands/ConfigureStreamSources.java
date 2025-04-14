package com.oyakov.binance_shared_model.model.klines.binance.commands;

import com.oyakov.binance_shared_model.kafka.command.CommandMarker;
import com.oyakov.binance_shared_model.model.klines.binance.StreamSource;
import lombok.*;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
@ToString
public class ConfigureStreamSources implements CommandMarker {
    private List<StreamSource> updatedStreamSources;

    private final String type = "CONFIGURE_STREAM_SOURCES";
}
