`include "mem.vh"
`timescale 1ns / 1ps

module tb_cpu_shift_imm;
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
    $readmemh("build/hex/cpu_shift_imm_program.hex", dut.u_imem.inst_mem, 0, `IMEM_SIZE - 1);
  end

  initial begin
    $dumpfile("build/vcd/projects/tb_cpu_shift_imm.vcd");
    $dumpvars(0, tb_cpu_shift_imm);

    #10;
    rst = 1;
    #10;
    rst = 0;

    repeat (20) @(posedge clk);

    // TEST CODE
    // x2 = x1 << 1 = 7 << 1 = 14
    expect_32(32'd14, `REG_X2);
    // x4 = x3 >> 2 = 16 >> 2 = 4
    expect_32(32'd4, `REG_X4);
    // x6 = x5 >> 3 (arithmetic) = 32 >> 3 = 4
    expect_32(32'd4, `REG_X6);
    // x8 = x7 >> 2 (arithmetic) = -16 >> 2 = -4 (0xFFFFFFFC)
    expect_32(32'hFFFFFFFC, `REG_X8);
    // x10 = x9 << 5 = 3 << 5 = 96
    expect_32(32'd96, `REG_X10);

    $finish;
  end

endmodule
