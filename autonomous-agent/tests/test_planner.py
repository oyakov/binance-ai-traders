from __future__ import annotations

from pathlib import Path

from autonomous_agent.llm_client import ChatResponse
from autonomous_agent.planner import Planner


class StubLLM:
    def __init__(self, response: str):
        self._response = response

    def chat(self, messages, temperature=0.0):
        return ChatResponse(content=self._response, raw={}, latency=0.01)


def test_planner_parses_plan(tmp_path):
    prompt_path = tmp_path / 'prompt.txt'
    prompt_path.write_text('prompt {max_steps}')
    llm = StubLLM('{"plan": [{"description": "Step one"}, {"description": "Step two"}]}')
    planner = Planner(llm, prompt_path)
    plan = planner.make_plan('Do stuff', ['read_file'])
    assert [step.description for step in plan.steps] == ['Step one', 'Step two']
