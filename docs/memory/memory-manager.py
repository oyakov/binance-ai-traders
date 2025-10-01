#!/usr/bin/env python3
"""
Memory Management Utility for Documentation System

This script provides utilities for managing the documentation memory system,
including adding new entries, updating existing ones, and maintaining the index.
"""

import os
import re
import json
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple

class MemoryManager:
    def __init__(self, memory_dir: str = "docs/memory"):
        self.memory_dir = Path(memory_dir)
        self.index_file = self.memory_dir / "memory-index.md"
        self.findings_dir = self.memory_dir / "findings"
        self.updates_dir = self.memory_dir / "updates"
        self.context_dir = self.memory_dir / "context"
        self.templates_dir = self.memory_dir / "templates"
        
        # Ensure directories exist
        for dir_path in [self.findings_dir, self.updates_dir, self.context_dir, self.templates_dir]:
            dir_path.mkdir(exist_ok=True)
    
    def get_next_id(self, memory_type: str) -> str:
        """Generate the next available ID for a memory type."""
        existing_ids = []
        
        # Scan all directories for existing IDs
        for dir_path in [self.findings_dir, self.updates_dir, self.context_dir, self.templates_dir]:
            for file_path in dir_path.glob("MEM-*.md"):
                match = re.match(r"MEM-(\d+)", file_path.stem)
                if match:
                    existing_ids.append(int(match.group(1)))
        
        # Find the next available number
        next_num = max(existing_ids, default=0) + 1
        
        # Generate ID based on type
        if memory_type == "finding":
            return f"MEM-{next_num:03d}"
        elif memory_type == "update":
            return f"MEM-U{next_num:03d}"
        elif memory_type == "context":
            return f"MEM-C{next_num:03d}"
        elif memory_type == "template":
            return f"MEM-T{next_num:03d}"
        else:
            return f"MEM-{next_num:03d}"
    
    def create_finding(self, title: str, summary: str, details: str, 
                      impact_scope: str, recommendations: List[str], 
                      code_references: List[str] = None) -> str:
        """Create a new finding entry."""
        memory_id = self.get_next_id("finding")
        filename = f"{memory_id}-{title.lower().replace(' ', '-')}.md"
        filepath = self.findings_dir / filename
        
        # Create the finding content
        content = f"""# {memory_id}: {title}

**Type**: Finding  
**Status**: Active  
**Created**: {datetime.now().strftime('%Y-%m-%d')}  
**Last Updated**: {datetime.now().strftime('%Y-%m-%d')}  
**Impact Scope**: {impact_scope}  

## Summary
{summary}

## Details
{details}

## Recommendations
{chr(10).join(f"- {rec}" for rec in recommendations)}

## Code References
{chr(10).join(f"- {ref}" for ref in (code_references or []))}

## Next Steps
- [ ] Review and validate finding
- [ ] Implement recommendations
- [ ] Update related documentation
"""
        
        # Write the file
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        
        # Update the index
        self._update_index(memory_id, title, "Finding", "Active", impact_scope)
        
        return memory_id
    
    def create_update(self, title: str, summary: str, changes: List[str], 
                     trigger: str) -> str:
        """Create a new update entry."""
        memory_id = self.get_next_id("update")
        filename = f"{memory_id}-{title.lower().replace(' ', '-')}.md"
        filepath = self.updates_dir / filename
        
        # Create the update content
        content = f"""# {memory_id}: {title}

**Type**: Update  
**Status**: Active  
**Created**: {datetime.now().strftime('%Y-%m-%d')}  
**Last Updated**: {datetime.now().strftime('%Y-%m-%d')}  
**Trigger**: {trigger}  

## Summary
{summary}

## Changes Made
{chr(10).join(f"1. {change}" for change in changes)}

## Next Steps
- [ ] Verify changes are complete
- [ ] Update related documentation
- [ ] Test implementation
"""
        
        # Write the file
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        
        # Update the index
        self._update_index(memory_id, title, "Update", "Active", "Global")
        
        return memory_id
    
    def _update_index(self, memory_id: str, title: str, memory_type: str, 
                     status: str, impact_scope: str):
        """Update the memory index with a new entry."""
        # Read current index
        if self.index_file.exists():
            with open(self.index_file, 'r', encoding='utf-8') as f:
                content = f.read()
        else:
            content = self._get_index_template()
        
        # Add entry to appropriate table
        if memory_type == "Finding":
            table_section = "## Active Findings"
        elif memory_type == "Update":
            table_section = "## Recent Updates"
        elif memory_type == "Context":
            table_section = "## Context Entries"
        elif memory_type == "Template":
            table_section = "## Templates"
        else:
            return
        
        # Find the table and add the entry
        table_pattern = rf"({re.escape(table_section)}.*?)(\n## |$)"
        match = re.search(table_pattern, content, re.DOTALL)
        
        if match:
            table_content = match.group(1)
            rest_content = match.group(2)
            
            # Add new row to table
            new_row = f"| {memory_id} | {title} | {memory_type} | {status} | {datetime.now().strftime('%Y-%m-%d')} | {impact_scope} |\n"
            
            # Insert after the table header
            lines = table_content.split('\n')
            for i, line in enumerate(lines):
                if '| --- |' in line:
                    lines.insert(i + 1, new_row)
                    break
            
            new_table_content = '\n'.join(lines)
            new_content = content.replace(table_content, new_table_content)
            
            # Write updated content
            with open(self.index_file, 'w', encoding='utf-8') as f:
                f.write(new_content)
    
    def _get_index_template(self) -> str:
        """Get the template for the memory index."""
        return """# Memory Index

This file serves as the central index for all memory entries in the documentation system. It tracks the status and relationships between different memory entries.

## Active Findings

| ID | Title | Type | Status | Last Updated | Impact Scope |
|----|-------|------|--------|--------------|--------------|

## Recent Updates

| ID | Title | Type | Status | Last Updated | Trigger |
|----|-------|------|--------|--------------|---------|

## Context Entries

| ID | Title | Type | Status | Last Updated | Scope |
|----|-------|------|--------|--------------|-------|

## Templates

| ID | Title | Type | Status | Last Updated | Usage |
|----|-------|------|--------|--------------|-------|

## Memory Statistics

- **Total Active Entries**: 0
- **Findings**: 0
- **Updates**: 0
- **Context**: 0
- **Templates**: 0
- **Last System Update**: {datetime.now().strftime('%Y-%m-%d')}

## Quick Reference

### Finding a Memory Entry
1. Check the appropriate table above
2. Navigate to the corresponding directory (`findings/`, `updates/`, `context/`, `templates/`)
3. Look for the file with the matching ID

### Adding a New Memory Entry
1. Generate a new ID (MEM-XXX format)
2. Create the appropriate file in the correct directory
3. Update this index with the new entry
4. Cross-reference with related entries

### Updating Memory Status
1. Locate the entry in the appropriate table
2. Update the status and last updated timestamp
3. Add any new cross-references if needed
4. Update memory statistics
"""
    
    def list_entries(self, memory_type: str = None) -> List[Dict]:
        """List all memory entries, optionally filtered by type."""
        entries = []
        
        for dir_path in [self.findings_dir, self.updates_dir, self.context_dir, self.templates_dir]:
            for file_path in dir_path.glob("MEM-*.md"):
                # Determine type from directory
                if dir_path == self.findings_dir:
                    entry_type = "Finding"
                elif dir_path == self.updates_dir:
                    entry_type = "Update"
                elif dir_path == self.context_dir:
                    entry_type = "Context"
                elif dir_path == self.templates_dir:
                    entry_type = "Template"
                else:
                    continue
                
                # Filter by type if specified
                if memory_type and entry_type.lower() != memory_type.lower():
                    continue
                
                # Read file to get metadata
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Extract metadata
                id_match = re.search(r'# (MEM-[^:]+):', content)
                status_match = re.search(r'\*\*Status\*\*: (\w+)', content)
                created_match = re.search(r'\*\*Created\*\*: (\d{4}-\d{2}-\d{2})', content)
                
                entries.append({
                    'id': id_match.group(1) if id_match else file_path.stem,
                    'type': entry_type,
                    'status': status_match.group(1) if status_match else 'Unknown',
                    'created': created_match.group(1) if created_match else 'Unknown',
                    'filepath': str(file_path)
                })
        
        return sorted(entries, key=lambda x: x['id'])
    
    def update_status(self, memory_id: str, new_status: str):
        """Update the status of a memory entry."""
        # Find the file
        for dir_path in [self.findings_dir, self.updates_dir, self.context_dir, self.templates_dir]:
            for file_path in dir_path.glob(f"{memory_id}*.md"):
                # Read and update the file
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Update status and last updated
                content = re.sub(r'\*\*Status\*\*: \w+', f'**Status**: {new_status}', content)
                content = re.sub(r'\*\*Last Updated\*\*: \d{4}-\d{2}-\d{2}', 
                               f'**Last Updated**: {datetime.now().strftime("%Y-%m-%d")}', content)
                
                # Write back
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                print(f"Updated {memory_id} status to {new_status}")
                return
        
        print(f"Memory entry {memory_id} not found")

