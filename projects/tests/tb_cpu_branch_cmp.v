`include "mem.vh"
`timescale 1ns / 1ps

module tb_cpu_branch_cmp;
  `include "expect.vh"
  `include "regfile_access.vh"

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
    $readmemh("build/hex/cpu_branch_cmp_program.hex", dut.u_imem.inst_mem, 0, `IMEM_SIZE - 1);
  end

  initial begin
    $dumpfile("build/vcd/projects/tb_cpu_branch_cmp.vcd");
    $dumpvars(0, tb_cpu_branch_cmp);

    #10;
    rst = 1;
    #10;
    rst = 0;

    repeat (20) @(posedge clk);

    // TEST CODE
    expect_32(32'd10, `REG_X1);  // x1 unchanged (branch taken)
    expect_32(32'd6, `REG_X3);  // x3 = 5 + 1 (branch not taken)
    expect_32(32'd19, `REG_X9);  // x9 = 9 + 10 (branch not taken)

    $finish;
  end

endmodule
