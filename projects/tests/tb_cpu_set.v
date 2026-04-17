`include "mem.vh"
`timescale 1ns / 1ps

module tb_cpu_set;
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
    $readmemh("build/hex/cpu_set_program.hex", dut.u_imem.inst_mem, 0, `IMEM_SIZE - 1);
  end

  initial begin
`ifdef CPU_PIPELINED
    $dumpfile("build/vcd/projects/pipelined/tb_cpu_set.vcd");
    $dumpvars(0, tb_cpu_set);
`else
    $dumpfile("build/vcd/projects/single_cycle/tb_cpu_set.vcd");
    $dumpvars(0, tb_cpu_set);
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

    expect_32(32'd0, `REG_X0);
    expect_32(32'd1, `REG_X3);
    expect_32(32'd0, `REG_X4);
    expect_32(32'd0, `REG_X7);
    expect_32(32'd1, `REG_X8);

    $finish;
  end

endmodule
