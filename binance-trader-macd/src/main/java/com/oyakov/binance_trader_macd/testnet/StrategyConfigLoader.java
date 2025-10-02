package com.oyakov.binance_trader_macd.testnet;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
@Profile("testnet")
@RequiredArgsConstructor
public class StrategyConfigLoader {

    private final TestnetStrategiesProperties strategiesProperties;
    private final TestnetProperties testnetProperties;

    public List<StrategyConfig> loadEnabledStrategies() {
        return strategiesProperties.getStrategies().entrySet().stream()
                .map(this::toStrategyConfig)
                .filter(StrategyConfig::isEnabled)
                .peek(config -> log.info("Loaded testnet strategy profile {}", config.getId()))
                .collect(Collectors.toList());
    }

    private StrategyConfig toStrategyConfig(Map.Entry<String, TestnetStrategiesProperties.StrategyProperties> entry) {
        StrategyConfig config = entry.getValue().toStrategyConfig(entry.getKey());
        if (config.getPositionSize() == null) {
            config.setPositionSize(testnetProperties.getMaxPositionSize());
        }
        if (config.getRiskLevel() == null) {
            config.setRiskLevel(testnetProperties.getRiskLevel());
        }
        return config;
    }
}
