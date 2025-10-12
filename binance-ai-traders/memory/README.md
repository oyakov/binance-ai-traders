# Documentation Memory System

This directory contains the memory system for maintaining and updating project documentation. The memory system acts as a persistent knowledge base that tracks findings, updates, and context across LLM interactions.

## Structure

- `memory-index.md` - Central index of all memory entries and their status
- `findings/` - Directory for storing specific findings and discoveries
- `updates/` - Directory for tracking documentation updates and changes
- `context/` - Directory for maintaining contextual information
- `templates/` - Directory for documentation templates and standards

## Memory Types

### 1. Findings Memory
Stores significant discoveries about the codebase, architecture, or implementation details.

### 2. Update Memory
Tracks documentation updates, when they were made, and what triggered them.

### 3. Context Memory
Maintains contextual information about the project state, dependencies, and relationships.

### 4. Template Memory
Stores reusable documentation templates and formatting standards.

## Usage

The memory system should be updated after every significant finding or change. Each memory entry should include:

- **Timestamp**: When the finding was made or update occurred
- **Source**: What triggered the discovery (code analysis, user request, etc.)
- **Impact**: What parts of the project are affected
- **Status**: Current state (active, outdated, needs-verification)
- **References**: Links to related documentation or code

## Memory Management

- Regular cleanup of outdated entries
- Verification of active findings
- Cross-referencing between related memories
- Integration with existing documentation structure
