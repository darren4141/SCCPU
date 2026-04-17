# scripts/generate_cpu_test.py
from pathlib import Path
import sys

if len(sys.argv) < 2:
    print("Usage: python scripts/generate_cpu_test.py <test name>")
    sys.exit(1)

name = sys.argv[1]

files = {
    Path(f"projects/tests/tb_cpu_{name}.v"): 
f"""`include "mem.vh"
`timescale 1ns / 1ps

module tb_cpu_{name};
  `include "expect.vh"
  `include "regfile_access.vh"

  reg clk;
  reg rst;
  integer i;

  `ifdef CPU_PIPELINED
    cpu_pipelined dut (
        .clk(clk),
        .rst(rst)
    );
  `else
    cpu_single_cycle dut (
        .clk(clk),
        .rst(rst)
    );
  `endif

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $readmemh("build/hex/cpu_{name}_program.hex", dut.u_imem.inst_mem, 0, `IMEM_SIZE - 1);
  end

  initial begin
`ifdef CPU_PIPELINED
    $dumpfile("build/vcd/projects/pipelined/tb_cpu_{name}.vcd");
    $dumpvars(0, tb_cpu_{name});
`else
    $dumpfile("build/vcd/projects/single_cycle/tb_cpu_{name}.vcd");
    $dumpvars(0, tb_cpu_{name});
`endif

    #10;
    rst = 1;
    #10;
    rst = 0;

    for (i = 1; i < 50; i = i + 1) begin
      repeat (1) @(posedge clk);
      // Add debugging messages here...
    end
    
    // TEST CODE

    expect_32(32'd0, `REG_X0);

    $finish;
  end

endmodule
""",
    Path(f"projects/programs/cpu_{name}_program.s"): """"""
}

for path, content in files.items():
    if path.exists():
        print(f"Error: {path} already exists")
        sys.exit(1)

for path, content in files.items():
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content)

print(f"Generated files for {name}")