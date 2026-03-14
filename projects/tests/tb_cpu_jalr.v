`include "mem.vh"
`timescale 1ns / 1ps

module tb_cpu_jalr;
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
    $readmemh("build/hex/cpu_jalr_program.hex", dut.u_imem.inst_mem, 0, `IMEM_SIZE - 1);
  end

  initial begin
    $dumpfile("build/vcd/projects/tb_cpu_jalr.vcd");
    $dumpvars(0, tb_cpu_jalr);

    #10;
    rst = 1;
    #10;
    rst = 0;

    repeat (10) @(posedge clk);

    // TEST CODE

    expect_32(32'd0, `REG_X0);
    expect_32(32'd1, `REG_X1);
    expect_32(32'd9, `REG_X2);
    expect_32(32'd16, `REG_X6);

    $finish;
  end

endmodule
