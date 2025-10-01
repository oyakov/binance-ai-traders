import asyncio
from types import SimpleNamespace
from unittest.mock import AsyncMock

import pytest

from routers.actuator_router import ActuatorRouter
from service.messaging.kafka_service import TradingCommand


def test_start_trading_command_triggers_kafka_call():
    kafka_service = AsyncMock()
    kafka_service.send_command = AsyncMock(return_value="corr-start")
    kafka_service.request_status = AsyncMock()

    router = ActuatorRouter(kafka_service)
    router.subsystem_manager = AsyncMock()

    message = SimpleNamespace(
        chat=SimpleNamespace(id=123),
        reply=AsyncMock(),
        answer=AsyncMock(),
    )
    callback_query = SimpleNamespace(message=message, data="start_trading")

    async def runner():
        await router.selected_option_callback(callback_query, AsyncMock(), kafka_service)

    asyncio.run(runner())

    kafka_service.send_command.assert_awaited_once()
    sent_command = kafka_service.send_command.call_args.args[0]
    assert isinstance(sent_command, TradingCommand)
    assert sent_command.action == "START_TRADING"
    message.reply.assert_awaited()
    message.answer.assert_awaited()


def test_request_status_handles_timeout():
    kafka_service = AsyncMock()
    kafka_service.send_command = AsyncMock()
    kafka_service.request_status = AsyncMock(side_effect=asyncio.TimeoutError)

    router = ActuatorRouter(kafka_service)
    router.subsystem_manager = AsyncMock()

    message = SimpleNamespace(
        chat=SimpleNamespace(id=123),
        reply=AsyncMock(),
        answer=AsyncMock(),
    )
    callback_query = SimpleNamespace(message=message, data="request_status")

    async def runner():
        await router.selected_option_callback(callback_query, AsyncMock(), kafka_service)

    asyncio.run(runner())

    kafka_service.request_status.assert_awaited_once()
    message.reply.assert_awaited()
    message.answer.assert_awaited()
