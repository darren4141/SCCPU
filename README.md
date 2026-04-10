# Single Cycle CPU in Verilog

A educational RISC-V processor implementation in Verilog, designed to learn CPU architecture by building a functional single-cycle processor from the ground up. This project implements core RISC-V RV32I instruction set with comprehensive unit tests for each instruction type and CPU component.

## Overview

This project implements a complete RISC-V RV32I single-cycle CPU with the following characteristics:
- **Target ISA**: RISC-V RV32I (32-bit base instruction set)
- **Implementation**: Pure single-cycle design (all operations complete in one clock cycle)
- **Architecture**: Harvard-style with separate instruction and data memory
- **Languages**: Verilog (design) + RISC-V Assembly (test programs)

## Project Statistics

### RISC-V Instruction Coverage
- **Instructions Tested**: 16 out of ~40 core RV32I instructions
- **Coverage**: ~40% of RISC-V RV32I base instruction set
- **Instruction Types Covered**:
  - **R-type** (Register-to-Register): add, sub, and, or, xor, sll, srl, slt
  - **I-type** (Immediate): addi, andi, ori, xori, slli, srli, slti, lw, lh, jalr
  - **S-type** (Store): sw
  - **B-type** (Branch): beq, bne, blt, bge
  - **U-type** (Upper Immediate): lui, auipc
  - **J-type** (Jump): jal

### Component Breakdown
- **18 Core Components** in `/elements/src/`:
  - Logic: ALU (32 operations), Control Unit, Branch Comparator, Immediate Generator
  - Memory: Instruction Memory (imem), Data Memory (dmem)
  - Registers: Register File (32 x 32-bit), Program Counter
  - Routing: Multiplexers for data routing
  - Utilities: Adder, Pipeline stages (if/id/ex/m registers)

- **18 Integration Tests** in `/projects/tests/`:
  - Each CPU test verifies one instruction type or category
  - Each element has dedicated unit tests in `/elements/tests/`

## Architecture

### Pipeline Flow
1. **Input**: Assembly programs in `/projects/programs/` 
2. **Assembly**: Convert to hex using `riscv-none-elf-as`
3. **Loading**: Load program into instruction memory (`imem`)
4. **Execution**: Execute on `/projects/src/cpu_single_cycle.v`
5. **Output**: Waveforms and test results for verification

### CPU Architecture Diagram
```
PC → [IMEM] → [Control Unit] ↓
     ↓                    [ALU] ↓
   [Registers] ← [Muxes] ← [DMEM]
                              ↑
                         [Branch Comp]
```

## Getting Started

### Quick Start

1. **Test All Components**:
   ```bash
   Build and Run All Elements
   ```
   This verifies each core component works correctly.

2. **Test All CPU Instructions**:
   ```bash
   Build and Run All CPU Tests
   ```
   This runs assembly programs for each instruction type.

3. **Create a Custom Test**:
   ```bash
   Generate new CPU test → [Enter test name]
   ```
   This generates boilerplate assembly program and testbench.

### Build System

The project uses VS Code tasks for automation:
- **Build all elements**: Compiles and runs unit tests for each module
- **Build single element**: Select element and testbench to compile
- **Build all CPU tests**: Assembles programs and runs full CPU tests
- **Build single CPU test**: Test individual instruction types

See `build_system.md` for detailed build commands.

## Directory Structure

```
elements/
  ├── inc/          # Include files with constants and definitions
  ├── src/          # Core CPU components (ALU, Control, Memory, etc.)
  └── tests/        # Unit tests for each component

projects/
  ├── programs/     # Assembly test programs (one per instruction type)
  ├── src/          # CPU implementations (single-cycle and pipelined)
  └── tests/        # Integration tests using assembly programs

scripts/
  ├── build_all.py           # Build all element tests
  ├── build_all_cpu_tests.py # Build all CPU integration tests
  ├── generate_element.py    # Template generator for new components
  └── generate_cpu_test.py   # Template generator for new tests

build/
  ├── hex/    # Assembled instruction binaries
  ├── obj/    # Object files
  ├── sim/    # Compiled simulation executables
  └── vcd/    # Waveform files (for debugging with gtkwave)

libraries/
  ├── constants.vh      # Instruction encodings and opcodes
  ├── inst_encode.vh    # Instruction format definitions
  └── regfile_access.vh # Register file utilities
```

## Testing Methodology

Each instruction is tested through:
1. **Unit Tests** (`/elements/tests/`): Component-level verification
2. **Integration Tests** (`/projects/tests/`): Full CPU execution
3. **Testbenches**: Written in SystemVerilog with assertion checks

Tests verify:
- Correct computation results
- Register and memory state changes
- Program counter updates (including jumps/branches)

## Tools & Dependencies

- **Simulator**: Icarus Verilog (`iverilog`)
- **VVP**: Runtime for Verilog simulations
- **Assembler**: RISC-V GNU Toolchain (`riscv-none-elf-as`)
- **Waveform Viewer**: GTKWave (optional, for debugging)

## Future Enhancements

- [ ] Pipeline implementation with hazard detection
- [ ] Branch prediction
- [ ] Cache simulation
- [ ] Additional RISC-V extensions (RV32M, RV32F)
- [ ] Load/store unit enhancements
- [ ] Performance metrics collection
- [ ] Interactive simulator UI