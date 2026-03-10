`timescale 1ns / 1ps

module tb_dmem;
  `include "expect.vh"

  reg clk;
  reg dwe;
  reg [31:0] addr;
  reg [31:0] dataW;
  reg [31:0] dataR;

  dmem uut (
      .clk  (clk),
      .dwe  (dwe),
      .addr (addr),
      .dataW(dataW),
      .dataR(dataR)
  );

  initial begin
    $dumpfile("build/vcd/elements/dmem_wave.vcd");
    $dumpvars(0, tb_dmem);

    #10;

    // Write values to 0, 4, 8 - writes only occur on rising edge
    clk   = 0;
    dwe   = 1;
    addr  = 0;
    dataW = 32'h00500093;
    #1;
    clk = 1;
    #1;

    clk   = 0;
    addr  = 4;
    dataW = 32'h00308113;
    #1;
    clk = 1;
    #1;

    clk   = 0;
    addr  = 8;
    dataW = 32'h002081b3;
    #1;
    clk = 1;
    #1;

    // Read values from 0, 4, 8, 0

    clk  = 0;
    dwe  = 0;
    addr = 0;
    #1;
    expect_32(dataR, 32'h00500093);
    #1;

    addr = 4;
    #1;
    expect_32(dataR, 32'h00308113);
    #1;

    addr = 8;
    #1;
    expect_32(dataR, 32'h002081b3);
    #1;

    addr = 0;
    #1;
    expect_32(dataR, 32'h00500093);
    #1;


    // Re-write & read
    clk   = 0;
    dwe   = 1;
    addr  = 8;

    dataW = 32'hDEADBEEF;
    #1;
    clk = 1;
    #1;

    clk  = 0;
    addr = 8;
    dwe  = 0;
    #1;
    expect_32(dataR, 32'hDEADBEEF);
    #1;

    // Write with wen = 0, expect no change

    clk   = 0;
    dwe   = 0;
    addr  = 8;

    dataW = 32'hCCCCCCCC;
    #1;
    clk = 1;
    #1;

    clk  = 0;
    addr = 8;
    dwe  = 0;
    #1;
    expect_32(dataR, 32'hDEADBEEF);
    #1;

    // Write with no clock edge, expect no change

    clk   = 0;
    dwe   = 1;
    addr  = 8;

    dataW = 32'hCCCCCCCC;
    #1;
    clk  = 0;
    addr = 8;
    dwe  = 0;
    #1;
    expect_32(dataR, 32'hDEADBEEF);
    #1;

    $finish;
  end

endmodule
