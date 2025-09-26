# MCP integration

The agent can talk to Model Context Protocol servers using a lightweight JSON-RPC implementation. Each server is started as a subprocess and must implement the following methods:

- `initialize(params)` – returns metadata about the server. The agent sends `{ "client": "autonomous-agent" }` as params.
- `listTools()` – returns `{ "tools": [ { "name": "...", "description": "...", "parameters": {...} } ] }`.
- `callTool({"name": "tool_name", "arguments": {...}})` – executes a tool and returns the result payload.
- `shutdown()` – optional, called during graceful shutdown.

Tools published through MCP become regular agent tools and can be invoked by the LLM. See `servers/filesystem.py` for an example server.
