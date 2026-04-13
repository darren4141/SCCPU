`include "mem.vh"
`timescale 1ns / 1ps

module tb_cpu_sub;
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
    $readmemh("build/hex/cpu_sub_program.hex", dut.u_imem.inst_mem, 0, `IMEM_SIZE - 1);
  end

  initial begin
    $dumpfile("build/vcd/projects/tb_cpu_sub.vcd");
    $dumpvars(0, tb_cpu_sub);

`ifdef CPU_PIPELINED
    $display("PIPELINED CPU TEST");
`else
    $display("SINGLE CYCLE CPU TEST");
`endif

    #10;
    rst = 1;
    #10;
    rst = 0;

    repeat (50) @(posedge clk);

    // TEST CODE
    // x3 = 10 - 3 = 7
    expect_32(32'd7, `REG_X3);
    // x6 = 5 - 8 = -3
    expect_32(-32'd3, `REG_X6);
    // x9 = -7 - 3 = -10
    expect_32(-32'd10, `REG_X9);

    $finish;
  end

endmodule
