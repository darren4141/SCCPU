`include "mem.vh"
`timescale 1ns / 1ps

module tb_cpu_set;
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
    $readmemh("build/hex/cpu_set_program.hex", dut.u_imem.inst_mem, 0, `IMEM_SIZE - 1);
  end

  initial begin
    $dumpfile("build/vcd/projects/tb_cpu_set.vcd");
    $dumpvars(0, tb_cpu_set);

    #10;
    rst = 1;
    #10;
    rst = 0;

    repeat (10) @(posedge clk);

    // TEST CODE

    expect_32(32'd0, `REG_X0);
    expect_32(32'd1, `REG_X3);
    expect_32(32'd0, `REG_X4);
    expect_32(32'd0, `REG_X7);
    expect_32(32'd1, `REG_X8);

    $finish;
  end

endmodule
