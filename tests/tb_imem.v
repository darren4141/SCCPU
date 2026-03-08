`timescale 1ns / 1ps

module tb_imem;
  `include "expect.vh"

  reg  [31:0] addr;
  wire [31:0] inst;

  imem uut (
      .addr(addr),
      .inst(inst)
  );

  initial begin
    $dumpfile("build/vcd/imem_wave.vcd");
    $dumpvars(0, tb_imem);

    #10;

    addr = 32'd0;
    #1;
    expect_32(32'h00500093, inst);
    #1;

    addr = 32'd4;
    #1;
    expect_32(32'h00308113, inst);
    #1;

    addr = 32'd8;
    #1;
    expect_32(32'h002081b3, inst);
    #1;

    addr = 32'd0;
    #1;
    expect_32(32'h00500093, inst);
    #1 $finish;
  end

endmodule
