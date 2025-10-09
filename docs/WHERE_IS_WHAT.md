# Where is what

Quick navigation guide to the most important parts of the repository. Use this as a jump table when working across services, infrastructure, monitoring, tests, and scripts.

## Modules and services
- **binance-data-collection**: `binance-data-collection/`
  - Purpose: Collect Binance WebSocket/REST data, publish to Kafka
  - Key config: `src/main/resources/application.yml`, `application-testnet.yml`
  - Build: `mvn -pl binance-data-collection -am clean install`

- **binance-data-storage**: `binance-data-storage/`
  - Purpose: Persist market data (PostgreSQL + Elasticsearch), expose REST + metrics
  - Key config: `src/main/resources/application.yml`, `application-testnet.yml`
  - DB migrations: `src/main/resources/db/migration/`

- **binance-trader-macd**: `binance-trader-macd/`
  - Purpose: MACD strategy service + full backtesting engine
  - Backtesting docs: `binance-trader-macd/BACKTESTING_ENGINE.md`
  - Run demo: `mvn test -pl binance-trader-macd -Dtest=StandaloneBacktestDemo`

- **binance-trader-grid**: `binance-trader-grid/`
  - Purpose: Grid strategy (incomplete/duplicate)

- **binance-shared-model**: `binance-shared-model/`
  - Purpose: Avro schemas and shared models
  - Avro schema: `src/main/avro/*.avsc`

- **telegram-frontend-python**: `telegram-frontend-python/`
  - Purpose: FastAPI + Telegram UI scaffolding
  - App code: `telegram-frontend-python/src/`

## Docker Compose stacks
- Root compose (dev/test): `docker-compose.test.yml`
  - Ports: Grafana 3000, Prometheus 9090, Kafka 9092, Postgres 5432, ES 9200, services 8081/8082/8083

- Testnet stack: `docker-compose-testnet.yml`
  - Ports: Trader 8083, Data Collection 8086, Data Storage 8087, Prometheus 9091, Grafana 3001, ES 9202, Kafka 9095, Postgres 5433, Health Server 8092

- Base infra: `docker-compose.yml`, `docker-compose-kafka-kraft.yml`, `docker-compose-elasticsearch-cluster.yml`

- Monitoring-only: `monitoring/docker-compose.grafana-testnet.yml`

## Monitoring
- Prometheus config: `monitoring/prometheus.yml` (scrapes Java `/actuator/prometheus`, health metrics server `/metrics`)
- Grafana dashboards/provisioning: `monitoring/grafana/`
- Quick open: `scripts/monitoring/open-monitoring.ps1`
- Simple/Comprehensive setup: `scripts/monitoring/setup-dashboard-simple.ps1`, `scripts/monitoring/setup-comprehensive-dashboard.ps1`
- Metrics testing summary: `docs/monitoring/METRICS_TESTING_SUMMARY.md`
- Grafana dashboard setup guide: `docs/monitoring/GRAFANA_DASHBOARD_SETUP.md`

## Scripts (PowerShell)
- Smoke tests: `scripts/tests/quick-test.ps1`, `scripts/tests/test-simple.ps1` (working), `scripts/tests/test-basic.ps1` (has syntax errors)
- Kline tests: `scripts/kline/test-kline-*.ps1`
- Metrics checks: `scripts/metrics/verify-metrics-simple.ps1`, `scripts/metrics/verify-metrics-config.ps1`, `scripts/metrics/check-metrics.ps1`
- Comprehensive tests (Newman): `scripts/run-comprehensive-tests.ps1`
- Monitoring helpers: `scripts/monitoring/open-monitoring.ps1`, `scripts/monitoring/start-grafana-monitoring.ps1`, `scripts/monitoring/start-kline-monitoring*.ps1`, `scripts/monitoring/monitor-*.ps1`

## Postman
- Collections: `postman/Binance-AI-Traders-Comprehensive-Test-Collection.json`, `postman/Binance-AI-Traders-Monitoring-Tests.json`
- Environment: `postman/Binance-AI-Traders-Testnet-Environment.json`
- README: `postman/README.md`

## Build & test
- Build all: `mvn clean install`
- Service-specific: `mvn -pl <module> -am clean install`
- Backtesting demo: `mvn test -pl binance-trader-macd -Dtest=StandaloneBacktestDemo`

## Configuration & environments
- Spring profiles: `application.yml`, `application-testnet.yml` in each Java service
- Testnet env file: `testnet.env`

## Quick links
- Top-level README: `README.md`
- Docs hub: `docs/README.md`
- Agent context: `docs/AGENTS.md`
- Monitoring guide: `MONITORING_GUIDE.md`
- System overview: `docs/overview.md`

---

If something is missing here, consider adding it to keep navigation fast for everyone.


