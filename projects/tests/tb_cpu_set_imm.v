`include "mem.vh"
`timescale 1ns / 1ps

module tb_cpu_set_imm;
  `include "expect.vh"
  `include "regfile_access.vh"

  reg clk;
  reg rst;

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
    $readmemh("build/hex/cpu_set_imm_program.hex", dut.u_imem.inst_mem, 0, `IMEM_SIZE - 1);
  end

  initial begin
`ifdef CPU_PIPELINED
    $dumpfile("build/vcd/projects/pipelined/tb_cpu_set_imm.vcd");
    $dumpvars(0, tb_cpu_set_imm);
`else
    $dumpfile("build/vcd/projects/single_cycle/tb_cpu_set_imm.vcd");
    $dumpvars(0, tb_cpu_set_imm);
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

    repeat (20) @(posedge clk);

    // TEST CODE
    // x2 = slti: 5 < 10 = true = 1
    expect_32(32'd1, `REG_X2);
    // x4 = slti: 15 < 10 = false = 0
    expect_32(32'd0, `REG_X4);
    // x6 = slti: -5 < 0 = true = 1
    expect_32(32'd1, `REG_X6);
    // x8 = sltiu: 10 < 5 (unsigned) = false = 0
    expect_32(32'd0, `REG_X8);
    // x10 = sltiu: 3 < 8 (unsigned) = true = 1
    expect_32(32'd1, `REG_X10);
    // x12 = sltiu: -1 (unsigned) < 100 = false = 0
    expect_32(32'd0, `REG_X12);

    $finish;
  end

endmodule
