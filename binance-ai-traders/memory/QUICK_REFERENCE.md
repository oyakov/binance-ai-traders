# Memory System Quick Reference

## Overview

The memory system maintains persistent knowledge about the project to support LLM interactions and documentation management.

## Quick Commands

### Using the Memory Manager Script

```bash
# List all memory entries
python docs/memory/memory-manager.py list

# List only findings
python docs/memory/memory-manager.py list --type finding

# Create a new finding
python docs/memory/memory-manager.py create-finding \
  --title "Service Implementation Issue" \
  --summary "Brief description of the issue" \
  --details "Detailed analysis of the problem" \
  --impact-scope "service-name" \
  --recommendations "Fix the issue" "Add tests"

# Update memory entry status
python docs/memory/memory-manager.py update-status --id MEM-001 --status Resolved
```

### Manual Memory Management

1. **Add New Finding**:
   - Create file in `docs/memory/findings/`
   - Use template from `docs/memory/templates/MEM-T002-finding-documentation-template.md`
   - Update `docs/memory/memory-index.md`

2. **Add New Update**:
   - Create file in `docs/memory/updates/`
   - Document what changed and why
   - Update memory index

3. **Add Context**:
   - Create file in `docs/memory/context/`
   - Document project state or relationships
   - Update memory index

## Memory Types

| Type | Purpose | Directory | Template |
|------|---------|-----------|----------|
| Finding | Significant discoveries | `findings/` | MEM-T002 |
| Update | Documentation changes | `updates/` | Custom |
| Context | Project state/relationships | `context/` | Custom |
| Template | Reusable standards | `templates/` | Custom |

## ID Format

- **Findings**: MEM-001, MEM-002, etc.
- **Updates**: MEM-U001, MEM-U002, etc.
- **Context**: MEM-C001, MEM-C002, etc.
- **Templates**: MEM-T001, MEM-T002, etc.

## Status Values

- **Active**: Current and relevant
- **Resolved**: Addressed/completed
- **Outdated**: No longer relevant

## Best Practices

### When to Update Memory
- After significant code analysis
- When discovering architectural issues
- After implementing major changes
- When finding missing components
- After resolving problems

### Memory Entry Guidelines
- Use descriptive, searchable titles
- Include specific code references
- Provide actionable recommendations
- Cross-reference related entries
- Keep status current

### Maintenance
- Review memory entries monthly
- Update status when issues are resolved
- Archive outdated entries
- Verify cross-references
- Update memory statistics

## Integration with LLM

The memory system provides:
- **Context**: Persistent knowledge across sessions
- **Findings**: Discovered issues and recommendations
- **Updates**: Track of what has changed
- **Templates**: Consistent documentation standards

When working with LLMs:
1. Reference relevant memory entries
2. Update memory after significant findings
3. Use templates for consistent documentation
4. Cross-reference related information
5. Maintain current status information

## File Structure

```
docs/memory/
├── README.md                           # System overview
├── memory-index.md                     # Central index
├── QUICK_REFERENCE.md                  # This file
├── memory-manager.py                   # Management utility
├── findings/                           # Discovery findings
│   ├── MEM-001-*.md
│   └── MEM-002-*.md
├── updates/                            # Documentation updates
│   └── MEM-U001-*.md
├── context/                            # Project context
│   ├── MEM-C001-*.md
│   └── MEM-C002-*.md
└── templates/                          # Documentation templates
    ├── MEM-T001-*.md
    └── MEM-T002-*.md
```
