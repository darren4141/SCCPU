`timescale 1ns / 1ps

module tb_flush;
  `include "expect.vh"

flush uut ();

  initial begin
    $dumpfile("build/vcd/elements/flush_wave.vcd");
    $dumpvars(0, tb_flush);

    #10;
    $finish;
  end

endmodule

