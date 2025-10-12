# binance-trader-grid Service Requirements

## Service overview
The grid trader module is currently a scaffold copied from the data-storage service with the goal of evolving into an independent grid-trading engine. No Spring beans are auto-registered, and runtime wiring is intentionally disabled until the domain model and APIs are implemented.【F:binance-trader-grid/README.md†L1-L24】

## Functional scope (current state)
- Provides pure Java domain types for grid strategy configuration (price ranges, level definitions, risk parameters) but does not yet expose services or controllers.
- Bundles placeholder Kafka, repository, and service classes that mirror data-storage implementations; these are not active and will be replaced as grid-specific logic is developed.【F:binance-trader-grid/src/main/java/com/oyakov/binance_data_storage/service/impl/KlineDataService.java†L1-L40】
- Includes example YAML configuration documenting the intended format for grid strategy definitions. The file is documentation-only and not loaded by Spring.【F:binance-trader-grid/README.md†L11-L24】

## Planned functional requirements
- Introduce Spring configuration to expose REST APIs for grid strategy CRUD operations behind a feature flag.
- Integrate with market data (Kafka) and Binance order execution similar to the MACD trader but tailored to grid-level placement logic.
- Persist strategy state, executed orders, and performance metrics to PostgreSQL and surface them through monitoring dashboards.【F:binance-trader-grid/README.md†L14-L21】

## Configuration contract
- No external configuration is consumed at runtime yet; future implementations should follow the `binance.*` namespace convention established by other services for consistency.

## Observability requirements
- Define Prometheus metrics once the runtime behavior is added. Reuse naming patterns from `binance.trader.*` metrics to enable drop-in dashboards.

## Known gaps & TODOs
- Replace duplicated data-storage classes with grid-specific domain and service layers; remove dead code to avoid confusion during dependency analysis.【F:binance-trader-grid/src/main/java/com/oyakov/binance_data_storage/BinanceDataStorageApplication.java†L1-L15】
- Establish automated tests to validate grid level calculations and risk checks once the business logic is implemented.
- Wire feature-flagged beans gradually to avoid destabilizing existing deployments during the migration from scaffold to production service.
