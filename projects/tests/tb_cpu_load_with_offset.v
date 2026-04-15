`include "mem.vh"
`timescale 1ns / 1ps

module tb_cpu_load_with_offset;
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
    $readmemh("build/hex/cpu_load_with_offset_program.hex", dut.u_imem.inst_mem, 0, `IMEM_SIZE - 1);
  end

  initial begin
`ifdef CPU_PIPELINED
    $dumpfile("build/vcd/projects/pipelined/tb_cpu_load_with_offset.vcd");
    $dumpvars(0, tb_cpu_load_with_offset);
`else
    $dumpfile("build/vcd/projects/single_cycle/tb_cpu_load_with_offset.vcd");
    $dumpvars(0, tb_cpu_load_with_offset);
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
    // Values stored at different offsets and loaded back
    // x3 = lw from offset 0 = 0x1111
    // x4 = lw from offset 4 = 0x2222
    // x5 = lw from offset 8 = 0x3333
    // x6 = lw from offset 12 = 0x4444
    // x7 = lhu from offset 0 = bits 15:0 of 0x1111 = 0x1111
    // x8 = lhu from offset 2 = bits 15:0 from higher address = 0x0000

    expect_32(32'd0, `REG_X0);  // x0 always 0
    expect_32(32'h111, `REG_X3);  // Load from offset 0
    expect_32(32'h222, `REG_X4);  // Load from offset 4
    expect_32(32'h333, `REG_X5);  // Load from offset 8
    expect_32(32'h444, `REG_X6);  // Load from offset 12
    expect_32(32'h111, `REG_X7);  // Half-word from offset 0
    expect_32(32'h111, `REG_X8);  // Half-word from offset 2

    $finish;
  end

endmodule
