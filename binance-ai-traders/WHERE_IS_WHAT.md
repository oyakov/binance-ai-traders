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

- **matrix-ui-portal**: `matrix-ui-portal/`
  - Purpose: React/Vite web UI with Matrix theme
  - Spec: `binance-ai-traders/UI_PORTAL_SPECIFICATION.md`
  - Port: 3000 (planned)

## Docker Compose stacks
- Root compose (dev/test): `docker-compose.test.yml`
  - Ports: Grafana 3000, Prometheus 9090, Kafka 9092, Postgres 5432, ES 9200, services 8081/8082/8083

- Testnet stack: `docker-compose-testnet.yml`
  - Ports: Trader 8083, Data Collection 8086, Data Storage 8087, Prometheus 9091, Grafana 3001, ES 9202, Kafka 9095, Postgres 5433, Health Server 8092

- Base infra: `docker-compose.yml`, `docker-compose-kafka-kraft.yml`, `docker-compose-elasticsearch-cluster.yml`

- Monitoring-only: `monitoring/docker-compose.grafana-testnet.yml`

## Security and Deployment
- **Public Deployment Security Guide**: `binance-ai-traders/guides/PUBLIC_DEPLOYMENT_SECURITY_GUIDE.md`
  - VPS deployment architecture, SSH hardening, secrets management, network security
- **VPS Setup Guide**: `binance-ai-traders/guides/VPS_SETUP_GUIDE.md`
  - Initial VPS provisioning, SSH keys, firewall, fail2ban, Docker installation
- **Incident Response Guide**: `binance-ai-traders/guides/INCIDENT_RESPONSE_GUIDE.md`
  - Security incident procedures, containment, recovery, communication
- **Security Verification Checklist**: `binance-ai-traders/guides/SECURITY_VERIFICATION_CHECKLIST.md`
  - Pre-deployment checklist, 100+ verification items
- **Security Hardening Guide**: `binance-ai-traders/guides/SECURITY_HARDENING_GUIDE.md`
  - High-grade security controls, compliance, technical hardening

### Secrets Management
- **SOPS Configuration**: `.sops.yaml` (age encryption configuration)
- **Environment Template**: `testnet.env.template` (documented template for secrets)
- **Encrypted Secrets**: `testnet.env.enc` (SOPS-encrypted, safe to commit)
- **Secrets Scripts**: `scripts/security/`
  - `setup-secrets.ps1` - Generate strong passwords and API keys
  - `encrypt-secrets.ps1` - Encrypt environment files with SOPS
  - `decrypt-secrets.ps1` - Decrypt for deployment
  - `rotate-secrets.ps1` - Secret rotation workflow
  - `test-security-controls.ps1` - Comprehensive security validation

### Network Security
- **Nginx Reverse Proxy**: `nginx/nginx.conf`
  - TLS 1.3, rate limiting, security headers, request size limits
- **API Gateway**: `nginx/conf.d/api-gateway.conf`
  - Service routing, authentication checks, endpoint protection
- **TLS Certificates**: `nginx/ssl/` (cert.pem, key.pem)

### Deployment Scripts
**Location**: `scripts/deployment/`
- **README**: Complete deployment scripts overview
- **Step-by-Step Deploy**: `step-by-step-deploy.ps1` - Interactive deployment guide (RECOMMENDED)
- **Automated Deploy**: `deploy-to-vps-automated.ps1` - Partially automated deployment
- **Quick Deploy (VPS)**: `quick-deploy.sh` - Application deployment on VPS
- **Deployment Guide**: `DEPLOYMENT_GUIDE.md` - Complete deployment reference

**Quick Start**: `.\scripts\deployment\step-by-step-deploy.ps1`

### Security Monitoring & Testing
- **Security Dashboard**: `monitoring/grafana/provisioning/dashboards/08-security/security-monitoring.json`
- **Prometheus Alerts**: `monitoring/prometheus/security_alerts.yml` (48 security alert rules)
- **Security Tests**: `postman/Security-Tests-Collection.json` (18 automated tests)

## Monitoring
- Prometheus config: `monitoring/prometheus.yml` (scrapes Java `/actuator/prometheus`, health metrics server `/metrics`)
- Grafana dashboards/provisioning: `monitoring/grafana/`
- Dashboard inventory: `monitoring/grafana/DASHBOARD_INVENTORY.md` (8 dashboards across 10 categories)
- Dashboard structure: `monitoring/grafana/DASHBOARD_STRUCTURE.md`
- Quick open: `scripts/monitoring/open-monitoring.ps1`
- Simple/Comprehensive setup: `scripts/monitoring/setup-dashboard-simple.ps1`, `scripts/monitoring/setup-comprehensive-dashboard.ps1`
- Metrics testing summary: `binance-ai-traders/monitoring/METRICS_TESTING_SUMMARY.md`
- Grafana dashboard setup guide: `binance-ai-traders/monitoring/GRAFANA_DASHBOARD_SETUP.md`

## Scripts (PowerShell, Python, SQL)
**Complete Index**: `scripts/INDEX.md` (87 PS1, 7 SQL, 6 Python files)

