package com.oyakov.binance_data_collection.commands;

import com.oyakov.binance_data_collection.kafka.CommandMarker;
import com.oyakov.binance_data_collection.model.StreamSource;
import lombok.*;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
@ToString
public class ConfigureStreamSources implements CommandMarker {
    private List<StreamSource> updatedStreamSources;
}
