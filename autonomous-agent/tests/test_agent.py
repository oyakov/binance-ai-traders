from __future__ import annotations

from autonomous_agent.agent import AutonomousCoderAgent
from autonomous_agent.config import AgentConfig, LLMConfig, MCPConfig, RuntimeConfig
from autonomous_agent.llm_client import ChatResponse


class StubLLM:
    def __init__(self, responses):
        self._responses = list(responses)

    def chat(self, messages, temperature=0.0):
        if not self._responses:
            raise AssertionError('No more stub responses')
        content = self._responses.pop(0)
        return ChatResponse(content=content, raw={}, latency=0.01)


def test_agent_executes_tool(tmp_path):
    runtime = RuntimeConfig(
        llm=LLMConfig(base_url='http://localhost', model='test'),
        agent=AgentConfig(workspace=tmp_path, auto_plan=False, max_iterations=3),
        mcp=MCPConfig(enabled=False, servers=[]),
    )
    tmp_path.mkdir(exist_ok=True)
    stub_llm = StubLLM([
        '{"thought": "Check directory", "action": {"tool": "list_directory", "input": {"path": "."}}}',
        '{"thought": "Done", "final": "Listed directory"}'
    ])
    agent = AutonomousCoderAgent(runtime, llm=stub_llm)
    result = agent.run('List project files')
    assert result.final_response == 'Listed directory'
    assert any(call['tool'] == 'list_directory' for call in result.tool_calls)
