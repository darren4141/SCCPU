#!/usr/bin/env python3
"""Build and run all CPU tests."""

import subprocess
import sys
import json
import re
from pathlib import Path
from collections import defaultdict

# Parse command-line argument for CPU type
cpu_type = "--single-cycle"  # Default
if len(sys.argv) > 1:
    if sys.argv[1] in ["--pipelined", "--single-cycle"]:
        cpu_type = sys.argv[1]
        sys.argv.pop(1)  # Remove the CPU type arg so it doesn't interfere with other processing
    else:
        print(f"Usage: build_all_cpu_tests.py [--pipelined|--single-cycle]")
        sys.exit(1)

# RV32I base instruction set
RV32I_INSTRUCTIONS = {
    # Arithmetic
    "add", "addi", "sub",
    # Logical
    "and", "andi", "or", "ori", "xor", "xori",
    # Shifts
    "sll", "slli", "srl", "srli", "sra", "srai",
    # Branches
    "beq", "bne", "blt", "bge", "bltu", "bgeu",
    # Jumps
    "jal", "jalr",
    # Loads
    "lb", "lh", "lw", "lbu", "lhu",
    # Stores
    "sb", "sh", "sw",
    # Upper Immediate
    "lui", "auipc",
    # Set
    "slt", "slti", "sltu", "sltiu",
    # Fence
    "fence", "fence.i",
    # Environment
    "ecall", "ebreak",
}

# Known common RISC-V pseudo-instructions and instruction variants
KNOWN_MNEMONICS = RV32I_INSTRUCTIONS | {
    # Pseudo-instructions
    "bgt", "ble", "bgtu", "bleu", "beqz", "bnez", "blez", "bgez", "bltz", "bgtz",
    "j", "jr", "ret", "nop", "mv", "not", "neg", "li", "la", "call", "tail",
    # Directive-like
    ".align", ".byte", ".half", ".word", ".string", ".data", ".text", ".globl",
    ".extern", ".section", ".include", ".macro", ".endm", ".if", ".else", ".endif",
}

def extract_instructions_from_program(program_path):
    """Extract RISC-V instructions from an assembly program."""
    instructions = set()
    try:
        with open(program_path, 'r') as f:
            for line in f:
                # Remove comments
                line = line.split('#')[0].strip()
                if not line:
                    continue
                
                # Skip lines that are just labels (ending with :)
                if line.endswith(':'):
                    continue
                
                # Extract the first word (instruction mnemonic)
                match = re.match(r'(\w+)', line)
                if match:
                    instr = match.group(1).lower()
                    # Only add if it looks like a known mnemonic (contains letters)
                    # This filters out numeric immediate values and labels
                    if any(c.isalpha() for c in instr) and instr in KNOWN_MNEMONICS:
                        instructions.add(instr)
    except (IOError, OSError):
        pass
    
    return instructions

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

# Collect all instructions used across tests
all_tested_instructions = set()
program_dir = Path(__file__).parent.parent / "projects" / "programs"

# Track test results
test_results = {}
total_passed = 0
total_failed = 0
build_failures = []

for test in cpu_tests:
    print(f"\n{'='*50}")
    print(f"Build and run: {test}")
    print(f"{'='*50}\n")
    
    # Extract instructions from this test's program
    program_file = program_dir / f"cpu_{test}_program.s"
    test_instructions = extract_instructions_from_program(program_file)
    all_tested_instructions.update(test_instructions)
    
    # Run the CPU test script (handles assembly, hex generation, build, and run)
    run_cmd = ["python", "scripts/run_cpu_test.py", test, cpu_type]
    
    print(f"Building and running {test}...")
    result = subprocess.run(run_cmd, capture_output=True, text=True)
    
    # Print output
    print(result.stdout)
    if result.stderr:
        print(result.stderr)
    
    # Check for build failure
    if result.returncode != 0:
        build_failures.append({
            "test": test,
            "error": result.stderr or result.stdout
        })
        test_results[test] = {"passed": 0, "failed": 0, "status": "BUILD_FAILED"}
        print(f"Warning: Build failed for {test}")
    else:
        # Parse test results
        passed = result.stdout.count("PASS:")
        failed = result.stdout.count("FAIL:")
        
        test_results[test] = {"passed": passed, "failed": failed, "status": "RUN_COMPLETE"}
        total_passed += passed
        total_failed += failed

print(f"\n{'='*50}")
print("TEST RECAP")
print(f"{'='*50}")
for test, results in test_results.items():
    status = results.get("status", "RUN_COMPLETE")
    
    if status == "BUILD_FAILED":
        print(f"\033[91m{test:20}\033[0m \033[91mBUILD FAILED\033[0m")
    else:
        passed = results["passed"]
        failed = results["failed"]
        
        if failed == 0:
            color = "\033[92m" # GREEN
        else:
            color = "\033[91m" # RED
        reset = "\033[0m"
        
        print(f"{color}{test:20}{reset} PASS: {passed:3}  FAIL: {failed:3}")

