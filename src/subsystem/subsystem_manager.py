import asyncio
from abc import ABC
from collections import defaultdict
from typing import Mapping, Any

from injector import inject

from oam import log_config
from subsystem.subsystem import Subsystem, InitPriority

logger = log_config.get_logger(__name__)


class SubsystemManager(ABC):

    @inject
    def __init__(self):
        self.subsystems: list[Subsystem] | None = None

    async def initialize_subsystems(self, subsystems: list[Subsystem]):
        priority_dict = self.split_subsystems_by_priority(subsystems)
        for priority in InitPriority:
            logger.info(f"Initializing subsystems with priority {priority}")
            await asyncio.gather(*(subsys.initialize(self) for subsys in priority_dict[priority]))
        if self.subsystems is None:
            self.subsystems = subsystems
        else:
            self.subsystems.extend(subsystems)

    async def shutdown_subsystems(self, subsystems: list[Subsystem] = None):
        await asyncio.gather(*(subsys.shutdown() for subsys in subsystems))
        self.subsystems = []

    async def restart_failed_subsystems(self):
        await asyncio.gather(*(subsys.initialize(self) for subsys in self.subsystems if not subsys.is_initialized))

    async def get_subsystem(self, subsystem_name: str):
        for subsystem in self.subsystems:
            if subsystem.__class__.__name__ == subsystem_name:
                return subsystem
        return None

    def collect_health_data(self) -> Mapping[str, Any]:
        return {subsystem.__class__.__name__: subsystem.is_initialized for subsystem in self.subsystems}

    def split_subsystems_by_priority(self, subsystems: list[Subsystem]) -> dict[InitPriority, list[Subsystem]]:
        priority_dict = defaultdict(list)
        for subsystem in subsystems:
            priority = subsystem.get_priority()
            priority_dict[priority].append(subsystem)
        return priority_dict
