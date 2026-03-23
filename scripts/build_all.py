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

# Track test results
test_results = {}
total_passed = 0
total_failed = 0

for element in elements:
    print(f"\n{'='*50}")
    print(f"Build and run: {element}")
    print(f"{'='*50}\n")
    
    # Build
    build_cmd = [
        "iverilog",
        "-g2012",
        "-I", "elements/inc",
        "-I", "libraries",
        "-o", f"build/sim/elements/{element}_sim",
        f"elements/src/{element}.v",
        f"elements/tests/tb_{element}.v"
    ]
    
    print(f"Building {element}...")
    result = subprocess.run(build_cmd)
    if result.returncode != 0:
        print(f"Build failed for {element}")
        sys.exit(1)
    
    # Run
    run_cmd = ["vvp", f"build/sim/elements/{element}_sim"]
    
    print(f"Running {element}...")
    result = subprocess.run(run_cmd, capture_output=True, text=True)
    
    # Print output
    print(result.stdout)
    if result.stderr:
        print(result.stderr)
    
    # Parse test results
    passed = result.stdout.count("PASS:")
    failed = result.stdout.count("FAIL:")
    
    test_results[element] = {"passed": passed, "failed": failed}
    total_passed += passed
    total_failed += failed
    
    if result.returncode != 0:
        print(f"Run failed for {element}")
        sys.exit(1)

print(f"\n{'='*50}")
print("TEST RECAP")
print(f"{'='*50}")
for element, results in test_results.items():
    passed = results["passed"]
    failed = results["failed"]
    
    if failed == 0:
        color = "\033[92m" # GREEN
    else:
        color = "\033[91m" # RED
    reset = "\033[0m"
    
    print(f"{color}{element:20}{reset} PASS: {passed:3}  FAIL: {failed:3}")

print(f"{'-'*50}")
print(f"{'TOTAL':20} PASS: {total_passed:3}  FAIL: {total_failed:3}")
print(f"{'='*50}")

if total_failed == 0:
    print(f"{"\033[92m"}All tests passed!")
else:
    print(f"{"\033[91m"}{total_failed} test(s) failed!")
    sys.exit(1)
