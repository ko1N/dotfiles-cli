#!/usr/bin/env python3
"""
Merge fish history files and remove duplicates.
Combines all files starting with "fish_history" in the current directory.
"""

import os
import glob
import re
from collections import defaultdict

def parse_fish_history_file(filepath):
    """Parse a fish history file using custom parsing instead of YAML."""
    entries = []
    
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return []
    
    # Split into individual entries (separated by lines starting with "- cmd:")
    entry_pattern = r'^- cmd: (.*)$'
    lines = content.split('\n')
    
    current_entry = None
    i = 0
    
    while i < len(lines):
        line = lines[i].rstrip()
        
        # Start of new entry
        if line.startswith('- cmd: '):
            # Save previous entry if exists
            if current_entry and 'cmd' in current_entry and 'when' in current_entry:
                entries.append(current_entry)
            
            # Start new entry
            cmd = line[7:]  # Remove "- cmd: "
            current_entry = {'cmd': cmd}
            
        elif line.startswith('  when: ') and current_entry:
            try:
                when_str = line[8:]  # Remove "  when: "
                current_entry['when'] = int(when_str)
            except ValueError:
                print(f"Warning: Invalid timestamp in {filepath}: {line}")
                
        elif line.startswith('  paths:') and current_entry:
            # Read paths
            current_entry['paths'] = []
            i += 1
            while i < len(lines) and lines[i].startswith('    - '):
                path = lines[i][6:]  # Remove "    - "
                current_entry['paths'].append(path)
                i += 1
            i -= 1  # Back up one since we'll increment at end of loop
            
        i += 1
    
    # Don't forget the last entry
    if current_entry and 'cmd' in current_entry and 'when' in current_entry:
        entries.append(current_entry)
    
    return entries

def merge_and_deduplicate_entries(all_entries):
    """Merge entries and remove duplicates, keeping the most recent timestamp."""
    # Group by command, keeping the entry with the latest timestamp
    cmd_to_entry = {}
    
    for entry in all_entries:
        cmd = entry['cmd']
        when = entry['when']
        
        if cmd not in cmd_to_entry or when > cmd_to_entry[cmd]['when']:
            cmd_to_entry[cmd] = entry
    
    # Sort by timestamp
    return sorted(cmd_to_entry.values(), key=lambda x: x['when'])

def escape_fish_command(cmd):
    """Escape command for fish history format if needed."""
    # If command contains newlines, colons in quotes, or other special chars,
    # we need to handle it carefully
    if '\n' in cmd or ('"' in cmd and ':' in cmd):
        # For complex commands, we might need special handling
        # For now, just return as-is since fish seems to handle most cases
        return cmd
    return cmd

def write_fish_history_file(entries, output_path):
    """Write entries to a fish history file."""
    try:
        with open(output_path, 'w', encoding='utf-8') as f:
            for i, entry in enumerate(entries):
                if i > 0:
                    f.write('\n')
                
                # Write command
                f.write(f"- cmd: {escape_fish_command(entry['cmd'])}\n")
                
                # Write timestamp
                f.write(f"  when: {entry['when']}\n")
                
                # Write paths if present
                if 'paths' in entry and entry['paths']:
                    f.write("  paths:\n")
                    for path in entry['paths']:
                        f.write(f"    - {path}\n")
        
        print(f"Successfully wrote {len(entries)} entries to {output_path}")
    except Exception as e:
        print(f"Error writing to {output_path}: {e}")

def main():
    # Find all fish_history files in current directory
    pattern = 'fish_history*'
    files = glob.glob(pattern)
    
    if not files:
        print("No files starting with 'fish_history' found in current directory.")
        return
    
    print(f"Found {len(files)} fish history files: {', '.join(files)}")
    
    # Load all entries
    all_entries = []
    total_loaded = 0
    
    for filepath in files:
        print(f"Loading {filepath}...")
        entries = parse_fish_history_file(filepath)
        all_entries.extend(entries)
        total_loaded += len(entries)
        print(f"  Loaded {len(entries)} entries")
    
    print(f"\nTotal entries loaded: {total_loaded}")
    
    if not all_entries:
        print("No valid entries found in any files.")
        return
    
    # Merge and deduplicate
    print("Merging and removing duplicates...")
    merged_entries = merge_and_deduplicate_entries(all_entries)
    
    duplicates_removed = len(all_entries) - len(merged_entries)
    print(f"Removed {duplicates_removed} duplicate commands")
    print(f"Final entry count: {len(merged_entries)}")
    
    # Write combined file
    output_file = 'fish_history.combined'
    write_fish_history_file(merged_entries, output_file)
    
    print(f"\nMerged history saved to: {output_file}")

if __name__ == '__main__':
    main()
