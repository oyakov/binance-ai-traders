"""Core autonomous coding agent."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional

from .config import RuntimeConfig
from .llm_client import ChatMessage, LLMClient
from .mcp import MCPManager
from .planner import Plan, Planner
from .tools import ToolError, ToolRegistry, create_default_registry
from .utils import extract_json_blob


@dataclass(slots=True)
class AgentResult:
    task: str
    final_response: str
    plan: Optional[Plan]
    iterations: int
    tool_calls: List[Dict[str, str]]


class AutonomousCoderAgent:
    def __init__(
        self,
        runtime: RuntimeConfig,
        llm: Optional[LLMClient] = None,
        planner: Optional[Planner] = None,
        tool_registry: Optional[ToolRegistry] = None,
        system_prompt_path: Optional[Path] = None,
    ):
        self._runtime = runtime
        self._workspace = runtime.agent.resolve_workspace()
        self._llm = llm or LLMClient(runtime.llm)
        prompt_file = system_prompt_path or Path(__file__).parent / 'prompts' / 'system_agent.txt'
        self._system_prompt = Path(prompt_file).read_text(encoding='utf-8')
        planner_prompt = Path(__file__).parent / 'prompts' / 'system_planner.txt'
        self._planner = planner or Planner(self._llm, planner_prompt)
        self._tools = tool_registry or create_default_registry(self._workspace)
        self._mcp = MCPManager(runtime.mcp, self._tools)
        self._history: List[ChatMessage] = []

    @property
    def tools(self) -> ToolRegistry:
        return self._tools

    @property
    def llm(self) -> LLMClient:
        return self._llm

    def run(self, task: str) -> AgentResult:
        self._mcp.start()
        plan: Optional[Plan] = None
        if self._runtime.agent.auto_plan:
            plan = self._planner.make_plan(task, self._tools.names())

        plan_summary = plan.summary() if plan else 'Planning disabled.'
        tools_description = '\n'.join(
            f"- {tool['name']}: {tool['description']} | params: {tool['parameters']}"
            for tool in self._tools.describe()
        )
        system_prompt = (
            self._system_prompt
            + '\nAvailable tools:\n'
            + tools_description
            + '\nCurrent plan:\n'
            + plan_summary
        )
        self._history = [ChatMessage(role='system', content=system_prompt)]
        self._history.append(ChatMessage(role='user', content=f'Task: {task}'))

        iterations = 0
        tool_calls: List[Dict[str, str]] = []
        try:
            while iterations < self._runtime.agent.max_iterations:
                iterations += 1
                response = self._llm.chat(self._history, temperature=0.2)
                assistant_text = response.content
                self._history.append(ChatMessage(role='assistant', content=assistant_text))
                try:
                    data = extract_json_blob(assistant_text)
                except Exception as exc:  # pragma: no cover - depends on LLM
                    self._history.append(
                        ChatMessage(
                            role='user',
                            content=f'Invalid JSON detected: {exc}. Please respond with valid JSON per instructions.',
                        )
                    )
                    continue

                if isinstance(data, dict) and 'final' in data:
                    final_response = str(data.get('final'))
                    return AgentResult(
                        task=task,
                        final_response=final_response,
                        plan=plan,
                        iterations=iterations,
                        tool_calls=tool_calls,
                    )

                if isinstance(data, dict) and 'action' in data:
                    action = data['action'] or {}
                    tool_name = action.get('tool')
                    tool_input = action.get('input') or {}
                    if not tool_name:
                        self._history.append(
                            ChatMessage(
                                role='user',
                                content='Tool name missing in action. Provide a valid tool call.',
                            )
                        )
                        continue
                    try:
                        result = self._tools.execute(tool_name, **tool_input)
                        tool_calls.append({'tool': tool_name, 'input': str(tool_input), 'output': result})
                        self._history.append(ChatMessage(role='tool', content=f'{tool_name}: {result}'))
                    except ToolError as exc:
                        tool_calls.append({'tool': tool_name, 'input': str(tool_input), 'output': f'ERROR: {exc}'})
                        self._history.append(ChatMessage(role='tool', content=f'{tool_name}: ERROR: {exc}'))
                        self._history.append(
                            ChatMessage(
                                role='user',
                                content='The previous tool call failed. Adjust your plan and try a different approach.',
                            )
                        )
                    continue

                self._history.append(
                    ChatMessage(
                        role='user',
                        content='Your response must include either an action or a final answer. Please try again.',
                    )
                )

            return AgentResult(
                task=task,
                final_response='Max iterations reached without final answer.',
                plan=plan,
                iterations=iterations,
                tool_calls=tool_calls,
            )
        finally:
            self._mcp.shutdown()


__all__ = ['AutonomousCoderAgent', 'AgentResult']
