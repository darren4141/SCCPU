`include "mem.vh"
`timescale 1ns / 1ps

module tb_cpu_branch_cmp;
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
    $readmemh("build/hex/cpu_branch_cmp_program.hex", dut.u_imem.inst_mem, 0, `IMEM_SIZE - 1);
  end

  initial begin
`ifdef CPU_PIPELINED
    $dumpfile("build/vcd/projects/pipelined/tb_cpu_branch_cmp.vcd");
    $dumpvars(0, tb_cpu_branch_cmp);
`else
    $dumpfile("build/vcd/projects/single_cycle/tb_cpu_branch_cmp.vcd");
    $dumpvars(0, tb_cpu_branch_cmp);
`endif

`ifdef CPU_PIPELINED
    $display("PIPELINED CPU TEST");
`else
    $display("SINGLE CYCLE CPU TEST");
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
    expect_32(32'd10, `REG_X1);  // x1 unchanged (branch taken)
    expect_32(32'd6, `REG_X3);  // x3 = 5 + 1 (branch not taken)
    expect_32(32'd19, `REG_X9);  // x9 = 9 + 10 (branch not taken)

    $finish;
  end

endmodule
