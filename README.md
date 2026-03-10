# Single Cycle CPU in Verilog

## Pipeline:
- Takes an assembly program in `/projects/programs/` 
- Converts to hex using `riscv-none-elf-as`
- Loads program to `imem`
- Runs on `/projects/src/cpu_single_cycle.v` using elements in `/elements`

## To use:

- Run task `Build and Run All Elements` to test each element individually
- Create an assembly program and corresponding test using `Generate new CPU test`
- Run all existing assembly program tests using `Build and Run All CPU Tests`