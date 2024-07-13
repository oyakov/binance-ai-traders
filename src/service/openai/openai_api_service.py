# Open AI libs
from openai import OpenAI, APIConnectionError

from oam import log_config
from oam.environment import OPENAI_TOKEN, OPENAI_URL, LLM_MODEL

logger = log_config.get_logger(__name__)


class OpenAIAPIService:

    def __init__(self):
        # Point to the local server
        try:
            self.client = OpenAI(base_url=OPENAI_URL, api_key=OPENAI_TOKEN)
        except() as exception:
            logger.error(f"Failed to initialize OpenAI module, AI functions will be unavailable. Error {exception}")

        self.personas = {
            "assistant": {
                "system_prompt": [
                    {"role": "system",
                     "content": "You are an intelligent assistant. You always provide well-reasoned answers that are "
                                "both correct and helpful."},
                    {"role": "user",
                     "content": "Hello, introduce yourself to someone opening this program for the first time. "
                                "Be concise."},
                ]
            },
            "moderator": {
                "system_prompt": [
                    {"role": "system",
                     "content": "You are a moderator. You are responsible for ensuring that the conversation remains "
                                "civil and respectful."},
                    {"role": "user",
                     "content": "Classify the content of the following message as appropriate or inappropriate:"},
                ]
            },
        }

    async def get_completion(self, history: list = None) -> list:
        """Add a reply of OpenAI assistant to the end of the provided message history"""
        if history is None: history = self.personas["assistant"]["system_prompt"].copy()
        try:
            completion = self.client.chat.completions.create(
                model=LLM_MODEL,
                messages=history,
                temperature=0.7,
                stream=True,
            )
        except APIConnectionError as conn_exception:
            logger.error(f"Failed to connect to OpenAI API: {conn_exception}")
            return history

        new_message = {"role": self.role, "content": ""}

        for chunk in completion:
            if chunk.choices[0].delta.content:
                print(chunk.choices[0].delta.content, end="", flush=True)
                new_message["content"] += chunk.choices[0].delta.content

        logger.info("New message generation complete")
        history.append(new_message)
        return history
