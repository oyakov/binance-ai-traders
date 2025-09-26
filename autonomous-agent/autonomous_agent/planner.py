"""Planning helper for the autonomous coding agent."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List

from .llm_client import ChatMessage, LLMClient
from .utils import extract_json_blob


@dataclass(slots=True)
class PlanStep:
    number: int
    description: str


@dataclass(slots=True)
class Plan:
    original_task: str
    steps: List[PlanStep]

    def summary(self) -> str:
        joined = '\n'.join(f"{step.number}. {step.description}" for step in self.steps)
        return f"Plan for: {self.original_task}\n{joined}" if joined else f"No plan generated for: {self.original_task}"


class Planner:
    def __init__(self, llm: LLMClient, prompt_path: Path):
        self._llm = llm
        self._prompt = prompt_path.read_text(encoding='utf-8')

    def make_plan(self, task: str, tools: Iterable[str], max_steps: int = 8) -> Plan:
        messages = [
            ChatMessage(role='system', content=self._prompt.format(max_steps=max_steps)),
            ChatMessage(
                role='user',
                content=(
                    "You must create a plan for the following task as a JSON object.\n"
                    f"Task: {task}\n"
                    f"Available tools: {', '.join(tools)}"
                ),
            ),
        ]
        response = self._llm.chat(messages, temperature=0.1)
        data = extract_json_blob(response.content)
        raw_steps = data.get('plan') if isinstance(data, dict) else []
        steps: List[PlanStep] = []
        for index, item in enumerate(raw_steps or [], start=1):
            if isinstance(item, dict):
                description = item.get('description') or item.get('summary') or str(item)
            else:
                description = str(item)
            steps.append(PlanStep(number=index, description=description.strip()))
        return Plan(original_task=task, steps=steps)


__all__ = ['Planner', 'Plan', 'PlanStep']
