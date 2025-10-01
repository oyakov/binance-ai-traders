# MEM-002: MACD Trader Service Architecture

**Type**: Finding  
**Status**: Active  
**Created**: 2024-12-25  
**Last Updated**: 2024-12-25  
**Impact Scope**: binance-trader-macd  

## Summary

The MACD Trader service has a well-structured architecture with comprehensive configuration and domain modeling, but lacks core strategy implementation and Kafka integration.

## Details

### Current Implementation
- `BinanceMACDTraderApplication` enables both JPA and Elasticsearch repositories
- `config/MACDTraderConfig` surfaces configuration for REST credentials, WebSocket connectivity, Kafka data ingestion, and trader-specific parameters
- Domain enums model order metadata (`OrderSide`, `OrderType`, `TimeInForce`, `OrderState`, `TradeSignal`)
- Converter classes translate Binance REST responses into internal order models
- Broker packages exist for Kafka consumer/producer but implementations are missing
- REST client scaffolding and DTOs suggest HTTP-based interaction with Binance

### Configuration Capabilities
The service supports comprehensive configuration through environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `BINANCE_REST_BASE_URL` | Binance REST API endpoint | Testnet/Production URLs |
| `BINANCE_API_KEY` | API key for authenticated calls | - |
| `BINANCE_API_SECRET` | Secret key for request signing | - |
| `BINANCE_TRADER_TEST_ORDER_MODE_ENABLED` | Enable test mode for dry-run validation | - |

### Missing Components
1. **Kafka Integration**: Consumer/producer classes are not implemented
2. **Strategy Logic**: MACD computation and crossover detection
3. **Position Management**: Logic for managing open positions
4. **Testing**: No tests for trading logic or order submission
5. **Error Handling**: Retry/backoff strategies and idempotency safeguards

### Observability Features
- Spring Boot Actuator endpoints (`/actuator/**`)
- Micrometer metrics for trading telemetry:
  - `binance.trader.active.positions` (gauge)
  - `binance.trader.realized.pnl` (gauge)
  - `binance.trader.signals{direction="total|buy|sell"}` (counter)

## Recommendations

1. **Implement MACD Pipeline**
   - Consume indicator streams
   - Encapsulate state in dedicated services
   - Implement crossover detection logic

2. **Complete Kafka Integration**
   - Implement consumer/producer components
   - Add retry/backoff strategies
   - Implement idempotency safeguards

3. **Centralize Shared Infrastructure**
   - Factor out shared beans (Elasticsearch, Kafka)
   - Reduce duplication across services

4. **Add Comprehensive Testing**
   - Mock Binance REST endpoints
   - Test order submission behavior
   - Validate both test and live modes

## Related Documentation
- [Binance MACD Trader Service](../services/binance-trader-macd.md)
- [System Overview](../overview.md)

## Code References
- `binance-trader-macd/src/main/java/com/oyakov/binance_trader_macd/`
- `binance-trader-macd/src/main/resources/application-*.yml`

## Next Steps
- [ ] Implement MACD computation pipeline
- [ ] Complete Kafka consumer/producer implementations
- [ ] Add comprehensive test coverage
- [ ] Centralize shared infrastructure components
