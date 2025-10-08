#!/usr/bin/env python3
"""
Fix Dashboard JSON Files Script
This script fixes JSON structure, removes nested wrappers, ensures proper titles, and fixes encoding
"""

import json
import os
import glob
from pathlib import Path

def fix_dashboard_file(file_path):
    """Fix a single dashboard file"""
    try:
        # Read file with UTF-8 encoding
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read().strip()
        
        if not content:
            print(f"[WARN] Empty file: {os.path.basename(file_path)}")
            return False
        
        # Parse JSON
        data = json.loads(content)
        
        # Extract dashboard content
        if 'dashboard' in data:
            dashboard = data['dashboard']
            print(f"Fixing nested structure: {os.path.basename(file_path)}")
        else:
            dashboard = data
        
        # Ensure required fields exist
        if 'title' not in dashboard or not dashboard['title']:
            dashboard['title'] = f"Untitled Dashboard - {os.path.basename(file_path)}"
        
        if 'id' not in dashboard:
            dashboard['id'] = None
        
        if 'version' not in dashboard:
            dashboard['version'] = 1
        
        if 'schemaVersion' not in dashboard:
            dashboard['schemaVersion'] = 36
        
        if 'time' not in dashboard:
            dashboard['time'] = {
                "from": "now-1h",
                "to": "now"
            }
        
        if 'refresh' not in dashboard:
            dashboard['refresh'] = "30s"
        
        if 'tags' not in dashboard:
            dashboard['tags'] = ["general"]
        
        if 'panels' not in dashboard:
            dashboard['panels'] = []
        
        # Ensure panels have required fields
        for i, panel in enumerate(dashboard.get('panels', [])):
            if 'id' not in panel:
                panel['id'] = i + 1
            if 'gridPos' not in panel:
                panel['gridPos'] = {
                    "h": 8,
                    "w": 12,
                    "x": 0,
                    "y": i * 8
                }
        
        # Add other required fields
        if 'annotations' not in dashboard:
            dashboard['annotations'] = {"list": []}
        
        if 'editable' not in dashboard:
            dashboard['editable'] = True
        
        if 'fiscalYearStartMonth' not in dashboard:
            dashboard['fiscalYearStartMonth'] = 0
        
        if 'graphTooltip' not in dashboard:
            dashboard['graphTooltip'] = 0
        
        if 'links' not in dashboard:
            dashboard['links'] = []
        
        if 'liveNow' not in dashboard:
            dashboard['liveNow'] = False
        
        if 'style' not in dashboard:
            dashboard['style'] = "dark"
        
        if 'templating' not in dashboard:
            dashboard['templating'] = {"list": []}
        
        if 'timepicker' not in dashboard:
            dashboard['timepicker'] = {}
        
        if 'uid' not in dashboard:
            dashboard['uid'] = os.path.splitext(os.path.basename(file_path))[0]
        
        if 'weekStart' not in dashboard:
            dashboard['weekStart'] = ""
        
        # Write the fixed dashboard back to file
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(dashboard, f, indent=2, ensure_ascii=False)
        
        print(f"[OK] Fixed: {os.path.basename(file_path)}")
        return True
        
    except json.JSONDecodeError as e:
        print(f"[ERROR] JSON error in {os.path.basename(file_path)}: {e}")
        return False
    except Exception as e:
        print(f"[ERROR] Error fixing {os.path.basename(file_path)}: {e}")
        return False

def main():
    """Main function"""
    print("=== Fixing All Dashboard JSON Files ===")
    
    # Find all dashboard files
    dashboard_dir = "monitoring/grafana/provisioning/dashboards"
    pattern = os.path.join(dashboard_dir, "**", "*.json")
    dashboard_files = glob.glob(pattern, recursive=True)
    
    print(f"Found {len(dashboard_files)} dashboard files")
    print()
    
    fixed_count = 0
    error_count = 0
    
    # Process each file
    for file_path in dashboard_files:
        if fix_dashboard_file(file_path):
            fixed_count += 1
        else:
            error_count += 1
    
    print()
    print("=== Fix Summary ===")
    print(f"Total files processed: {len(dashboard_files)}")
    print(f"Successfully fixed: {fixed_count}")
    print(f"Errors: {error_count}")
    
    print()
    print("[SUCCESS] Dashboard fixing completed!")

if __name__ == "__main__":
    main()
