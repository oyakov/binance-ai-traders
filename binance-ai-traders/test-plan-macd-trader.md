# MACD Trader Test Plan

## Objectives
- Validate MACD signal generation across bullish/bearish crossovers using deterministic kline sequences.
- Exercise trader sliding-window orchestration for signal vs. non-signal paths.
- Verify order service orchestration around placement, duplication guards, and closure semantics.
- Simulate a backtesting loop over historical-style data to ensure consistent signal sequencing.

## Scope & Coverage Matrix
| Requirement | Test Type | Coverage Approach |
|-------------|-----------|-------------------|
| MACD EMA computation and signal extraction | Unit | Feed synthetic kline series that produce BUY, SELL, and neutral outcomes. |
| Sliding window gating & order update checks | Unit | Drive `TraderServiceImpl` with mocked analyzer/service dependencies. |
| Order placement workflow (limit + OCO) | Unit | Mock Binance client & repositories to assert interactions and guard rails. |
| Order closure & active order lookup | Unit | Exercise `closeOrderWithState`, `getActiveOrder`, and `hasActiveOrder` logic. |
| Backtesting of MACD strategy | Integration | Replay a sinusoidal kline dataset, capturing the sequence of emitted trade signals. |

## Test Data
- Deterministic sinusoidal price curve (`f(t) = 100 + 10 sin(t/5)`) converted into Avro `KlineEvent` fixtures, producing alternating MACD crossovers.
- Boundary datasets with insufficient (<35) and exactly window-sized klines.
- Stubbed Binance API responses for order placement and OCO order reports.

## Execution Strategy
1. Implement unit tests under `binance-trader-macd` with Mockito + JUnit 5.
2. Implement integration-style test using the real `MACDSignalAnalyzer` processing the synthetic dataset end-to-end.
3. Run `mvn test -pl binance-trader-macd` to execute the new suite.
4. Integrate into CI by ensuring tests live in the module's standard `src/test/java` tree.

## Exit Criteria
- All new and existing tests pass without flaky behavior.
- Coverage includes positive and negative paths for MACD signal extraction, trader window management, and order service workflow.
- Backtesting integration test validates expected alternating signal sequence without exceptions.
