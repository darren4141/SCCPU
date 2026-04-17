`include "mem.vh"
`timescale 1ns / 1ps

module tb_cpu_arith_imm;
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
    $readmemh("build/hex/cpu_arith_imm_program.hex", dut.u_imem.inst_mem, 0, `IMEM_SIZE - 1);
  end

  initial begin
`ifdef CPU_PIPELINED
    $dumpfile("build/vcd/projects/pipelined/tb_cpu_arith_imm.vcd");
    $dumpvars(0, tb_cpu_arith_imm);
`else
    $dumpfile("build/vcd/projects/single_cycle/tb_cpu_arith_imm.vcd");
    $dumpvars(0, tb_cpu_arith_imm);
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
    // x2 = x1 & 0xAA = 0xF0 & 0xAA = 0xA0 = 160
    expect_32(32'd160, `REG_X2);
    // x4 = x3 | 0x1C = 0xE3 | 0x1C = 0xFF = 255
    expect_32(32'd255, `REG_X4);
    // x6 = x5 ^ 0xF0 = 0xAA ^ 0xF0 = 0x5A = 90
    expect_32(32'd90, `REG_X6);
    // x8 = x7 & 0xFF = 0 & 0xFF = 0
    expect_32(32'd0, `REG_X8);
    // x9 = x7 | 0xAA = 0 | 0xAA = 170
    expect_32(32'd170, `REG_X9);
    // x10 = x9 ^ 0x55 = 0xAA ^ 0x55 = 0xFF = 255
    expect_32(32'd255, `REG_X10);

    $finish;
  end

endmodule