print(f"{'-'*50}")
print(f"{'TOTAL':20} PASS: {total_passed:3}  FAIL: {total_failed:3}  BUILD FAILURES: {len(build_failures):3}")
print(f"{'='*50}")

# Instruction coverage diagnostics
print(f"\n{'='*50}")
print("INSTRUCTION COVERAGE DIAGNOSTICS")
print(f"{'='*50}")

tested_rv32i = all_tested_instructions & RV32I_INSTRUCTIONS
untested_rv32i = RV32I_INSTRUCTIONS - all_tested_instructions
non_standard = all_tested_instructions - RV32I_INSTRUCTIONS

coverage_pct = (len(tested_rv32i) / len(RV32I_INSTRUCTIONS)) * 100

print(f"\nRV32I Instruction Coverage:")
print(f"  Tested:    {len(tested_rv32i):3}/{len(RV32I_INSTRUCTIONS)} ({coverage_pct:5.1f}%)")
print(f"  Not Tested: {len(untested_rv32i):3}/{len(RV32I_INSTRUCTIONS)}")

if tested_rv32i:
    print(f"\n[OK] Tested Instructions ({len(tested_rv32i)}):")
    # Group by category
    by_category = defaultdict(list)
    for instr in sorted(tested_rv32i):
        if instr in {"add", "addi", "sub"}:
            by_category["Arithmetic"].append(instr)
        elif instr in {"and", "andi", "or", "ori", "xor", "xori"}:
            by_category["Logical"].append(instr)
        elif instr in {"sll", "slli", "srl", "srli", "sra", "srai"}:
            by_category["Shift"].append(instr)
        elif instr in {"beq", "bne", "blt", "bge", "bltu", "bgeu"}:
            by_category["Branch"].append(instr)
        elif instr in {"jal", "jalr"}:
            by_category["Jump"].append(instr)
        elif instr in {"lb", "lh", "lw", "lbu", "lhu"}:
            by_category["Load"].append(instr)
        elif instr in {"sb", "sh", "sw"}:
            by_category["Store"].append(instr)
        elif instr in {"lui", "auipc"}:
            by_category["Upper Immediate"].append(instr)
        elif instr in {"slt", "slti", "sltu", "sltiu"}:
            by_category["Set"].append(instr)
        else:
            by_category["Other"].append(instr)
    
    for category in sorted(by_category.keys()):
        instrs = by_category[category]
        print(f"    {category:15} {', '.join(sorted(instrs))}")

if untested_rv32i:
    print(f"\n[MISSING] Untested Instructions ({len(untested_rv32i)}):")
    # Group by category
    by_category = defaultdict(list)
    for instr in sorted(untested_rv32i):
        if instr in {"add", "addi", "sub"}:
            by_category["Arithmetic"].append(instr)
        elif instr in {"and", "andi", "or", "ori", "xor", "xori"}:
            by_category["Logical"].append(instr)
        elif instr in {"sll", "slli", "srl", "srli", "sra", "srai"}:
            by_category["Shift"].append(instr)
        elif instr in {"beq", "bne", "blt", "bge", "bltu", "bgeu"}:
            by_category["Branch"].append(instr)
        elif instr in {"jal", "jalr"}:
            by_category["Jump"].append(instr)
        elif instr in {"lb", "lh", "lw", "lbu", "lhu"}:
            by_category["Load"].append(instr)
        elif instr in {"sb", "sh", "sw"}:
            by_category["Store"].append(instr)
        elif instr in {"lui", "auipc"}:
            by_category["Upper Immediate"].append(instr)
        elif instr in {"slt", "slti", "sltu", "sltiu"}:
            by_category["Set"].append(instr)
        else:
            by_category["Other"].append(instr)
    
    for category in sorted(by_category.keys()):
        instrs = by_category[category]
        print(f"    {category:15} {', '.join(sorted(instrs))}")

if non_standard:
    print(f"\n[WARNING] Non-standard Instructions ({len(non_standard)}):")
    print(f"    {', '.join(sorted(non_standard))}")

print(f"{'='*50}\n")

# Display build failures if any
if build_failures:
    print(f"{'='*50}")
    print("BUILD FAILURES")
    print(f"{'='*50}")
    for failure in build_failures:
        print(f"\n{failure['test']}:")
        print(f"  Error output:")
        # Print first few lines of error
        error_lines = failure['error'].split('\n')[:5]
        for line in error_lines:
            if line.strip():
                print(f"    {line}")
        if len(failure['error'].split('\n')) > 5:
            print(f"    ... (see full output above)")
    print(f"{'='*50}\n")

if total_failed == 0 and len(build_failures) == 0:
    print("\033[92mAll tests passed!\033[0m")
elif len(build_failures) > 0:
    print(f"\033[91m{len(build_failures)} build failure(s) and {total_failed} test(s) failed!\033[0m")
    sys.exit(1)
else:
    print(f"\033[91m{total_failed} test(s) failed!\033[0m")
    sys.exit(1)
