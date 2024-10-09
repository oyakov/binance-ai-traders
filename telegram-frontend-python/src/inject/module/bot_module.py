from aiogram import Bot
from injector import Module, singleton, provider

from oam.environment import MASTER_BOT_TOKEN


class BotModule(Module):
    @singleton
    @provider
    def provide_bot(self) -> Bot:
        return Bot(token=MASTER_BOT_TOKEN)
