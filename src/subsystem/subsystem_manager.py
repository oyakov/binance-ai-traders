# TODO: implement the subsystem manager that will allow the modular stucture to work
import asyncio
from abc import ABC
from typing import Mapping, Any

from injector import inject

from service.elastic.elastic_service import ElasticService
from subsystem.subsystem import Subsystem


class SubsystemManager(ABC):

    @inject
    def __init__(self, elastic_service: ElasticService):
        self.subsystems: list[Subsystem] | None = None

    async def initialize_subsystems(self, subsystems: list[Subsystem]):
        await asyncio.gather(*(subsys.initialize(self) for subsys in subsystems))
        if self.subsystems is None:
            self.subsystems = subsystems
        else:
            self.subsystems.extend(subsystems)

    async def shutdown_subsystems(self, subsystems: list[Subsystem] = None):
        await asyncio.gather(*(subsys.shutdown() for subsys in subsystems))
        self.subsystems = []

    async def restart_failed_subsystems(self):
        await asyncio.gather(*(subsys.initialize() for subsys in self.subsystems if not subsys.is_initialized))

    async def get_subsystem(self, subsystem_name: str):
        for subsystem in self.subsystems:
            if subsystem.__class__.__name__ == subsystem_name:
                return subsystem
        return None

    def collect_health_data(self) -> Mapping[str, Any]:
        return {subsystem.__class__.__name__: subsystem.is_initialized for subsystem in self.subsystems}
