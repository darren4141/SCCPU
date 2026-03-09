`timescale 1ns / 1ps

module tb_control;
  `include "expect.vh"

  reg [8:0] inst;
  reg brEQ;
  reg brLT;
  wire [13:0] control;

  control uut (
      .inst(inst),
      .brEQ(brEQ),
      .brLT(brLT),
      .control(control)
  );

  initial begin
    $dumpfile("build/vcd/control_wave.vcd");
    $dumpvars(0, tb_control);

    #10;
    $finish;
  end

endmodule
