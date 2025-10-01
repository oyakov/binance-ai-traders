from typing import Optional

from aiogram import Bot
from injector import inject

from oam import log_config
from oam.environment import CHAT_ID
from service.messaging.kafka_service import KafkaMessagingService, NotificationMessage
from subsystem.subsystem import InitPriority, Subsystem

logger = log_config.get_logger(__name__)


class KafkaNotificationSubsystem(Subsystem):
    """Subsystem responsible for forwarding Kafka notifications to Telegram chats."""

    @inject
    def __init__(self, bot: Bot, messaging_service: KafkaMessagingService) -> None:
        self._bot = bot
        self._messaging_service = messaging_service
        self._subsystem_manager = None
        self._default_chat_id: Optional[str] = CHAT_ID
        self._callback_registered = False

    async def initialize(self, subsystem_manager) -> None:
        logger.info("Initializing Kafka notification subsystem")
        self._subsystem_manager = subsystem_manager
        await self._messaging_service.start()
        if not self._callback_registered:
            self._messaging_service.register_notification_handler(self._handle_notification)
            self._callback_registered = True
        self.is_initialized = True
        logger.info("Kafka notification subsystem initialized")

    async def shutdown(self) -> None:
        logger.info("Shutting down Kafka notification subsystem")
        if self._callback_registered:
            self._messaging_service.unregister_notification_handler(self._handle_notification)
            self._callback_registered = False
        await self._messaging_service.stop()
        self.is_initialized = False

    def get_priority(self) -> InitPriority:
        return InitPriority.DATA_PROCESSING

    async def _handle_notification(self, notification: NotificationMessage) -> None:
        logger.info(
            "Forwarding notification to Telegram (level=%s, source=%s)",
            notification.level,
            notification.source,
        )
        message = self._format_notification(notification)
        if self._default_chat_id:
            try:
                await self._bot.send_message(chat_id=self._default_chat_id, text=message)
            except Exception as exc:  # pragma: no cover - network errors are best-effort logged
                logger.exception("Failed to send notification to chat %s: %s", self._default_chat_id, exc)
        else:
            logger.warning("CHAT_ID is not configured; logging notification only: %s", message)

    @staticmethod
    def _format_notification(notification: NotificationMessage) -> str:
        parts = ["🔔 Новое уведомление от торговой системы"]
        if notification.source:
            parts.append(f"Источник: {notification.source}")
        parts.append(f"Уровень: {notification.level}")
        if notification.correlation_id:
            parts.append(f"Correlation ID: {notification.correlation_id}")
        parts.append("Сообщение:")
        parts.append(notification.message)
        return "\n".join(parts)
