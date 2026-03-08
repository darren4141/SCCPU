#!/usr/bin/env python3
"""Build and run all Verilog elements."""

import subprocess
import sys
import json
from pathlib import Path

# Read elements from tasks.json
tasks_file = Path(__file__).parent.parent / ".vscode" / "tasks.json"

with open(tasks_file, "r") as f:
    tasks = json.load(f)

# Find elementNameSelect input and extract options
elements = []
for input_item in tasks.get("inputs", []):
    if input_item.get("id") == "elementNameSelect":
        elements = input_item.get("options", [])
        break

if not elements:
    print("Error: Could not find elementNameSelect in tasks.json")
    sys.exit(1)

for element in elements:
    print(f"\n{'='*50}")
    print(f"Build and run: {element}")
    print(f"{'='*50}\n")
    
    # Build
    build_cmd = [
        "iverilog",
        "-g2012",
        "-I", "inc",
        "-I", "libraries",
        "-o", f"build/sim/{element}_sim",
        f"elements/{element}.v",
        f"tests/tb_{element}.v"
    ]
    
    print(f"Building {element}...")
    result = subprocess.run(build_cmd)
    if result.returncode != 0:
        print(f"Build failed for {element}")
        sys.exit(1)
    
    # Run
    run_cmd = ["vvp", f"build/sim/{element}_sim"]
    
    print(f"Running {element}...")
    result = subprocess.run(run_cmd)
    if result.returncode != 0:
        print(f"Run failed for {element}")
        sys.exit(1)

print(f"\n{'='*50}")
print("All elements completed successfully!")
print(f"{'='*50}")
