"""Kafka integration utilities for the Telegram frontend."""

from __future__ import annotations

import asyncio
import contextlib
import json
import uuid
from dataclasses import dataclass, field
from typing import Any, Awaitable, Callable, Dict, List, Optional

try:  # pragma: no cover - import guard for test environments
    from aiokafka import AIOKafkaConsumer, AIOKafkaProducer
except ImportError:  # pragma: no cover
    class AIOKafkaProducer:  # type: ignore[override]
        def __init__(self, *args, **kwargs):
            raise RuntimeError(
                "aiokafka is required for KafkaMessagingService; install the optional dependency to enable Kafka integration."
            )

    class AIOKafkaConsumer:  # type: ignore[override]
        def __init__(self, *args, **kwargs):
            raise RuntimeError(
                "aiokafka is required for KafkaMessagingService; install the optional dependency to enable Kafka integration."
            )

from oam import log_config

logger = log_config.get_logger(__name__)


NotificationCallback = Callable[["NotificationMessage"], Awaitable[None]]


@dataclass(slots=True)
class TradingCommand:
    """Command envelope that is published to Kafka."""

    action: str
    payload: Dict[str, Any] = field(default_factory=dict)
    correlation_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    reply_to: Optional[str] = None

    def to_message(self) -> Dict[str, Any]:
        """Convert the command to a serialisable dictionary."""

        message = {
            "action": self.action,
            "payload": self.payload,
            "correlation_id": self.correlation_id,
        }
        if self.reply_to:
            message["reply_to"] = self.reply_to
        return message


@dataclass(slots=True)
class CommandResponse:
    """Response envelope received from Kafka when evaluating bot state."""

    correlation_id: str
    status: str
    payload: Dict[str, Any] = field(default_factory=dict)


@dataclass(slots=True)
class NotificationMessage:
    """Notification emitted by downstream trading services."""

    message: str
    level: str = "INFO"
    source: Optional[str] = None
    correlation_id: Optional[str] = None


