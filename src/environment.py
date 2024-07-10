import os

from dotenv import load_dotenv

load_dotenv()

############################################################################
# Access the variables
BOT_TOKEN = os.getenv('BOT_TOKEN')
LOGGING_CONFIG_PATH = os.getenv('LOGGING_CONFIG_PATH')
DATABASE_URL = os.getenv('DATABASE_URL')
DB_CONNECTION_POOL_MIN_SIZE = os.getenv('DB_CONNECTION_POOL_MIN_SIZE')
DB_CONNECTION_POOL_MAX_SIZE = os.getenv('DB_CONNECTION_POOL_MAX_SIZE')
CHAT_ID = os.getenv('CHAT_ID')
COROUTINE_DEBUG = os.getenv('COROUTINE_DEBUG')
OPENAI_URL = os.getenv('OPENAI_URL')
OPENAI_TOKEN = os.getenv('OPENAI_TOKEN')
LLM_MODEL = os.getenv('LLM_MODEL')
############################################################################

DELIMITER: str = '🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊'
APP_NAME: str = 'Multi-Channel Telegram Bot'
