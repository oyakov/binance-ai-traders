
"""Test package initialization for the telegram frontend project."""

from pathlib import Path
import sys

# Ensure the application source directory is importable when running the test suite.
SRC_PATH = Path(__file__).resolve().parents[1] / 'src'
if SRC_PATH.exists():
    sys.path.insert(0, str(SRC_PATH))

