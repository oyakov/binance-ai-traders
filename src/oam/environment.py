import os

from dotenv import load_dotenv

load_dotenv()

############################################################################
# Access the variables
MASTER_BOT_TOKEN = os.getenv('MASTER_BOT_TOKEN')
LOGGING_CONFIG_PATH = os.getenv('LOGGING_CONFIG_PATH')
DATABASE_URL = os.getenv('DATABASE_URL')
DB_CONNECTION_POOL_MIN_SIZE = os.getenv('DB_CONNECTION_POOL_MIN_SIZE')
DB_CONNECTION_POOL_MAX_SIZE = os.getenv('DB_CONNECTION_POOL_MAX_SIZE')
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
############################################################################

DELIMITER: str = '🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊'
APP_NAME: str = 'Multi-Channel Telegram Bot'
