# scripts/generate_project_test.py
from pathlib import Path
import sys

if len(sys.argv) < 2:
    print("Usage: python scripts/generate_project_test.py <test name>")
    sys.exit(1)

name = sys.argv[1]

files = {
    Path(f"projects/tests/tb_cpu_{name}.v"): 
f"""`include "mem.vh"
`timescale 1ns / 1ps

module tb_cpu_{name};
  `include "expect.vh"

  reg clk;
  reg rst;

  cpu_single_cycle dut (
      .clk(clk),
      .rst(rst)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $readmemh("build/hex/cpu_{name}_program.hex", dut.u_imem.inst_mem, 0, `IMEM_SIZE - 1);
  end

  initial begin
    $dumpfile("build/vcd/projects/tb_cpu_{name}.vcd");
    $dumpvars(0, tb_bcomp);

    #10;
    rst = 1;
    #10;
    rst = 0;

    repeat (10) @(posedge clk);
    
    $finish;
  end

endmodule
""",
    Path(f"projects/programs/cpu_{name}_program.s"): f"""
    
"""
}

for path, content in files.items():
    if path.exists():
        print(f"Error: {path} already exists")
        sys.exit(1)

for path, content in files.items():
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content)

print(f"Generated files for {name}")