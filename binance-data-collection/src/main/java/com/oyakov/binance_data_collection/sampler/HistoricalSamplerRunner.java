package com.oyakov.binance_data_collection.sampler;

import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

@Log4j2
@Component
@RequiredArgsConstructor
@ConditionalOnProperty(prefix = "binance.sampler", name = "enabled", havingValue = "true")
public class HistoricalSamplerRunner implements ApplicationRunner {

    private final HistoricalSamplerProperties properties;
    private final HistoricalKlineSampler sampler;

    @Override
    public void run(ApplicationArguments args) {
        if (properties.getSymbols().isEmpty()) {
            throw new IllegalStateException("Sampler requires at least one symbol. Configure binance.sampler.symbols");
        }
        if (properties.getIntervals().isEmpty()) {
            throw new IllegalStateException("Sampler requires at least one interval. Configure binance.sampler.intervals");
        }
        sampler.collect();
    }
}
