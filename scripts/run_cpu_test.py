#!/usr/bin/env python3
import subprocess
import sys

# Get CPU test name from command-line argument
if len(sys.argv) < 2:
    print("Usage: run_cpu_test.py <test_name>")
    sys.exit(1)

test_name = sys.argv[1]
print(f"Building and running test: {test_name}\n")

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

# Compile and run the simulation
commands = [
    ["iverilog", "-g2012", "-I", "elements/inc", "-I", "libraries", "-o", f"build/sim/projects/cpu_{test_name}_sim", "projects/src/cpu_single_cycle.v", "elements/src/adder.v", "elements/src/alu.v", "elements/src/bcomp.v", "elements/src/control.v", "elements/src/dmem.v", "elements/src/imem.v", "elements/src/imm_gen.v", "elements/src/muxes.v", "elements/src/pc.v", "elements/src/regfile.v", f"projects/tests/tb_cpu_{test_name}.v"],
    ["vvp", f"build/sim/projects/cpu_{test_name}_sim"],
]

for cmd in commands:
    print(f"Running: {' '.join(cmd)}")
    result = subprocess.run(cmd, cwd=".")
    if result.returncode != 0:
        print(f"Error running: {' '.join(cmd)}")
        sys.exit(1)

print("\nBuild and test complete!")