def main():
    """Command-line interface for the memory manager."""
    import argparse
    
    parser = argparse.ArgumentParser(description='Memory Management Utility')
    parser.add_argument('--memory-dir', default='docs/memory', help='Memory directory path')
    
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # List command
    list_parser = subparsers.add_parser('list', help='List memory entries')
    list_parser.add_argument('--type', choices=['finding', 'update', 'context', 'template'], 
                           help='Filter by memory type')
    
    # Create finding command
    finding_parser = subparsers.add_parser('create-finding', help='Create a new finding')
    finding_parser.add_argument('--title', required=True, help='Finding title')
    finding_parser.add_argument('--summary', required=True, help='Finding summary')
    finding_parser.add_argument('--details', required=True, help='Finding details')
    finding_parser.add_argument('--impact-scope', required=True, help='Impact scope')
    finding_parser.add_argument('--recommendations', nargs='+', help='Recommendations')
    
    # Update status command
    status_parser = subparsers.add_parser('update-status', help='Update memory entry status')
    status_parser.add_argument('--id', required=True, help='Memory entry ID')
    status_parser.add_argument('--status', required=True, help='New status')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        return
    
    manager = MemoryManager(args.memory_dir)
    
    if args.command == 'list':
        entries = manager.list_entries(args.type)
        for entry in entries:
            print(f"{entry['id']}: {entry['type']} - {entry['status']} ({entry['created']})")
    
    elif args.command == 'create-finding':
        memory_id = manager.create_finding(
            title=args.title,
            summary=args.summary,
            details=args.details,
            impact_scope=args.impact_scope,
            recommendations=args.recommendations or []
        )
        print(f"Created finding: {memory_id}")
    
    elif args.command == 'update-status':
        manager.update_status(args.id, args.status)

if __name__ == '__main__':
    main()
