from oam import log_config
from service.crypto.binance.binance_service import BinanceService
from subsystem.subsystem import Subsystem

logger = log_config.get_logger(__name__)


class BinanceSubsystem(Subsystem):
    def __init__(self, bot, router):
        self.bot = bot
        self.router = router
        self.binance_service = None

    async def initialize(self):
        logger.info(f"Initializing Binance subsystem {self.bot}")
        try:
            self.binance_service = BinanceService()
        except Exception as e:
            print(f"Error initializing BinanceService: {e}")
            raise e
        self.is_initialized = True
        logger.info(f"Binance subsystem is initialized")

    async def shutdown(self):
        logger.info(f"Shutting down Binance subsystem")

    def get_binance_service(self):
        return self.binance_service

    def get_router(self):
        return self.router
