# Repository Guidance

## Repository Context
- **Name**: binance-ai-traders
- **Purpose**: Collection of services and libraries supporting automated trading strategies on Binance, including data collection, shared models, and strategy-specific traders.
- **Structure**: Monorepo with multiple Python packages and service directories (e.g., `binance-data-collection`, `binance-data-storage`, strategy bots, and Telegram frontend).

## Governance Tasks
- Maintain coherent shared APIs and configuration formats across subprojects.
- Keep dependencies aligned and document version changes in relevant READMEs.
- Ensure Docker compose stacks remain functional and tested after modifications.
- Coordinate cross-service changes through issues referencing all impacted components.

## Code Conventions
- Prefer Python 3.11 features where available, but remain backward compatible with 3.10 for deployed services.
- Enforce PEP 8 style and use type hints with `typing` or `pydantic` models.
- Organize modules by domain; avoid circular imports by using interfaces in `binance-shared-model`.
- Write docstrings for public functions/classes and include usage examples when practical.

## Testing Expectations
- Run unit tests for modified packages with `pytest`.
- For services using Docker, execute relevant integration checks via `docker compose` where feasible.
- Validate linting with `ruff` and type checks with `mypy` when touching Python code.
- Document any un-run required tests with justification in PRs.

## Contribution Workflow Guidance
1. Create feature or bugfix branches from `main`.
2. Keep commits logically scoped; reference issue IDs when available.
3. Update documentation (README, diagrams) alongside code changes that affect behavior.
4. Submit PRs with:
   - Summary of changes and rationale.
   - Tests executed and their outcomes.
   - Follow-up tasks or deployment notes if applicable.
5. Request review from domain owners for affected services.
