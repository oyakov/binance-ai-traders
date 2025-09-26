"""Configuration handling for the autonomous agent."""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional
import os
import tomllib


@dataclass(slots=True)
class LLMConfig:
    base_url: str = "http://localhost:11434/v1"
    model: str = "llama3"
    request_timeout: int = 120
    api_key: Optional[str] = None


@dataclass(slots=True)
class AgentConfig:
    workspace: Path = Path('.')
    auto_plan: bool = True
    max_iterations: int = 12
    reflection: bool = True

    def resolve_workspace(self) -> Path:
        path = self.workspace.expanduser().resolve()
        path.mkdir(parents=True, exist_ok=True)
        return path


@dataclass(slots=True)
class MCPServerConfig:
    name: str
    command: str
    args: List[str] = field(default_factory=list)
    cwd: Optional[Path] = None
    env: Dict[str, str] = field(default_factory=dict)


@dataclass(slots=True)
class MCPConfig:
    enabled: bool = True
    servers: List[MCPServerConfig] = field(default_factory=list)


@dataclass(slots=True)
class RuntimeConfig:
    llm: LLMConfig
    agent: AgentConfig
    mcp: MCPConfig


def _load_toml(path: Path) -> Dict[str, Any]:
    if not path.exists():
        return {}
    with path.open('rb') as handle:
        return tomllib.load(handle)


def _get_bool(value: Any, default: bool) -> bool:
    if value is None:
        return default
    if isinstance(value, bool):
        return value
    if isinstance(value, (int, float)):
        return bool(value)
    if isinstance(value, str):
        lowered = value.strip().lower()
        if lowered in {"1", "true", "yes", "on"}:
            return True
        if lowered in {"0", "false", "no", "off"}:
            return False
    return default


def _load_mcp_servers(raw_servers: Iterable[Dict[str, Any]]) -> List[MCPServerConfig]:
    servers: List[MCPServerConfig] = []
    for raw in raw_servers:
        name = str(raw.get('name'))
        command = str(raw.get('command'))
        if not name or not command:
            continue
        args = [str(item) for item in raw.get('args', [])]
        cwd_value = raw.get('cwd')
        cwd = Path(cwd_value) if cwd_value else None
        env_raw = raw.get('env', {})
        env = {str(k): str(v) for k, v in env_raw.items()}
        servers.append(MCPServerConfig(name=name, command=command, args=args, cwd=cwd, env=env))
    return servers


def load_config(path: Optional[Path | str] = None) -> RuntimeConfig:
    """Load configuration from TOML and environment variables."""

    candidate_paths = []
    if path:
        candidate_paths.append(Path(path))
    else:
        candidate_paths.append(Path('config.toml'))
        candidate_paths.append(Path('autonomous-agent/config.sample.toml'))

    data: Dict[str, Any] = {}
    for candidate in candidate_paths:
        if candidate.exists():
            data = _load_toml(candidate)
            break

    llm_data = data.get('llm', {}) if isinstance(data.get('llm'), dict) else {}
    agent_data = data.get('agent', {}) if isinstance(data.get('agent'), dict) else {}
    mcp_data = data.get('mcp', {}) if isinstance(data.get('mcp'), dict) else {}

    llm = LLMConfig(
        base_url=str(llm_data.get('base_url', LLMConfig.base_url)),
        model=str(llm_data.get('model', LLMConfig.model)),
        request_timeout=int(llm_data.get('request_timeout', LLMConfig.request_timeout)),
        api_key=llm_data.get('api_key') or None,
    )

    workspace_value = agent_data.get('workspace', AgentConfig.workspace)
    agent = AgentConfig(
        workspace=Path(workspace_value) if workspace_value else AgentConfig.workspace,
        auto_plan=_get_bool(agent_data.get('auto_plan'), AgentConfig.auto_plan),
        max_iterations=int(agent_data.get('max_iterations', AgentConfig.max_iterations)),
        reflection=_get_bool(agent_data.get('reflection'), AgentConfig.reflection),
    )

    mcp = MCPConfig(
        enabled=_get_bool(mcp_data.get('enabled'), MCPConfig.enabled),
        servers=_load_mcp_servers(mcp_data.get('servers', [])),
    )

    # Environment overrides
    llm.base_url = os.getenv('AGENT_BASE_URL', llm.base_url)
    llm.model = os.getenv('AGENT_MODEL', llm.model)
    if os.getenv('AGENT_REQUEST_TIMEOUT'):
        try:
            llm.request_timeout = int(os.getenv('AGENT_REQUEST_TIMEOUT', llm.request_timeout))
        except ValueError:
            pass
    llm.api_key = os.getenv('AGENT_API_KEY', llm.api_key)

    if os.getenv('AGENT_WORKSPACE'):
        agent.workspace = Path(os.getenv('AGENT_WORKSPACE'))
    if os.getenv('AGENT_AUTO_PLAN'):
        agent.auto_plan = _get_bool(os.getenv('AGENT_AUTO_PLAN'), agent.auto_plan)
    if os.getenv('AGENT_MAX_ITERATIONS'):
        try:
            agent.max_iterations = int(os.getenv('AGENT_MAX_ITERATIONS', agent.max_iterations))
        except ValueError:
            pass
    if os.getenv('AGENT_REFLECTION'):
        agent.reflection = _get_bool(os.getenv('AGENT_REFLECTION'), agent.reflection)

    if os.getenv('AGENT_MCP_ENABLED'):
        mcp.enabled = _get_bool(os.getenv('AGENT_MCP_ENABLED'), mcp.enabled)

    return RuntimeConfig(llm=llm, agent=agent, mcp=mcp)


__all__ = [
    'LLMConfig',
    'AgentConfig',
    'MCPConfig',
    'MCPServerConfig',
    'RuntimeConfig',
    'load_config',
]
