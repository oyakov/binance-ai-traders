from __future__ import annotations

from autonomous_agent.config import load_config


def test_load_config_with_env_overrides(tmp_path, monkeypatch):
    config_path = tmp_path / 'config.toml'
    config_path.write_text(
        """
[llm]
base_url = "http://example.com"
model = "base"
request_timeout = 30

[agent]
workspace = "{workspace}"
auto_plan = false
max_iterations = 5

[mcp]
enabled = false
""".format(workspace=tmp_path / 'ws')
    )

    monkeypatch.setenv('AGENT_MODEL', 'override-model')
    monkeypatch.setenv('AGENT_MAX_ITERATIONS', '9')

    runtime = load_config(config_path)
    assert runtime.llm.model == 'override-model'
    assert runtime.agent.max_iterations == 9
    assert runtime.agent.auto_plan is False
    assert runtime.mcp.enabled is False
