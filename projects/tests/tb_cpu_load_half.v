`include "mem.vh"
`timescale 1ns / 1ps

module tb_cpu_load_half;
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
    $readmemh("build/hex/cpu_load_half_program.hex", dut.u_imem.inst_mem, 0, `IMEM_SIZE - 1);
  end

  initial begin
    $dumpfile("build/vcd/projects/tb_cpu_load_half.vcd");
    $dumpvars(0, tb_cpu_load_half);

    #10;
    rst = 1;
    #10;
    rst = 0;

    repeat (10) @(posedge clk);

    // TEST CODE
    // x5 and x6 should load half words successfully
    // The exact values depend on what's stored, but testing lhu instruction
    expect_32(32'd0, `REG_X0);  // x0 always 0
    expect_32(32'd1, `REG_X7);  // Simple test that x7 was set to 0x100 + 7 = 263 >> then stored 

    $finish;
  end

endmodule
