# bot_manager.py
import asyncio
from sqlalchemy.orm import sessionmaker
from sub_bot import SubBot
from db_config import engine, CustomerConfiguration


class BotManager:
    def __init__(self):
        self.sub_bots = []
        self.tasks = []
        self.Session = sessionmaker(bind=engine)

    async def create_sub_bot(self, customer_id, api_key, subsystems):
        sub_bot = SubBot(api_key, subsystems)
        await sub_bot.initialize()
        self.sub_bots.append(sub_bot)

        # Update the database with the status of the sub_bot
        self.update_sub_bot_status(customer_id, sub_bot)

    def update_sub_bot_status(self, customer_id, sub_bot):
        session = self.Session()
        try:
            config = session.query(CustomerConfiguration).filter_by(customer_id=customer_id).first()
            if config:
                config.status = 'running'  # Update with actual status
                session.commit()
        except Exception as e:
            print(f"Failed to update DB for customer {customer_id}: {e}")
        finally:
            session.close()

    async def initialize_sub_bots(self, customer_configs):
        for config in customer_configs:
            task = asyncio.create_task(self.create_sub_bot(config.customer_id, config.api_key, config.subsystems))
            self.tasks.append(task)

    async def shutdown(self):
        for task in self.tasks:
            task.cancel()
        await asyncio.gather(*self.tasks, return_exceptions=True)

        for sub_bot in self.sub_bots:
            await sub_bot.shutdown()
