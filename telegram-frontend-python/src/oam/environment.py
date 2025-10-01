import os
import importlib.util
import importlib


def _load_dotenv() -> None:
    """Load environment variables from a ``.env`` file when python-dotenv is available."""

    dotenv_spec = importlib.util.find_spec("dotenv")
    if dotenv_spec is None:
        return

    module = importlib.import_module("dotenv")
    load = getattr(module, "load_dotenv", None)
    if callable(load):
        load()


_load_dotenv()

############################################################################
# Access the variables
MASTER_BOT_TOKEN = os.getenv('MASTER_BOT_TOKEN')
LOGGING_CONFIG_PATH = os.getenv('LOGGING_CONFIG_PATH')
DATABASE_URL = os.getenv('DATABASE_URL')
DB_CONNECTION_POOL_MIN_SIZE = os.getenv('DB_CONNECTION_POOL_MIN_SIZE')
DB_CONNECTION_POOL_MAX_SIZE = os.getenv('DB_CONNECTION_POOL_MAX_SIZE')
DB_SQLACHEMY_LOGGING_ENABLED = os.getenv('DB_SQLACHEMY_LOGGING_ENABLED')
CHAT_ID = os.getenv('CHAT_ID')
COROUTINE_DEBUG = os.getenv('COROUTINE_DEBUG')
OPENAI_URL = os.getenv('OPENAI_URL')
OPENAI_TOKEN = os.getenv('OPENAI_TOKEN')
LLM_MODEL = os.getenv('LLM_MODEL')
BINANCE_TOKEN = os.getenv('BINANCE_TOKEN')
BINANCE_SECRET_TOKEN = os.getenv('BINANCE_SECRET_TOKEN')
BINANCE_TESTNET_TOKEN = os.getenv('BINANCE_TESTNET_TOKEN')
BINANCE_TESTNET_SECRET_TOKEN = os.getenv('BINANCE_TESTNET_SECRET_TOKEN')
BINANCE_TESTNET_ENABLED = os.getenv('BINANCE_TESTNET_ENABLED')
ELASTIC_HOSTNAME = os.getenv('ELASTIC_HOSTNAME')
ELASTIC_PORT = os.getenv('ELASTIC_PORT')
ELASTIC_SCHEME = os.getenv('ELASTIC_SCHEME')
ELASTIC_USERNAME = os.getenv('ELASTIC_USERNAME')
ELASTIC_PASSWORD = os.getenv('ELASTIC_PASSWORD')
KAFKA_BOOTSTRAP_SERVERS = os.getenv('KAFKA_BOOTSTRAP_SERVERS', 'kafka:9092')
KAFKA_COMMAND_TOPIC = os.getenv('KAFKA_COMMAND_TOPIC', 'trading-command')
KAFKA_STATUS_TOPIC = os.getenv('KAFKA_STATUS_TOPIC', 'trading-status')
KAFKA_NOTIFICATION_TOPIC = os.getenv('KAFKA_NOTIFICATION_TOPIC', 'trading-notification')
KAFKA_CONSUMER_GROUP = os.getenv('KAFKA_CONSUMER_GROUP', 'telegram-frontend')
KAFKA_CLIENT_ID = os.getenv('KAFKA_CLIENT_ID', 'telegram-frontend-bot')
############################################################################

DELIMITER: str = '🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊'
APP_NAME: str = 'Multi-Channel Telegram Bot'
