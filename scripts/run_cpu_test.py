#!/usr/bin/env python3
import subprocess
import sys
import json
from pathlib import Path

# Get CPU test name from command-line argument
if len(sys.argv) < 2:
    print("Usage: run_cpu_test.py <test_name>")
    sys.exit(1)

test_name = sys.argv[1]
cpu_type = sys.argv[2] if len(sys.argv) > 2 else "--single-cycle"

# Determine CPU type and set appropriate flags
if cpu_type == "--pipelined":
    cpu_define = "-DCPU_PIPELINED"
    task_label = "Build Verilog Pipelined CPU Test"
    print(f"Building and running test: {test_name} (Pipelined CPU)\n")
elif cpu_type == "--single-cycle":
    cpu_define = "-DCPU_SINGLE_CYCLE"
    task_label = "Build Verilog SCCPU Test"
    print(f"Building and running test: {test_name} (Single-Cycle CPU)\n")
else:
    print(f"Usage: run_cpu_test.py <test_name> [--pipelined|--single-cycle]")
    sys.exit(1)

# Read tasks.json to get the iverilog command arguments
tasks_file = Path(".vscode/tasks.json")
with open(tasks_file, 'r') as f:
    tasks_data = json.load(f)

# Find the appropriate task
task_args = None
for task in tasks_data.get("tasks", []):
    if task.get("label") == task_label:
        task_args = task.get("args", [])
        break

if task_args is None:
    print(f"Error: Could not find task '{task_label}' in tasks.json")
    sys.exit(1)

# Replace input variables in the args
processed_args = []
for arg in task_args:
    arg = arg.replace("${input:cpuTestNameSelect}", test_name)
    arg = arg.replace("${input:elementNameSelect}", test_name)
    processed_args.append(arg)

# Run the sequence of commands with the selected test name
commands = [
    ["riscv-none-elf-as", "-march=rv32i", f"projects/programs/cpu_{test_name}_program.s", "-o", f"build/obj/cpu_{test_name}_program.o"],
    ["riscv-none-elf-objcopy", "-O", "verilog", f"build/obj/cpu_{test_name}_program.o", f"build/hex/cpu_{test_name}_program.hex"],
]

for cmd in commands:
    print(f"Running: {' '.join(cmd)}")
    result = subprocess.run(cmd, cwd=".")
    if result.returncode != 0:
        print(f"Error running: {' '.join(cmd)}")
        sys.exit(1)

# Format the hex file for Verilog (convert bytes to 32-bit words)
print(f"Formatting hex file...")
subprocess.run(["python", "scripts/format_hex.py", f"build/hex/cpu_{test_name}_program.hex", f"build/hex/cpu_{test_name}_program.hex"], cwd=".")

# Compile and run the simulation with arguments from tasks.json
sim_cmd = ["iverilog"] + processed_args

commands = [
    sim_cmd,
    ["vvp", f"build/sim/projects/cpu_{test_name}_sim"],
]

for cmd in commands:
    print(f"Running: {' '.join(cmd)}")
    result = subprocess.run(cmd, cwd=".")
    if result.returncode != 0:
        print(f"Error running: {' '.join(cmd)}")
        sys.exit(1)

print("\nBuild and test complete!")
