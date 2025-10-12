# Binance AI Traders – Capability Evaluation & Runnable Task Backlog

**Source Reference:** *Crypto Trading System: Strategies for Growth and Roadmap to Production* (January 2025 briefing)

## 1. Current Capability Assessment

### 1.1 Trading & Analytics Stack
- **Backtesting Engine:** Complete MACD engine with 2,400+ scenarios and documented top configurations (e.g., XRP/USDT MACD 30-60-15 delivering ~413% annualized return).
- **Strategy Diversity:** Only the MACD strategy is production-grade. Grid trading is a placeholder; swing, scalping, and arbitrage strategies are not yet implemented.
- **Signal Execution:** Live MACD trader lacks full order lifecycle (entries, stops, exits) and has not produced signals in recent multi-day testnet runs.

### 1.2 Data Platform
- **Market Data Ingestion:** WebSocket collectors and Kafka producers for Binance are missing, so real-time feeds rely on manual imports.
- **Persistence & Analytics:** PostgreSQL and Elasticsearch storage flows are validated for klines and MACD results once data is available.
- **Observability:** Grafana/Prometheus stack is operational, but dashboards are geared toward infrastructure metrics rather than strategy performance.

### 1.3 User & Agent Experience
- **Telegram Frontend:** Extensive scaffolding exists, yet critical dependencies and modules are absent, preventing deployment.
- **Mechanicus/Agent Layer:** Agent concepts are defined; integration points with the trading stack still need concrete tooling and automation hooks.
- **Operator UX Assets:** High-fidelity UI/UX templates and PSD diagrams described in the roadmap are pending creation.

### 1.4 Deployment Readiness
- **Testnet (M1):** Infrastructure spins up, but service gaps (data collection, grid logic, Telegram UI) block extended soak testing.
- **Production (M2):** Security hardening, runbooks, and automated risk controls are partially specified but not implemented.
- **Multi-Exchange (M3+):** No connector abstraction or exchange plugins exist yet.

## 2. Runnable Next Tasks

### 2.1 Complete M1 Testnet Foundations
1. **Implement Binance WebSocket Consumer & Kafka Publisher** in `binance-data-collection` so klines stream continuously.
2. **Finish MACD Trade Execution Pipeline** (order submission, stop-loss/take-profit enforcement, error handling) inside `binance-trader-macd`.
3. **Replace Grid Trader Scaffolding** with an operational range-trading engine tailored for sideways markets.
4. **Stabilize Telegram Frontend** by resolving missing dependencies, wiring FastAPI/aiogram modules, and exposing health checks.
5. **Enrich Observability Dashboards** with strategy P&L, drawdown, and recommendation panels that the agent can reference.

### 2.2 Prepare M2 Production Launch
1. **Introduce Secure Credential Storage** (encrypted secrets, rotation process) for Binance API keys across services.
2. **Document and Automate Kill-Switch Controls** to halt trading when drawdown thresholds are breached.
3. **Generate AI-Assisted Daily Runbooks** summarizing production trades, anomalies, and recommended adjustments.
4. **Finalize Compliance Reporting Templates** covering trade logs, tax summaries, and audit trails.

### 2.3 Lay the Groundwork for M3 Multi-Exchange Expansion
1. **Define an Exchange Connector Interface** shared across traders (market data, order management, account info).
2. **Prototype a Second Exchange Connector** (e.g., Coinbase Advanced Trade) using the new abstraction.
3. **Design Swing & Arbitrage Strategy Specifications** so implementation can begin once additional exchanges are supported.
4. **Produce Visual Architecture & UI Templates** (PSD/diagram assets) to guide future agentic contributors and UI development.

## 3. Milestone Alignment
- **M1 (Testnet)** focuses on delivering reliable live data, diversified strategies (MACD + grid + swing roadmap), and an operator-friendly UI bolstered by Mechanicus insights.
- **M2 (Production)** prioritizes small-account safety ($300 budget), transparent reporting, and AI-authored operator guidance.
- **M3 (Scaling & Multi-Exchange)** expands strategy coverage across additional exchanges, enabling arbitrage and redundancy.
- **M4 (Institutional Readiness)** layers on comprehensive compliance, advanced order types, and polished UX artifacts.

## 4. Immediate Action Checklist
- [ ] Kick off WebSocket ingestion sprint with integration tests against Binance testnet streams.
- [ ] Schedule pair-programming session to complete MACD order execution and backstop risk logic.
- [ ] Draft grid strategy specification (parameters, inventory balancing rules) before coding begins.
- [ ] Compile dependency manifest for the Telegram frontend to unblock environment setup.
- [ ] Outline AI runbook generation flow (data sources, formatting, delivery channel).

---
*Maintained by: Roadmap Working Group (January 2025)*
