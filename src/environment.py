import os

from dotenv import load_dotenv

load_dotenv()

############################################################################
# Access the variables
BOT_TOKEN = os.getenv('BOT_TOKEN')
DATABASE_URL = os.getenv('DATABASE_URL')
CHAT_ID = os.getenv('CHAT_ID')
COROUTINE_DEBUG = os.getenv('COROUTINE_DEBUG')
OPENAI_URL = os.getenv('OPENAI_URL')
OPENAI_TOKEN = os.getenv('OPENAI_TOKEN')
LLM_MODEL = os.getenv('LLM_MODEL')
############################################################################

delimiter: str = '🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊'

