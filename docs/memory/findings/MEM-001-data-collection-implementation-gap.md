# MEM-001: Data Collection Service Implementation Gap

**Type**: Finding  
**Status**: Active  
**Created**: 2024-12-25  
**Last Updated**: 2024-12-25  
**Impact Scope**: binance-data-collection  

## Summary

The Binance Data Collection service is currently a skeleton implementation with missing core functionality for data ingestion and Kafka publishing.

## Details

### Current State
- `BinanceDataCollectionApplication` only bootstraps Spring without additional configuration
- `config/BinanceDataCollectionConfig` exposes hierarchical configuration properties for REST and WebSocket endpoints as well as Kafka topic metadata
- `config/KafkaConfig` defines producers/consumers for the shared `KlineEvent` Avro schema but is currently commented out with `//@Configuration`
- `config/RestTemplateConfig` registers a plain `RestTemplate`
- `rest/DataCollectionRest` is an empty `@RestController` with no routes
- No WebSocket listeners, schedulers, or Kafka publishing logic exist

### Missing Components
1. **WebSocket Client**: No implementation for connecting to Binance WebSocket streams
2. **REST Endpoints**: Empty controller with no data collection routes
3. **Kafka Publishing**: Configuration exists but is disabled
4. **Data Processing**: No logic for processing and normalizing kline data
5. **Testing**: No tests for configuration binding or data processing logic

### Risks
- Service cannot collect data from Binance
- Kafka configuration has TODO to delete the class
- No validation of data processing logic
- Missing error handling and retry mechanisms

## Recommendations

1. **Implement WebSocket Listener**
   - Use configured intervals/symbols to subscribe to Binance streams
   - Publish `KlineEvent` messages via `KafkaTemplate`

2. **Decide on Kafka Configuration**
   - Either re-enable the existing KafkaConfig class
   - Or replace it with a shared auto-configuration module

3. **Add Integration Tests**
   - Mock Binance responses
   - Verify serialized Avro payloads
   - Test configuration binding

## Related Documentation
- [Binance Data Collection Service](../services/binance-data-collection.md)
- [System Overview](../overview.md)

## Code References
- `binance-data-collection/src/main/java/com/oyakov/binance_data_collection/`
- `binance-data-collection/src/main/resources/application-*.yml`

## Next Steps
- [ ] Implement WebSocket client for Binance streams
- [ ] Create REST endpoints for manual data collection
- [ ] Enable and test Kafka configuration
- [ ] Add comprehensive test coverage
