from abc import ABC


class Subsystem(ABC):

    is_initialized: bool = False

    async def initialize(self):
        raise NotImplementedError("Subclasses must override this method")

    async def shutdown(self):
        raise NotImplementedError("Subclasses must override this method")
