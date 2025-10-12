# Binance Shared Model Library

**Language**: Java, Avro-generated classes

## Purpose
Provides Avro schemas and generated Java classes used to serialize cross-service events, currently limited to the `KlineEvent` record.

## Current Implementation
- `avro/KlineEvent.java` is the Avro-generated POJO representing candlestick data with decimal logical types for prices and volume.
- No hand-written utilities or schema registry helpers are included.

## Integration Notes
- Services must configure Avro serializers/deserializers (`KafkaAvroSerializer` / `KafkaAvroDeserializer`) and register the schema with Confluent Schema Registry.
- When extending the schema, regenerate the Java classes and ensure compatibility policies are satisfied.

## Recommendations
1. Add build tooling (e.g., Maven `avro-maven-plugin`) to regenerate classes from `.avsc` files rather than committing generated code only.
2. Document schema evolution guidelines and topic compatibility levels to avoid breaking consumers.
