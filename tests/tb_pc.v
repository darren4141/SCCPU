`timescale 1ns / 1ps

module tb_pc;
  `include "expect.vh"

  reg rst;
  reg clk;
  reg [31:0] in;
  wire [31:0] out;

  pc uut (
      .rst(rst),
      .clk(clk),
      .in (in),
      .out(out)
  );

  initial begin
    $dumpfile("build/vcd/pc_wave.vcd");
    $dumpvars(0, tb_pc);

    rst = 0;
    clk = 0;
    in  = 0;
    #1;
    clk = 1;
    #1;
    expect_32(0, out);

    clk = 0;
    in  = 4;
    #1;
    expect_32(0, out);

    clk = 1;
    #1;
    expect_32(4, out);

    clk = 0;
    in  = 8;
    #1;
    expect_32(4, out);

    clk = 1;
    #1;
    expect_32(8, out);

    clk = 0;
    rst = 1;
    #1;
    expect_32(8, out);

    clk = 1;
    #1;
    expect_32(0, out);

    #10;
    $finish;
  end

endmodule
