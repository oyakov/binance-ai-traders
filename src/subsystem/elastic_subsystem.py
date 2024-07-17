from oam import log_config
from service.elastic.elastic_service import ElasticService
from subsystem.subsystem import Subsystem

logger = log_config.get_logger(__name__)


class ElasticSubsystem(Subsystem):

    def __init__(self, bot, router):
        self.bot = bot
        self.router = router
        self.elastic_service: ElasticService | None = None

    async def initialize(self):
        logger.info(f"Initializing the Elastic")
        try:
            self.elastic_service = ElasticService()
            self.is_initialized = True
            logger.info(f"Elastic is initialized")
        except OSError as exception:
            logger.error(f"Error connecting to the Elastic: {exception}")
        except Exception as exception:
            logger.error(f"Error creating Elastic: {exception}")

    async def shutdown(self):
        pass
