`timescale 1ns / 1ps

module tb_regfile;
  `include "expect.vh"

  reg clk;
  reg we;

  reg [4:0] addrA;
  reg [4:0] addrB;
  reg [4:0] addrD;

  reg [31:0] dataD;
  wire [31:0] dataA;
  wire [31:0] dataB;

  regfile uut (
      .clk(clk),
      .we(we),
      .addrA(addrA),
      .addrB(addrB),
      .addrD(addrD),
      .dataD(dataD),
      .dataA(dataA),
      .dataB(dataB)
  );

  initial begin
    $dumpfile("build/vcd/elements/regfile_wave.vcd");
    $dumpvars(0, tb_regfile);

    clk = 0;
    #10;

    addrA = 5'd5;
    addrB = 5'd6;

    // Write to rd = x7
    addrD = 5'd7;
    dataD = 32'hDEADBEEF;
    we = 1;
    #1;

    // addrA = x5 so dataA should be zero
    expect_32(32'b0, dataA);

    // addrA = x7 but clock hasnt risen yet so dataA should still be zero
    addrA = 5'd7;
    #1;
    expect_32(32'b0, dataA);

    // addrA = x7, clock edge has risen so we should see the data now
    clk = 1;
    #1;
    expect_32(32'hDEADBEEF, dataA);

    // Read from addrB should work as well
    addrB = 5'd7;
    #1;
    expect_32(32'hDEADBEEF, dataB);

    // Attempt to write with we = 0, expect no change
    clk = 0;
    we = 0;
    addrA = 5'd7;
    addrD = 5'd7;
    dataD = 32'hFFFFFFFF;
    #1;
    expect_32(32'hDEADBEEF, dataA);
    #1;
    clk = 1;
    #1 expect_32(32'hDEADBEEF, dataA);

    // Attempt to write to reg x0, expect 0
    clk = 0;
    we = 0;
    addrA = 5'd0;
    addrD = 5'd0;
    dataD = 32'hCCCCCCCC;
    #1;
    expect_32(32'b0, dataA);
    #1;
    clk = 1;
    #1 expect_32(32'b0, dataA);

    $finish;
  end

endmodule
