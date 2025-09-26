# Autonomous Coding Agent

This package provides a lightweight autonomous coding agent that mimics key Cursor-like features while staying entirely local. The agent is designed to:

- run a local LLM for reasoning and tool orchestration;
- plan tasks automatically and work towards goals in an iterative manner;
- interact with the filesystem to inspect, create and modify code files;
- communicate with Model Context Protocol (MCP) servers to extend its toolset;
- be launched from the command line or through Docker Compose together with the local LLM runtime.

## Features

- **Planning-first workflow** – every task is decomposed into actionable steps before execution.
- **Tool-aware reasoning** – the agent keeps a catalog of tools (filesystem, search, patch) and reasons about which tool to execute next.
- **MCP integration** – the agent can connect to one or more MCP servers that expose extra tools over JSON-RPC.
- **Configurable runtime** – behaviour is defined via a `config.toml` file or environment variables.
- **Docker-first setup** – a Dockerfile and `docker-compose.agent.yml` help spin up both the LLM runtime (`ollama`) and the agent service.

## Quick start

1. **Prepare configuration**

   Copy the sample configuration and adjust paths or models as needed:

   ```bash
   cp config.sample.toml config.toml
   ```

2. **Start with Docker Compose**

   ```bash
   docker compose -f docker-compose.agent.yml up --build
   ```

   The compose file launches two services:

   - `llm`: an [`ollama`](https://github.com/ollama/ollama) instance serving OpenAI compatible endpoints;
   - `agent`: the autonomous agent container which mounts your workspace and talks to the LLM.

3. **Run from the host**

   ```bash
   poetry run autonomous-agent --task "Add unit tests for the config loader"
   ```

   or, without Poetry:

   ```bash
   python -m autonomous_agent.cli --task "Describe repository"
   ```

## Configuration

Create a `config.toml` (or rely on `config.sample.toml`). Key sections:

```toml
[llm]
base_url = "http://llm:11434/v1"
model = "llama3.1:8b-instruct"
request_timeout = 120

[agent]
workspace = "."
auto_plan = true
max_iterations = 12

[mcp]
enabled = true
servers = [
  { name = "filesystem", command = "python", args = ["-m", "autonomous_agent.mcp.servers.filesystem"], cwd = "." }
]
```

Environment variables such as `AGENT_MODEL`, `AGENT_BASE_URL`, `AGENT_WORKSPACE` override config values.

## MCP support

The Model Context Protocol allows the agent to discover external tools. Each server is started as a subprocess using the provided command. The agent initialises servers using JSON-RPC (`initialize`, `listTools`) and exposes them as built-in tools.

A tiny reference server is included (`autonomous_agent.mcp.servers.filesystem`) which grants read-only access to files under the workspace root. You can add your own servers by implementing the JSON-RPC contract described in `autonomous_agent/mcp/README.md`.

## Development

- `tests/` contains a minimal unit-test suite that exercises the config loader, planner and agent loop via stubbed LLM responses.
- Run tests with:

  ```bash
  python -m pytest
  ```

- Formatting follows the default `black` style (120 char width) although no formatter is bundled.

## Roadmap

- Add real diff-based editing tools (currently the agent overwrites files when writing).
- Support multi-agent collaboration through MCP.
- Integrate vector search for repository-scale recall.

