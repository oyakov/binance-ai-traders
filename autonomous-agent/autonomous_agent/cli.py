"""Command line interface for the autonomous agent."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Optional

from .agent import AutonomousCoderAgent
from .config import load_config
from .planner import Planner


def parse_args(argv: Optional[list[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description='Autonomous coding agent CLI')
    parser.add_argument('--config', type=Path, help='Path to config.toml')
    parser.add_argument('--task', required=True, help='Task for the agent to solve')
    parser.add_argument('--plan-only', action='store_true', help='Only generate a plan')
    parser.add_argument('--json', action='store_true', help='Emit JSON output')
    return parser.parse_args(argv)


def main(argv: Optional[list[str]] = None) -> int:
    args = parse_args(argv)
    runtime = load_config(args.config)
    agent = AutonomousCoderAgent(runtime)

    if args.plan_only:
        planner = Planner(agent.llm, Path(__file__).parent / 'prompts' / 'system_planner.txt')
        plan = planner.make_plan(args.task, agent.tools.names())
        if args.json:
            print(json.dumps({'task': args.task, 'plan': [step.description for step in plan.steps]}, ensure_ascii=False))
        else:
            print(plan.summary())
        return 0

    result = agent.run(args.task)
    if args.json:
        print(
            json.dumps(
                {
                    'task': result.task,
                    'final': result.final_response,
                    'plan': [step.description for step in (result.plan.steps if result.plan else [])],
                    'iterations': result.iterations,
                    'tool_calls': result.tool_calls,
                },
                ensure_ascii=False,
            )
        )
    else:
        if result.plan:
            print(result.plan.summary())
            print('-' * 40)
        print(result.final_response)
    return 0


if __name__ == '__main__':  # pragma: no cover - CLI entry point
    raise SystemExit(main())
