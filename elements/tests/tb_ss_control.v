`timescale 1ns / 1ps

module tb_ss_control;
  `include "expect.vh"

  reg [8:0] inst;
  reg brEQ;
  reg brLT;
  wire [17:0] control;

  ss_control uut (
      .inst(inst),
      .brEQ(brEQ),
      .brLT(brLT),
      .control(control)
  );

  initial begin
    $dumpfile("build/vcd/elements/ss_control_wave.vcd");
    $dumpvars(0, tb_ss_control);

    #10;
    $finish;
  end

endmodule
