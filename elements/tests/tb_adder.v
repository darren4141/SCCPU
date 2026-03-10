`timescale 1ns / 1ps

module tb_adder;
  `include "expect.vh"

  reg  [31:0] a;
  reg  [31:0] b;
  wire [31:0] sum;

  adder uut (
      .a  (a),
      .b  (b),
      .sum(sum)
  );

  initial begin
    $dumpfile("build/vcd/elements/adder_wave.vcd");
    $dumpvars(0, tb_adder);

    a = 5;
    b = 3;
    #10;
    expect_32(8, sum);

    a = 10;
    b = 7;
    #10;
    expect_32(17, sum);

    $finish;
  end

endmodule