class KafkaMessagingService:
    """Facade over aiokafka producer/consumer with focus on observability."""

    def __init__(
        self,
        bootstrap_servers: str,
        command_topic: str,
        status_topic: str,
        notification_topic: str,
        consumer_group: str,
        client_id: str | None = None,
        *,
        producer: AIOKafkaProducer | None = None,
        consumer: AIOKafkaConsumer | None = None,
        enable_consumer: bool = True,
    ) -> None:
        self._bootstrap_servers = bootstrap_servers
        self._command_topic = command_topic
        self._status_topic = status_topic
        self._notification_topic = notification_topic
        self._consumer_group = consumer_group
        self._client_id = client_id
        if producer is None:
            self._producer = AIOKafkaProducer(
                bootstrap_servers=self._bootstrap_servers,
                client_id=self._client_id,
                value_serializer=lambda payload: json.dumps(payload).encode("utf-8"),
            )
        else:
            self._producer = producer

        if not enable_consumer:
            self._consumer = None
        elif consumer is None:
            self._consumer = AIOKafkaConsumer(
                self._status_topic,
                self._notification_topic,
                bootstrap_servers=self._bootstrap_servers,
                group_id=self._consumer_group,
                client_id=self._client_id,
                value_deserializer=lambda payload: json.loads(payload.decode("utf-8")),
                enable_auto_commit=True,
            )
        else:
            self._consumer = consumer
        self._producer_started = False
        self._consumer_started = False
        self._listener_task: asyncio.Task | None = None
        self._pending: Dict[str, asyncio.Future[CommandResponse]] = {}
        self._notification_callbacks: List[NotificationCallback] = []

    async def start(self) -> None:
        """Start producer and consumer connections."""

        if not self._producer_started:
            logger.info("Starting Kafka producer (client_id=%s)", self._client_id)
            await self._producer.start()
            self._producer_started = True

        if not self._consumer_started and self._consumer is not None:
            logger.info(
                "Starting Kafka consumer (topics=%s, group=%s)",
                [self._status_topic, self._notification_topic],
                self._consumer_group,
            )
            await self._consumer.start()
            self._consumer_started = True
            self._listener_task = asyncio.create_task(self._listen(), name="kafka-listener")

    async def stop(self) -> None:
        """Stop producer, consumer and cancel listener task."""

        if self._listener_task:
            self._listener_task.cancel()
            with contextlib.suppress(asyncio.CancelledError):
                await self._listener_task
            self._listener_task = None

        if self._consumer_started and self._consumer is not None:
            logger.info("Stopping Kafka consumer")
            await self._consumer.stop()
            self._consumer_started = False

        if self._producer_started:
            logger.info("Stopping Kafka producer")
            await self._producer.stop()
            self._producer_started = False

        # Cancel pending requests to avoid memory leak
        for correlation_id, future in list(self._pending.items()):
            if not future.done():
                future.cancel()
            self._pending.pop(correlation_id, None)

    async def _listen(self) -> None:
        """Listen for messages from Kafka and dispatch them."""

        try:
            assert self._consumer is not None
            async for record in self._consumer:
                payload = record.value
                topic = record.topic
                await self._handle_message(topic, payload)
        except asyncio.CancelledError:
            logger.info("Kafka listener cancelled")
            raise
        except Exception as exc:  # pragma: no cover - defensive logging branch
            logger.exception("Unexpected error while consuming Kafka messages: %s", exc)

    async def _handle_message(self, topic: str, payload: Dict[str, Any]) -> None:
        """Route messages to the appropriate handler based on topic."""

        if topic == self._status_topic:
            await self._handle_status_message(payload)
        elif topic == self._notification_topic:
            await self._handle_notification_message(payload)
        else:  # pragma: no cover - unexpected topics are logged only
            logger.warning("Received message for unrecognised topic %s", topic)

    async def _handle_status_message(self, payload: Dict[str, Any]) -> None:
        correlation_id = payload.get("correlation_id")
        status = payload.get("status", "UNKNOWN")
        response = CommandResponse(
            correlation_id=correlation_id or "",
            status=status,
            payload=payload.get("payload", {}),
        )
        logger.info(
            "Received command response (correlation_id=%s, status=%s)",
            response.correlation_id,
            response.status,
        )
        if correlation_id and correlation_id in self._pending:
            future = self._pending.pop(correlation_id)
            if not future.done():
                future.set_result(response)
        else:
            logger.debug("No pending request for correlation_id=%s", correlation_id)

    async def _handle_notification_message(self, payload: Dict[str, Any]) -> None:
        notification = NotificationMessage(
            message=payload.get("message", ""),
            level=payload.get("level", "INFO"),
            source=payload.get("source"),
            correlation_id=payload.get("correlation_id"),
        )
        logger.info(
            "Received notification (level=%s, source=%s, correlation_id=%s)",
            notification.level,
            notification.source,
            notification.correlation_id,
        )
        if not notification.message:
            logger.debug("Skipping empty notification payload")
            return

        if not self._notification_callbacks:
            logger.debug("No notification callbacks registered; dropping message")
            return

        await asyncio.gather(
            *(callback(notification) for callback in list(self._notification_callbacks)),
            return_exceptions=False,
        )

    async def send_command(self, command: TradingCommand) -> str:
        """Send a command to the trading system."""

        if not self._producer_started:
            raise RuntimeError("KafkaMessagingService is not started")

        logger.info(
            "Publishing command (action=%s, correlation_id=%s)",
            command.action,
            command.correlation_id,
        )
        await self._producer.send_and_wait(self._command_topic, command.to_message())
        return command.correlation_id

    async def request_status(
        self,
        action: str,
        payload: Optional[Dict[str, Any]] = None,
        *,
        timeout: float = 10.0,
    ) -> CommandResponse:
        """Send a command that expects a response."""

        if not self._producer_started:
            raise RuntimeError("KafkaMessagingService is not started")

        command = TradingCommand(action=action, payload=payload or {}, reply_to=self._status_topic)
        loop = asyncio.get_running_loop()
        future: asyncio.Future[CommandResponse] = loop.create_future()
        self._pending[command.correlation_id] = future
        try:
            await self.send_command(command)
            logger.debug("Waiting for response correlation_id=%s", command.correlation_id)
            response = await asyncio.wait_for(future, timeout=timeout)
            return response
        except asyncio.TimeoutError:
            logger.warning("Status request timed out (correlation_id=%s)", command.correlation_id)
            raise
        finally:
            self._pending.pop(command.correlation_id, None)

    def register_notification_handler(self, callback: NotificationCallback) -> None:
        """Register a coroutine callback for Kafka notifications."""

        self._notification_callbacks.append(callback)

    def unregister_notification_handler(self, callback: NotificationCallback) -> None:
        """Remove a previously registered notification callback."""

        with contextlib.suppress(ValueError):
            self._notification_callbacks.remove(callback)
