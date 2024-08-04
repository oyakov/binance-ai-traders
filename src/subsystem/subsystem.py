from abc import ABC
from enum import Enum

from routers.base_router import BaseRouter


class InitPriority(Enum):
    CRITICAL = "CRITICAL"
    DATA_SOURCE = "DATA_SOURCE"
    DATA_OFFLOAD = "DATA_OFFLOAD"
    DATA_PROCESSING = "DATA_PROCESSING"
    DATA_CONSUMPTION = "DATA_CONSUMPTION"


class Subsystem(ABC):
    is_initialized: bool = False

    async def initialize(self, subsystem_manager):
        raise NotImplementedError("Subclasses must override this method")

    async def shutdown(self):
        raise NotImplementedError("Subclasses must override this method")

    def get_router(self) -> BaseRouter | None:
        """
        Get the Telegram aiogram router associated with this subsystem
        if any
        """
        return None

    def get_priority(self) -> InitPriority:
        """
        Get the priority of the subsystem
        """
        return self.InitPriority.CRITICAL
