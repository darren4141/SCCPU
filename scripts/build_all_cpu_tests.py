#!/usr/bin/env python3
"""Build and run all CPU tests."""

import subprocess
import sys
import json
from pathlib import Path

# Read CPU tests from tasks.json
tasks_file = Path(__file__).parent.parent / ".vscode" / "tasks.json"

with open(tasks_file, "r") as f:
    tasks = json.load(f)

# Find cpuTestNameSelect input and extract options
cpu_tests = []
for input_item in tasks.get("inputs", []):
    if input_item.get("id") == "cpuTestNameSelect":
        cpu_tests = input_item.get("options", [])
        break

if not cpu_tests:
    print("Error: Could not find cpuTestNameSelect in tasks.json")
    sys.exit(1)

# Track test results
test_results = {}
total_passed = 0
total_failed = 0

for test in cpu_tests:
    print(f"\n{'='*50}")
    print(f"Build and run: {test}")
    print(f"{'='*50}\n")
    
    # Run the CPU test script (handles assembly, hex generation, build, and run)
    run_cmd = ["python", "scripts/run_cpu_test.py", test]
    
    print(f"Building and running {test}...")
    result = subprocess.run(run_cmd, capture_output=True, text=True)
    
    # Print output
    print(result.stdout)
    if result.stderr:
        print(result.stderr)
    
    # Parse test results
    passed = result.stdout.count("PASS:")
    failed = result.stdout.count("FAIL:")
    
    test_results[test] = {"passed": passed, "failed": failed}
    total_passed += passed
    total_failed += failed
    
    if result.returncode != 0:
        print(f"Test failed for {test}")
        sys.exit(1)

print(f"\n{'='*50}")
print("TEST RECAP")
print(f"{'='*50}")
for test, results in test_results.items():
    passed = results["passed"]
    failed = results["failed"]
    
    if failed == 0:
        color = "\033[92m" # GREEN
    else:
        color = "\033[91m" # RED
    reset = "\033[0m"
    
    print(f"{color}{test:15}{reset} PASS: {passed:3}  FAIL: {failed:3}")

print(f"{'-'*50}")
print(f"{'TOTAL':15} PASS: {total_passed:3}  FAIL: {total_failed:3}")
print(f"{'='*50}")

if total_failed == 0:
    print(f"\033[92mAll tests passed!\033[0m")
else:
    print(f"\033[91m{total_failed} test(s) failed!\033[0m")
    sys.exit(1)
