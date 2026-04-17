`include "mem.vh"
`timescale 1ns / 1ps

module tb_cpu_shift_imm;
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
    $readmemh("build/hex/cpu_shift_imm_program.hex", dut.u_imem.inst_mem, 0, `IMEM_SIZE - 1);
  end

  initial begin
`ifdef CPU_PIPELINED
    $dumpfile("build/vcd/projects/pipelined/tb_cpu_shift_imm.vcd");
    $dumpvars(0, tb_cpu_shift_imm);
`else
    $dumpfile("build/vcd/projects/single_cycle/tb_cpu_shift_imm.vcd");
    $dumpvars(0, tb_cpu_shift_imm);
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
