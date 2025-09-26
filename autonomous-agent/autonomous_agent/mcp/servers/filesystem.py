"""Reference MCP server exposing read-only filesystem tools."""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path
from typing import Any, Dict

WORKSPACE = Path(os.getenv('AGENT_WORKSPACE', '.')).resolve()


def within_workspace(path: Path) -> bool:
    try:
        return str(path.resolve()).startswith(str(WORKSPACE))
    except OSError:
        return False


def read_file(arguments: Dict[str, Any]) -> Dict[str, Any]:
    path = WORKSPACE / arguments.get('path', '')
    path = path.resolve()
    if not within_workspace(path):
        raise ValueError('Path outside workspace')
    if not path.exists():
        raise FileNotFoundError(str(path))
    return {'result': path.read_text(encoding='utf-8', errors='replace')}


def list_directory(arguments: Dict[str, Any]) -> Dict[str, Any]:
    path = WORKSPACE / arguments.get('path', '.')
    path = path.resolve()
    if not within_workspace(path):
        raise ValueError('Path outside workspace')
    if not path.exists() or not path.is_dir():
        raise FileNotFoundError(str(path))
    entries = []
    for item in sorted(path.iterdir()):
        entries.append({'name': item.name, 'type': 'directory' if item.is_dir() else 'file'})
    return {'result': entries}


TOOLS = {
    'fs.read': {
        'name': 'fs.read',
        'description': 'Read a UTF-8 file relative to the workspace.',
        'parameters': {'type': 'object', 'properties': {'path': {'type': 'string'}}},
        'handler': read_file,
    },
    'fs.list': {
        'name': 'fs.list',
        'description': 'List files in a workspace directory.',
        'parameters': {'type': 'object', 'properties': {'path': {'type': 'string'}}},
        'handler': list_directory,
    },
}


def send_response(message_id: Any, result: Any = None, error: Any = None) -> None:
    payload = {'jsonrpc': '2.0', 'id': message_id}
    if error is not None:
        payload['error'] = {'message': str(error)}
    else:
        payload['result'] = result
    sys.stdout.write(json.dumps(payload) + '\n')
    sys.stdout.flush()


def main() -> None:
    for line in sys.stdin:
        if not line.strip():
            continue
        try:
            message = json.loads(line)
        except json.JSONDecodeError as exc:
            send_response(None, error=f'Invalid JSON: {exc}')
            continue

        method = message.get('method')
        message_id = message.get('id')
        params = message.get('params') or {}

        try:
            if method == 'initialize':
                send_response(message_id, {'server': 'filesystem', 'workspace': str(WORKSPACE)})
            elif method == 'listTools':
                tools = [
                    {k: v for k, v in desc.items() if k != 'handler'}
                    for desc in TOOLS.values()
                ]
                send_response(message_id, {'tools': tools})
            elif method == 'callTool':
                name = params.get('name')
                arguments = params.get('arguments') or {}
                tool = TOOLS.get(name)
                if not tool:
                    raise ValueError(f'Unknown tool {name}')
                result = tool['handler'](arguments)
                send_response(message_id, result)
            elif method == 'shutdown':
                send_response(message_id, {'ok': True})
                break
            else:
                raise ValueError(f'Unknown method {method}')
        except Exception as exc:
            send_response(message_id, error=str(exc))


if __name__ == '__main__':
    main()
