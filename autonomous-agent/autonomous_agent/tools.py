"""Filesystem tools exposed to the agent."""

from __future__ import annotations

import io
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List


class ToolError(RuntimeError):
    pass


@dataclass(slots=True)
class ToolContext:
    workspace: Path

    def resolve(self, relative: str) -> Path:
        candidate = (self.workspace / relative).resolve()
        if not str(candidate).startswith(str(self.workspace.resolve())):
            raise ToolError('Attempt to access path outside workspace')
        return candidate


class Tool:
    name: str = ''
    description: str = ''
    parameters: str = ''

    def __init__(self, context: ToolContext):
        self.context = context

    def describe(self) -> Dict[str, str]:
        return {
            'name': self.name,
            'description': self.description,
            'parameters': self.parameters,
        }

    def __call__(self, **kwargs) -> str:  # pragma: no cover - abstract
        raise NotImplementedError


class ReadFileTool(Tool):
    name = 'read_file'
    description = 'Read a text file from the workspace.'
    parameters = '{"path": "relative path"}'

    def __call__(self, path: str) -> str:
        file_path = self.context.resolve(path)
        if not file_path.exists():
            raise ToolError(f'File not found: {path}')
        return file_path.read_text(encoding='utf-8', errors='replace')


class WriteFileTool(Tool):
    name = 'write_file'
    description = 'Create or overwrite a text file with provided content.'
    parameters = '{"path": "relative path", "content": "full file content"}'

    def __call__(self, path: str, content: str) -> str:
        file_path = self.context.resolve(path)
        file_path.parent.mkdir(parents=True, exist_ok=True)
        file_path.write_text(content, encoding='utf-8')
        return f'Wrote {len(content)} characters to {path}'


class AppendFileTool(Tool):
    name = 'append_file'
    description = 'Append text to an existing file, creating it if necessary.'
    parameters = '{"path": "relative path", "content": "text to append"}'

    def __call__(self, path: str, content: str) -> str:
        file_path = self.context.resolve(path)
        file_path.parent.mkdir(parents=True, exist_ok=True)
        with file_path.open('a', encoding='utf-8') as handle:
            handle.write(content)
        return f'Appended {len(content)} characters to {path}'


class ListDirectoryTool(Tool):
    name = 'list_directory'
    description = 'List files under a directory.'
    parameters = '{"path": "relative directory"}'

    def __call__(self, path: str = '.') -> str:
        dir_path = self.context.resolve(path)
        if not dir_path.exists():
            raise ToolError(f'Directory not found: {path}')
        if not dir_path.is_dir():
            raise ToolError(f'Not a directory: {path}')
        lines = []
        for item in sorted(dir_path.iterdir()):
            marker = '/' if item.is_dir() else ''
            lines.append(item.name + marker)
        return '\n'.join(lines)


class SearchFileTool(Tool):
    name = 'search_file'
    description = 'Search for a regular expression inside a file.'
    parameters = '{"path": "relative path", "pattern": "regular expression"}'

    def __call__(self, path: str, pattern: str) -> str:
        file_path = self.context.resolve(path)
        if not file_path.exists():
            raise ToolError(f'File not found: {path}')
        text = file_path.read_text(encoding='utf-8', errors='replace')
        matches = list(re.finditer(pattern, text, flags=re.MULTILINE))
        if not matches:
            return 'No matches found.'
        output = io.StringIO()
        for match in matches:
            start = max(match.start() - 40, 0)
            end = min(match.end() + 40, len(text))
            snippet = text[start:end].replace('\n', '\\n')
            output.write(f'{match.start()}-{match.end()}: {snippet}\n')
        return output.getvalue().strip()


class ToolRegistry:
    def __init__(self, context: ToolContext):
        self._context = context
        self._tools: Dict[str, Tool] = {}

    def register(self, tool_or_cls) -> None:
        if isinstance(tool_or_cls, type):
            tool = tool_or_cls(self._context)
        else:
            tool = tool_or_cls
        self._tools[tool.name] = tool

    def get(self, name: str) -> Tool:
        if name not in self._tools:
            raise ToolError(f'Unknown tool: {name}')
        return self._tools[name]

    def names(self) -> List[str]:
        return sorted(self._tools.keys())

    def describe(self) -> List[Dict[str, str]]:
        return [tool.describe() for tool in self._tools.values()]

    def execute(self, name: str, **kwargs) -> str:
        tool = self.get(name)
        return tool(**kwargs)


def create_default_registry(workspace: Path) -> ToolRegistry:
    context = ToolContext(workspace=workspace.resolve())
    registry = ToolRegistry(context)
    for tool_cls in (ReadFileTool, WriteFileTool, AppendFileTool, ListDirectoryTool, SearchFileTool):
        registry.register(tool_cls)
    return registry


__all__ = [
    'ToolContext',
    'Tool',
    'ToolRegistry',
    'ToolError',
    'create_default_registry',
]
