`timescale 1ns / 1ps

module tb_stalling;
  `include "expect.vh"

stalling uut ();

  initial begin
    $dumpfile("build/vcd/elements/stalling_wave.vcd");
    $dumpvars(0, tb_stalling);

    #10;
    $finish;
  end

endmodule
