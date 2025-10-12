# Testnet Monitoring with Prometheus & Grafana

This guide explains how to visualize the Binance MACD trading service while it runs against the Binance Spot testnet. The stack uses Prometheus to scrape the Spring Boot Actuator metrics that are already exposed by the trader and Grafana to render an opinionated dashboard.

## Prerequisites

1. A deployed instance of the `binance-trader-macd` service targeting the testnet (set `BINANCE_REST_BASE_URL=https://testnet.binance.vision` and `BINANCE_TRADER_TEST_ORDER_MODE_ENABLED=true` for dry-run order placement).
2. The Actuator `/actuator/prometheus` endpoint reachable from the monitoring host.
3. Docker installed locally to launch the Prometheus and Grafana containers.

## Configuration Files

The repository provides a dedicated monitoring bundle under `monitoring/`:

- [`monitoring/prometheus/testnet-prometheus.yml`](../../monitoring/prometheus/testnet-prometheus.yml) – scrapes the trader's Prometheus endpoint every 15 seconds and tags the metrics with `environment="testnet"`.
- [`monitoring/grafana/dashboards/binance-macd-testnet.json`](../../monitoring/grafana/dashboards/binance-macd-testnet.json) – dashboard with panels for open positions, realized PnL, and signal volume.
- [`monitoring/grafana/provisioning/datasources/prometheus.yml`](../../monitoring/grafana/provisioning/datasources/prometheus.yml) – preconfigures Grafana with a Prometheus data source pointing at the local Prometheus container.
- [`monitoring/grafana/provisioning/dashboards/testnet-dashboards.yml`](../../monitoring/grafana/provisioning/dashboards/testnet-dashboards.yml) – auto-imports dashboards stored in the mounted directory.
- [`monitoring/docker-compose.grafana-testnet.yml`](../../monitoring/docker-compose.grafana-testnet.yml) – launches Prometheus and Grafana with the provisioning files mounted.

## Setup Instructions

1. **Update the scrape target**

   Edit [`monitoring/prometheus/testnet-prometheus.yml`](../../monitoring/prometheus/testnet-prometheus.yml) so that the `macd-trader-testnet:8080` host matches the reachable hostname or IP for your testnet deployment (for example `trader.internal:8080` or `10.0.0.5:8080`).

2. **Start Prometheus and Grafana**

   From the repository root run:

   ```bash
   docker compose -f monitoring/docker-compose.grafana-testnet.yml up -d
   ```

   Prometheus listens on <http://localhost:9090> and Grafana on <http://localhost:3000>. The default Grafana credentials are `admin` / `admin` (change them on first login).

3. **Validate metric ingestion**

   - Open the Prometheus expression browser and execute `binance_trader_active_positions` to confirm samples are arriving.
   - In Grafana, the *Testnet MACD Trader Overview* dashboard should appear under the “Testnet Trading” folder. Use the *Instance* drop-down to narrow to a specific trader pod if multiple replicas are running.

## Dashboard Overview

The curated dashboard surfaces three key telemetry streams exposed by the MACD trader service:

| Panel | Metric | Description |
| --- | --- | --- |
| **Active Positions** | `binance_trader_active_positions` | Shows how many orders are currently open according to the trader's state store. Thresholds highlight more than five concurrent positions. |
| **Realized PnL (Testnet)** | `binance_trader_realized_pnl` | Tracks realized profit and loss by quote asset so you can verify strategy stability on the testnet without risking funds. |
| **Signal Volume (last 1h)** | `increase(binance_trader_signals_total{direction!="total"}[1h])` | Uses a 1-hour rolling window to display how many buy/sell signals the trader processed. |

Because the Actuator metrics already encode labels such as `direction` and `quote_asset`, Grafana automatically separates series by those dimensions. You can extend the dashboard with additional panels (e.g., error budgets or latency histograms) by editing the JSON or through the Grafana UI.

## Operational Tips

- **Alerting**: Configure recording and alerting rules in Prometheus (e.g., alert when `binance_trader_active_positions` stays at zero for an extended period) and pair them with Grafana Alerting or your on-call tooling.
- **Multiple environments**: Duplicate the scrape job with a different `environment` label if you monitor both testnet and mainnet traders from the same Prometheus instance.
- **Security**: Replace the default Grafana admin password and, if exposing dashboards publicly, place Grafana behind an authenticated proxy or VPN.

With these assets you gain immediate visibility into the testnet trading behaviour while keeping the monitoring stack isolated from the live trading infrastructure.
