import os
import logging

# Open AI libs
from openai import OpenAI

from dotenv import load_dotenv

load_dotenv()

OPENAI_URL = os.getenv('OPENAI_URL')
OPENAI_TOKEN = os.getenv('OPENAI_TOKEN')
LLM_MODEL = os.getenv('LLM_MODEL')

logger = logging.getLogger(__name__)


class OpenAIAPIService:

    def __init__(self):
        # Point to the local server
        try:
            self.client = OpenAI(base_url=OPENAI_URL, api_key=OPENAI_TOKEN)
        except() as exception:
            logger.error(f"Failed to initialize OpenAI module, AI functions will be unavailable. Error {exception}")
        self.role = "assistant"
        self.system_prompt = [
            {"role": "system",
             "content": "You are an intelligent assistant. "
                        "You always provide well-reasoned answers that are both correct and helpful."},
            {"role": "user",
             "content": "Hello, introduce yourself to someone opening this program for the first time. Be concise."},
        ]

    async def get_completion(self, history: list = None) -> list:
        """Add a reply of OpenAI assistant to the end of the provided message history"""
        if history is None: history = self.system_prompt.copy()
        completion = self.client.chat.completions.create(
            model=LLM_MODEL,
            messages=history,
            temperature=0.7,
            stream=True,
        )

        new_message = {"role": self.role, "content": ""}

        for chunk in completion:
            if chunk.choices[0].delta.content:
                print(chunk.choices[0].delta.content, end="", flush=True)
                new_message["content"] += chunk.choices[0].delta.content

        logger.info("New message generation complete")
        history.append(new_message)
        return history