### Quick Reference
- Smoke tests: `scripts/tests/quick-test.ps1`, `scripts/tests/test-simple.ps1` (working), `scripts/tests/test-basic.ps1` (has syntax errors)
- Kline tests: `scripts/kline/test-kline-*.ps1`
- Metrics checks: `scripts/metrics/verify-metrics-simple.ps1`, `scripts/metrics/verify-metrics-config.ps1`, `scripts/metrics/check-metrics.ps1`
- Comprehensive tests (Newman): `scripts/run-comprehensive-tests.ps1`
- Monitoring helpers: `scripts/monitoring/open-monitoring.ps1`, `scripts/monitoring/start-grafana-monitoring.ps1`, `scripts/monitoring/start-kline-monitoring*.ps1`
- Backfill operations: `scripts/backfill/backfill_klines.py`, `scripts/backfill/load_csv_to_postgres.py`
- SQL diagnostics: `scripts/sql-diagnostics/` (database health, kline analysis, performance monitoring)
- Build acceleration: `scripts/build/build-data-collection-fast.ps1`
- Storage tests: `scripts/storage/test-storage-fix.ps1`

## Testing & Validation
**Quick Start**: `binance-ai-traders/TESTING_QUICK_START.md` - Fast-track testing guide

### Comprehensive System Testing
- **Master Plan**: `binance-ai-traders/COMPREHENSIVE_SYSTEM_TESTING_AND_ARCHITECTURE_EVALUATION_PLAN.md`
  - Complete testing scope and strategy
  - Architecture evaluation criteria
  - Detailed test categories and validation checklists
  - Issue classification and success metrics
- **Automated Test Script**: `scripts/run-complete-system-test.ps1`
  - Full automated test execution (4-6 hours)
  - Generates comprehensive reports
  - Run: `.\scripts\run-complete-system-test.ps1`
- **Test Checklist**: `binance-ai-traders/SYSTEM_TEST_CHECKLIST.md`
  - Printable checklist for manual testing
  - Architecture scorecard (0-100 points)
  - Issue tracking templates

### Test Plans
- **Comprehensive System Testing**: `binance-ai-traders/test-plan-comprehensive-system-testing.md`
- **MACD Trader Testing**: `binance-ai-traders/test-plan-macd-trader.md`
- **Testability & Observability**: `binance-ai-traders/TESTABILITY_OBSERVABILITY_IMPLEMENTATION_STATUS.md`

### Postman Collections
- **Collections**: `postman/Binance-AI-Traders-Comprehensive-Test-Collection.json`, `postman/Binance-AI-Traders-Monitoring-Tests.json`, `postman/PostgreSQL-Kafka-Health-Tests.json`
- **Environment**: `postman/Binance-AI-Traders-Testnet-Environment.json`
- **README**: `postman/README.md`
- **Run Tests**: `scripts/run-comprehensive-tests.ps1`

## Build & test
- Build all: `mvn clean install`
- Service-specific: `mvn -pl <module> -am clean install`
- Backtesting demo: `mvn test -pl binance-trader-macd -Dtest=StandaloneBacktestDemo`

## Configuration & environments
- Spring profiles: `application.yml`, `application-testnet.yml` in each Java service
- Testnet env file: `testnet.env`

## API Documentation
- REST API endpoints: `binance-ai-traders/API_ENDPOINTS.md` (comprehensive API reference)
- binance-data-storage: `/api/v1/klines`, `/api/v1/macd`, `/api/v1/observability`
- binance-trader-macd: `/api/v1/macd/indicator`, `/api/v1/macd/update`, `/api/v1/macd/stats`

## Memory System
- Memory index: `binance-ai-traders/memory/memory-index.md` (31 active entries)
- Findings: `binance-ai-traders/memory/findings/` (MEM-001 to MEM-F001)
- Context: `binance-ai-traders/memory/context/` (MEM-C001 to MEM-C009)
- Infrastructure: `binance-ai-traders/memory/` (MEM-I001 to MEM-I007)
- Updates: `binance-ai-traders/memory/updates/`

## Quick links
- Top-level README: `README.md`
- Project docs: `binance-ai-traders/` (main documentation folder)
- Agent context: `binance-ai-traders/AGENTS.md` (comprehensive agent guidance)
- Project rules: `binance-ai-traders/PROJECT_RULES.md`
- Monitoring guide: `binance-ai-traders/monitoring/MONITORING_GUIDE.md`
- System overview: `binance-ai-traders/overview.md`
- Service docs: `binance-ai-traders/services/` (individual service documentation)
- Guides: `binance-ai-traders/guides/` (QUICK_START, TESTNET_LAUNCH, MILESTONE_GUIDE, etc.)
- Monitoring reports: `binance-ai-traders/reports/monitoring/`
- Status reports: `binance-ai-traders/reports/status/`
- Incident reports: `binance-ai-traders/reports/incidents/`
- Document inventory: `binance-ai-traders/overview/DOCUMENT_INVENTORY.md`

---

If something is missing here, consider adding it to keep navigation fast for everyone.


