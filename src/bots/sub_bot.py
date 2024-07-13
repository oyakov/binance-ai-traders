# sub_bot.py
import asyncio
from subsystems.periodic_messages import PeriodicMessages
from subsystems.ai_assistant import AIAssistant
from subsystems.binance_api import BinanceAPI
from additional_jobs import job1, job2


class SubBot:
    def __init__(self, api_key, subsystems):
        self.api_key = api_key
        self.subsystems = subsystems
        self.enabled_subsystems = []
        self.tasks = []

    async def initialize(self):
        if 'periodic_messages' in self.subsystems:
            if await self.init_periodic_messages():
                self.enabled_subsystems.append('periodic_messages')
        if 'ai_assistant' in self.subsystems:
            if await self.init_ai_assistant():
                self.enabled_subsystems.append('ai_assistant')
        if 'binance_api' in self.subsystems:
            if await self.init_binance_api():
                self.enabled_subsystems.append('binance_api')

        # Start additional jobs
        self.start_additional_jobs()

    async def init_periodic_messages(self):
        try:
            self.periodic_messages = PeriodicMessages(self.api_key)
            await self.periodic_messages.start()
            return True
        except Exception as e:
            print(f"Failed to initialize PeriodicMessages: {e}")
            return False

    async def init_ai_assistant(self):
        try:
            self.ai_assistant = AIAssistant(self.api_key)
            await self.ai_assistant.start()
            return True
        except Exception as e:
            print(f"Failed to initialize AIAssistant: {e}")
            return False

    async def init_binance_api(self):
        try:
            self.binance_api = BinanceAPI(self.api_key)
            await self.binance_api.start()
            return True
        except Exception as e:
            print(f"Failed to initialize BinanceAPI: {e}")
            return False

    def start_additional_jobs(self):
        self.tasks.append(asyncio.create_task(job1()))
        self.tasks.append(asyncio.create_task(job2()))

    async def shutdown(self):
        for task in self.tasks:
            task.cancel()
        await asyncio.gather(*self.tasks, return_exceptions=True)
