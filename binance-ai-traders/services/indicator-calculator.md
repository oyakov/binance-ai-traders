# Indicator Calculator Service (Missing)

The top-level README references an `indicator-calculator` microservice responsible for deriving technical indicators (MACD, RSI, etc.) from stored market data. This directory does not exist in the repository snapshot.

## Implications
- Trading services that depend on indicator streams have no documented producer.
- Kafka topics for indicator outputs are unspecified, making end-to-end data flow unclear.

## Recommendations
1. Confirm whether the indicator service lives in a separate repository; if so, document its location and integration points here.
2. If the implementation is pending, create at least a design stub outlining expected topics, data contracts, and dependency on the storage service.
