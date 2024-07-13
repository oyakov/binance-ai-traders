from oam import log_config
from schedule.periodic_message_scheduler import initialize_message_sender_job
from subsystem.subsystem import Subsystem

logger = log_config.get_logger(__name__)

q
class SchedulerSubsystem(Subsystem):
    def __init__(self, bot, interval_minutes, new_message_router):
        self.bot = bot
        self.interval_minutes = interval_minutes
        self.new_message_router = new_message_router

    async def initialize(self):
        logger.info(f"Initializing Scheduler subsystem {self.bot}, {self.interval_minutes}")
        await initialize_message_sender_job(bot=self.bot, interval_minutes=self.interval_minutes)
        self.is_initialized = True

    async def shutdown(self):
        pass
