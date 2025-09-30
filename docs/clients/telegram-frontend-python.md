# Telegram Frontend (Python)

**Language**: Python 3 (Poetry project)

## Purpose
Intended to provide a Telegram bot that manages multiple customer-specific sub-bots, sends scheduled broadcasts, facilitates AI-assisted chats, and surfaces Binance trading signals.

## Current Implementation
- Project is structured as a Poetry package with extensive subpackages for bots, routers, services, repositories, scheduling, and infrastructure installers.
- `bots/bot_manager.py` orchestrates `SubBot` instances per customer configuration using SQLAlchemy sessions.
- `bots/sub_bot.py` coordinates subsystem startup (periodic messaging, AI assistant, Binance API) and schedules background jobs.
- Router modules (`routers/`) suggest a command-based interface covering configuration, gateway interactions, OpenAI chat, and health checks.
- Service packages cover integrations with OpenAI, Binance, Elasticsearch, operating system utilities, and indicator calculations.

## Gaps & Issues
- Many imports reference modules that are missing from the repository (`additional_jobs`, `subsystems.ai_assistant`, `db_config`, etc.), preventing the application from running.
- There is no entry point script configuring aiogram/telebot clients despite router scaffolding.
- Tests are effectively empty, providing no safety net for the numerous services.
- Configuration management is undocumented; secrets (API keys, database URLs) lack standardized loading.

## Recommendations
1. Audit the package for missing modules and either restore them or adjust imports to the available structure.
2. Create a concrete startup script that wires routers, middleware, and dependency injection (possibly via `inject` package).
3. Add integration tests that spin up the bot in dry-run mode to validate router registration and subsystem orchestration.
4. Document required environment variables and provide sample configuration files for local development.
