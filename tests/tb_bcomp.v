`timescale 1ns / 1ps

module tb_bcomp;
  `include "expect.vh"

  reg [31:0] dataA;
  reg [31:0] dataB;
  reg brUN;
  reg brEQ;
  reg brLT;

  bcomp uut (
      .dataA(dataA),
      .dataB(dataB),
      .brUN (brUN),
      .brEQ (brEQ),
      .brLT (brLT)
  );

  initial begin
    $dumpfile("build/vcd/bcomp_wave.vcd");
    $dumpvars(0, tb_bcomp);

    #10;

    dataA = 32'd5;
    dataB = 32'd6;
    brUN  = 1;
    #1;
    expect_1(1, brLT);
    expect_1(0, brEQ);

    dataA = 32'd5;
    dataB = 32'd5;
    brUN  = 1;
    #1;
    expect_1(0, brLT);
    expect_1(1, brEQ);

    dataA = 32'd6;
    dataB = 32'd5;
    brUN  = 1;
    #1;
    expect_1(0, brLT);
    expect_1(0, brEQ);

    dataA = -32'd6;
    dataB = -32'd5;
    brUN  = 0;
    #1;
    expect_1(1, brLT);
    expect_1(0, brEQ);

    dataA = -32'd6;
    dataB = -32'd6;
    brUN  = 0;
    #1;
    expect_1(0, brLT);
    expect_1(1, brEQ);

    dataA = -32'd5;
    dataB = -32'd6;
    brUN  = 0;
    #1;
    expect_1(0, brLT);
    expect_1(0, brEQ);

    // We have signed numbers being treated as unsigned
    // -5 = 0xFFFFFFFB
    // -6 = 0xFFFFFFFA
    // So brLT should equal zero
    dataA = -32'd5;
    dataB = -32'd6;
    brUN  = 1;
    #1;
    expect_1(0, brLT);
    expect_1(0, brEQ);

    $finish;
  end

endmodule
