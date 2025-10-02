package com.oyakov.binance_trader_macd.testnet;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TestnetReport {
    private Instant generatedAt;
    private List<InstancePerformance> performances;
    private String bestPerformer;
}
