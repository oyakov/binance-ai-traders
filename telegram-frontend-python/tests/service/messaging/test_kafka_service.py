import asyncio
from unittest.mock import AsyncMock

import pytest

from service.messaging.kafka_service import KafkaMessagingService, NotificationMessage


@pytest.fixture
def kafka_service_stub():
    producer = AsyncMock()
    producer.start = AsyncMock()
    producer.stop = AsyncMock()
    producer.send_and_wait = AsyncMock()

    service = KafkaMessagingService(
        bootstrap_servers="localhost:9092",
        command_topic="commands",
        status_topic="status",
        notification_topic="notifications",
        consumer_group="telegram-tests",
        client_id="telegram-tests",
        producer=producer,
        consumer=None,
        enable_consumer=False,
    )
    return service, producer


def test_send_command_requires_start(kafka_service_stub):
    service, _ = kafka_service_stub

    async def runner():
        with pytest.raises(RuntimeError):
            await service.send_command(action_command("PING"))

    asyncio.run(runner())


def action_command(action: str):
    from service.messaging.kafka_service import TradingCommand

    return TradingCommand(action=action)


def test_send_command_publishes_payload(kafka_service_stub):
    service, producer = kafka_service_stub

    async def runner():
        await service.start()
        command = action_command("PING")
        correlation_id = await service.send_command(command)
        producer.send_and_wait.assert_awaited_once()
        args, _ = producer.send_and_wait.call_args
        assert args[0] == "commands"
        assert args[1]["action"] == "PING"
        assert correlation_id == command.correlation_id

    asyncio.run(runner())


def test_request_status_resolves_on_message(kafka_service_stub):
    service, producer = kafka_service_stub

    async def runner():
        await service.start()
        producer.send_and_wait.reset_mock()

        async def perform_request():
            return await service.request_status("STATUS", timeout=1.0)

        task = asyncio.create_task(perform_request())
        await asyncio.sleep(0)
        assert service._pending  # pylint: disable=protected-access
        correlation_id = next(iter(service._pending.keys()))
        await service._handle_status_message(  # pylint: disable=protected-access
            {
                "correlation_id": correlation_id,
                "status": "OK",
                "payload": {"healthy": True},
            }
        )

        response = await task
        assert response.status == "OK"
        assert response.payload == {"healthy": True}

    asyncio.run(runner())


def test_notification_callback_invoked(kafka_service_stub):
    service, _ = kafka_service_stub

    async def runner():
        await service.start()
        callback = AsyncMock()
        service.register_notification_handler(callback)

        notification = NotificationMessage(message="Trade executed", level="INFO", source="test")
        await service._handle_notification_message(  # pylint: disable=protected-access
            {
                "message": notification.message,
                "level": notification.level,
                "source": notification.source,
                "correlation_id": "corr-123",
            }
        )

        callback.assert_awaited_once()

    asyncio.run(runner())
