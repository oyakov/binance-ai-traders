# Microservice Requirements Index

This directory consolidates the current functional and non-functional requirements for every deployable component in the **binance-ai-traders** platform. Each service-specific file captures the latest behaviors discovered in code, public interfaces, configuration contracts, dependencies, and observability expectations. Use these documents as the single source of truth when planning work, reviewing architecture, or verifying acceptance criteria.

## Contents
- [binance-data-collection](binance-data-collection.md)
- [binance-data-storage](binance-data-storage.md)
- [binance-trader-macd](binance-trader-macd.md)
- [binance-trader-grid](binance-trader-grid.md)
- [binance-shared-model](binance-shared-model.md)
- [telegram-frontend-python](telegram-frontend-python.md)
- [matrix-ui-portal](matrix-ui-portal.md)

## How to use these requirements
1. **Start with the high-level flow**: Review `docs/overview/` and the system memory entries, then use this directory to dive into the exact contract for the component you are modifying.
2. **Trace dependencies**: Every requirements file lists inbound/outbound integrations so you can identify upstream and downstream impacts before coding.
3. **Verify implementation coverage**: Cross-check the documented behaviors against the code paths and metrics cited in each section. Missing functionality is called out explicitly as open work.
4. **Update alongside code changes**: When a service adds an endpoint, alters message schemas, or introduces new configuration, amend the matching requirements file in the same commit.

## Documentation conventions
- Functional scope is organized around externally visible behaviors (APIs, message handling, scheduled jobs).
- Non-functional scope covers performance, resilience, observability, and configuration requirements.
- Known gaps or TODO items are preserved so future work can be prioritized without rescanning the code base.
- References include the key classes and line numbers that enforce each requirement for quick verification.
