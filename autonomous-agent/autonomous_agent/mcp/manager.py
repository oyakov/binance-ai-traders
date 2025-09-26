"""MCP server integration utilities."""

from __future__ import annotations

import json
import os
import queue
import subprocess
import threading
import uuid
from dataclasses import dataclass
from typing import Any, Dict, List, Optional

from ..config import MCPConfig, MCPServerConfig
from ..tools import Tool, ToolContext, ToolError, ToolRegistry


class MCPConnectionError(RuntimeError):
    pass


class MCPClient:
    def __init__(self, config: MCPServerConfig, workspace: str):
        self._config = config
        env = os.environ.copy()
        env.setdefault('AGENT_WORKSPACE', workspace)
        env.update(config.env or {})
        args = [config.command, *config.args]
        try:
            self._process = subprocess.Popen(
                args,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                cwd=config.cwd,
                env=env,
                text=True,
                bufsize=1,
            )
        except OSError as exc:  # pragma: no cover - depends on env
            raise MCPConnectionError(f'Failed to start MCP server {config.name}: {exc}') from exc

        if not self._process.stdin or not self._process.stdout:
            raise MCPConnectionError('MCP server pipes not available')

        self._stdin = self._process.stdin
        self._stdout = self._process.stdout
        self._responses: "queue.Queue[Dict[str, Any]]" = queue.Queue()
        self._listener = threading.Thread(target=self._listen_loop, daemon=True)
        self._listener.start()

    def _listen_loop(self) -> None:
        while True:
            line = self._stdout.readline()
            if not line:
                break
            try:
                decoded = json.loads(line)
            except json.JSONDecodeError:
                continue
            if isinstance(decoded, dict):
                self._responses.put(decoded)

    def _request(self, method: str, params: Optional[Dict[str, Any]] = None, timeout: float = 10.0) -> Any:
        message_id = str(uuid.uuid4())
        payload = {
            'jsonrpc': '2.0',
            'id': message_id,
            'method': method,
            'params': params or {},
        }
        body = json.dumps(payload)
        self._stdin.write(body + '\n')
        self._stdin.flush()
        while True:
            try:
                response = self._responses.get(timeout=timeout)
            except queue.Empty as exc:
                raise MCPConnectionError(f'MCP server timed out waiting for {method}') from exc
            if response.get('id') == message_id:
                if 'error' in response:
                    raise MCPConnectionError(str(response['error']))
                return response.get('result')

    def initialize(self) -> Any:
        return self._request('initialize', {'client': 'autonomous-agent'})

    def list_tools(self) -> List[Dict[str, Any]]:
        result = self._request('listTools')
        tools = result.get('tools') if isinstance(result, dict) else None
        return tools or []

    def call_tool(self, name: str, arguments: Dict[str, Any]) -> Any:
        return self._request('callTool', {'name': name, 'arguments': arguments})

    def close(self) -> None:
        try:
            self._request('shutdown', {})
        except MCPConnectionError:
            pass
        if self._process.poll() is None:
            self._process.terminate()


class RemoteTool(Tool):
    def __init__(self, context: ToolContext, client: MCPClient, descriptor: Dict[str, Any]):
        super().__init__(context)
        self._client = client
        self.name = descriptor.get('name', 'remote_tool')
        self.description = descriptor.get('description', f'Remote tool from {client._config.name}')
        parameters = descriptor.get('parameters', {})
        try:
            self.parameters = json.dumps(parameters)
        except TypeError:
            self.parameters = str(parameters)

    def __call__(self, **kwargs) -> str:
        result = self._client.call_tool(self.name, kwargs)
        if isinstance(result, dict) and 'result' in result:
            payload = result['result']
        else:
            payload = result
        if isinstance(payload, str):
            return payload
        return json.dumps(payload, ensure_ascii=False)


@dataclass(slots=True)
class MCPServerHandle:
    config: MCPServerConfig
    client: MCPClient


class MCPManager:
    def __init__(self, mcp_config: MCPConfig, registry: ToolRegistry):
        self._config = mcp_config
        self._registry = registry
        self._servers: List[MCPServerHandle] = []

    def start(self) -> None:
        if not self._config.enabled:
            return
        workspace = str(self._registry._context.workspace)
        for server_cfg in self._config.servers:
            client = MCPClient(server_cfg, workspace)
            client.initialize()
            tools = client.list_tools()
            handle = MCPServerHandle(config=server_cfg, client=client)
            self._servers.append(handle)
            for tool in tools:
                remote = RemoteTool(self._registry._context, client, tool)
                self._registry.register(remote)

    def shutdown(self) -> None:
        for handle in self._servers:
            handle.client.close()
        self._servers.clear()


__all__ = ['MCPManager', 'MCPConnectionError']
