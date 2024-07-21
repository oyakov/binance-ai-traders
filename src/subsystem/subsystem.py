from abc import ABC

from routers.base_router import BaseRouter


class Subsystem(ABC):

    is_initialized: bool = False

    async def initialize(self, subsystem_manager):
        raise NotImplementedError("Subclasses must override this method")

    async def shutdown(self):
        raise NotImplementedError("Subclasses must override this method")

    async def get_router(self) -> BaseRouter | None:
        """
        Get the Telegram aiogram router associated with this subsystem
        if any
        """
        return None
