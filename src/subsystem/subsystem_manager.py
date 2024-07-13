# TODO: implement the subsystem manager that will allow the modular stucture to work
import asyncio
from abc import ABC

from subsystem.subsystem import Subsystem


class SubsystemManager(ABC):
    def __init__(self):
        self.subsystems = None

    async def initialize_subsystems(self, subsystems: list[Subsystem]):
        await asyncio.gather(*(subsys.initialize() for subsys in subsystems))
        if self.subsystems is None:
            self.subsystems = subsystems
        else:
            self.subsystems.extend(subsystems)

    async def shutdown_subsystems(self, subsystems: list[Subsystem] = None):
        await asyncio.gather(*(subsys.shutdown() for subsys in subsystems))
        self.subsystems = []

    async def restart_failed_subsystems(self):
        await asyncio.gather(*(subsys.initialize() for subsys in self.subsystems if not subsys.is_initialized))


subsystem_manager: SubsystemManager = SubsystemManager()
