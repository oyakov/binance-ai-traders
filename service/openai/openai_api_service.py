import os

# Open AI libs
from openai import OpenAI

from dotenv import load_dotenv

load_dotenv()

API_TOKEN = os.getenv('BOT_TOKEN')
CHAT_ID = os.getenv('CHAT_ID')

# Point to the local server
client = OpenAI(base_url="http://localhost:1234/v1", api_key="lm-studio")
