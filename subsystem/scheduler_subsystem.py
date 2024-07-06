from schedule.periodic_message_scheduler import initialize_message_sender_job
from subsystem.subsystem import Subsystem


class SchedulerSubsystem(Subsystem):
    def __init__(self, bot, interval_minutes):
        self.bot = bot
        self.interval_minutes = interval_minutes

    async def initialize(self):
        await initialize_message_sender_job(bot=self.bot, interval_minutes=self.interval_minutes)