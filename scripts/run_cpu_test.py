#!/usr/bin/env python3
import subprocess
import sys

# Get CPU test name from command-line argument
if len(sys.argv) < 2:
    print("Usage: run_cpu_test.py <test_name>")
    sys.exit(1)

test_name = sys.argv[1]
cpu_type = sys.argv[2] if len(sys.argv) > 2 else "--single-cycle"

# Determine CPU type and set appropriate flags
if cpu_type == "--pipelined":
    cpu_define = "-DCPU_PIPELINED"
    print(f"Building and running test: {test_name} (Pipelined CPU)\n")
elif cpu_type == "--single-cycle":
    cpu_define = "-DCPU_SINGLE_CYCLE"
    print(f"Building and running test: {test_name} (Single-Cycle CPU)\n")
else:
    print(f"Usage: run_cpu_test.py <test_name> [--pipelined|--single-cycle]")
    sys.exit(1)

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

# Format the hex file for Verilosg (convert bytes to 32-bit words)
print(f"Formatting hex file...")
subprocess.run(["python", "scripts/format_hex.py", f"build/hex/cpu_{test_name}_program.hex", f"build/hex/cpu_{test_name}_program.hex"], cwd=".")

# Compile and run the simulation
if cpu_type == "--pipelined":
    # Build with pipelined CPU and all pipelined components
    sim_cmd = ["iverilog", "-g2012", cpu_define, "-I", "elements/inc", "-I", "libraries", "-I", "projects/inc", "-o", f"build/sim/projects/cpu_{test_name}_sim", "projects/src/cpu_pipelined.v", "elements/src/adder.v", "elements/src/alu.v", "elements/src/bcomp.v", "elements/src/control.v", "elements/src/dmem.v", "elements/src/ex_reg.v", "elements/src/flush.v", "elements/src/forwarding.v", "elements/src/id_reg.v", "elements/src/if_reg.v", "elements/src/imem.v", "elements/src/imm_gen.v", "elements/src/m_reg.v", "elements/src/muxes.v", "elements/src/pc.v", "elements/src/pipeline_psd_control.v", "elements/src/regfile.v", "elements/src/stalling.v", f"projects/tests/tb_cpu_{test_name}.v"]
else:
    # Build with single-cycle CPU
    sim_cmd = ["iverilog", "-g2012", cpu_define, "-I", "elements/inc", "-I", "libraries", "-I", "projects/inc", "-o", f"build/sim/projects/cpu_{test_name}_sim", "projects/src/cpu_single_cycle.v", "elements/src/adder.v", "elements/src/alu.v", "elements/src/bcomp.v", "elements/src/control.v", "elements/src/dmem.v", "elements/src/imem.v", "elements/src/imm_gen.v", "elements/src/muxes.v", "elements/src/pc.v", "elements/src/regfile.v", f"projects/tests/tb_cpu_{test_name}.v"]

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
