# telegram-frontend-python Service Requirements

## Service overview
The Telegram frontend is an async aiogram bot that orchestrates business messaging, operator tooling, AI-assisted conversations, and trading controls exposed through interactive chats. It is structured as a subsystem-based application bootstrapped via dependency injection.【F:telegram-frontend-python/src/main.py†L1-L38】【F:telegram-frontend-python/README.md†L1-L6】

## Functional scope
- **Subsystem lifecycle management**: `SubsystemManager` groups subsystems by initialization priority, starts them concurrently with `asyncio.gather`, and exposes restart/health inspection APIs for operator tooling.【F:telegram-frontend-python/src/subsystem/subsystem_manager.py†L14-L53】
- **Telegram bot subsystem**: `SlaveBotSubsystem` wires aiogram dispatchers, registers routers, and starts polling the Telegram API while tracking initialization state for health reporting.【F:telegram-frontend-python/src/subsystem/slave_bot_subsystem.py†L12-L31】
- **Operations & trading control UI**: `ActuatorRouter` presents monitoring options, issues Kafka trading commands (start/stop/status), and surfaces subsystem health data from the manager, providing correlation IDs for traceability.【F:telegram-frontend-python/src/routers/actuator_router.py†L27-L108】
- **AI assistant experience**: `OpenAIRouter` delivers conversational flows against the OpenAI API service, managing FSM states for prompt selection, chat continuations, and other AI features invoked from the main menu.【F:telegram-frontend-python/src/routers/openai_router.py†L18-L89】
- **Kafka messaging gateway**: `KafkaMessagingService` manages async producers/consumers, correlation tracking, and notification callbacks, encapsulating the Telegram bot’s interaction with trading microservices through command/status topics.【F:telegram-frontend-python/src/service/messaging/kafka_service.py†L1-L200】

## Configuration contract
- Bot runtime expects dependency injection bindings defined in `inject` modules to supply routers, services, and infrastructure clients. Update these modules when adding new subsystems or external services.
- Kafka settings (bootstrap servers, topics, group IDs, client ID) must be provided via environment variables or configuration files before enabling the messaging service; aiokafka is an optional dependency and must be installed in deployed environments.【F:telegram-frontend-python/src/service/messaging/kafka_service.py†L75-L143】
- OpenAI features require credentials configured for `OpenAIAPIService`; missing configuration should disable routes gracefully.

## Observability requirements
- Leverage the subsystem manager’s `collect_health_data` output to expose health checks through the Actuator dialog and any future HTTP endpoints.【F:telegram-frontend-python/src/routers/actuator_router.py†L55-L62】【F:telegram-frontend-python/src/subsystem/subsystem_manager.py†L45-L46】
- Kafka messaging logs every producer/consumer lifecycle transition, unexpected topic, and command correlation, supporting operational audits.【F:telegram-frontend-python/src/service/messaging/kafka_service.py†L127-L199】
- Main entrypoint logs coroutine debug status and lifecycle transitions for graceful shutdown of the bot process.【F:telegram-frontend-python/src/main.py†L26-L41】

## External dependencies
- Telegram Bot API via aiogram for message routing and FSM dialogs.【F:telegram-frontend-python/src/routers/actuator_router.py†L4-L37】【F:telegram-frontend-python/src/routers/openai_router.py†L1-L47】
- Kafka for trading command exchange with backend services, mediated through `KafkaMessagingService`.【F:telegram-frontend-python/src/service/messaging/kafka_service.py†L35-L200】
- OpenAI API for AI chat/image features; other subsystems (Elasticsearch, PostgreSQL installers) are scaffolded for future integrations per repository structure.【F:telegram-frontend-python/README.md†L3-L6】

## Known gaps & TODOs
- Binance trading and configuration dialogs are marked “in progress”; complete their routers, validation logic, and Kafka command handling before promoting to production.【F:telegram-frontend-python/README.md†L3-L6】
- `main.py` catch-all exception handler currently references an empty tuple (`except ()`); replace with `Exception` to ensure runtime errors are logged rather than silently ignored.【F:telegram-frontend-python/src/main.py†L33-L42】
- Add automated tests/mocks for Kafka messaging flows to ensure command correlation and timeout handling work without an external broker.
