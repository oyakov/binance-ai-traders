package com.oyakov.binance_trader_macd.testnet;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StrategyRanking {
    private List<StrategyPerformance> rankings;
}
