`timescale 1ns / 1ps

`include "mem.vh"

module tb_dmem;
  `include "expect.vh"

  reg clk;
  reg dwe;
  reg [2:0] size;
  reg [31:0] addr;
  reg [31:0] dataW;
  wire [31:0] dataR;

  dmem uut (
      .clk  (clk),
      .dwe  (dwe),
      .size (size),
      .addr (addr),
      .dataW(dataW),
      .dataR(dataR)
  );

  initial begin
    $dumpfile("build/vcd/elements/dmem_wave.vcd");
    $dumpvars(0, tb_dmem);

    clk   = 0;
    dwe   = 0;
    size  = `DMEM_TYPE_W;
    addr  = 32'b0;
    dataW = 32'b0;

    #10;

    // ----------------------------------------------------------------
    // WORD WRITE / READ
    // ----------------------------------------------------------------
    clk   = 0;
    dwe   = 1;
    size  = `DMEM_TYPE_W;
    addr  = 32'd0;
    dataW = 32'h1234ABCD;
    #1;
    clk = 1;
    #1;

    clk  = 0;
    dwe  = 0;
    size = `DMEM_TYPE_W;
    addr = 32'd0;
    #1;
    expect_32(dataR, 32'h1234ABCD);
    #1;

    // ----------------------------------------------------------------
    // BYTE READS from 0x1234ABCD
    // LB/LBU will read 0xCD from this word.
    // ----------------------------------------------------------------
    size = `DMEM_TYPE_B;
    #1;
    expect_32(dataR, 32'hFFFFFFCD);
    #1;

    size = `DMEM_TYPE_BU;
    #1;
    expect_32(dataR, 32'h000000CD);
    #1;

    // ----------------------------------------------------------------
    // HALFWORD READS from 0x1234ABCD
    // LH/LHU will read 0xABCD from this word.
    // ----------------------------------------------------------------
    size = `DMEM_TYPE_H;
    #1;
    expect_32(dataR, 32'hFFFFABCD);
    #1;

    size = `DMEM_TYPE_HU;
    #1;
    expect_32(dataR, 32'h0000ABCD);
    #1;

    size = `DMEM_TYPE_W;
    #1;
    expect_32(dataR, 32'h1234ABCD);
    #1;

    // ----------------------------------------------------------------
    // BYTE WRITE
    // ----------------------------------------------------------------
    clk   = 0;
    dwe   = 1;
    size  = `DMEM_TYPE_W;
    addr  = 32'd4;
    dataW = 32'hAABBCCDD;
    #1;
    clk = 1;
    #1;

    clk   = 0;
    dwe   = 1;
    size  = `DMEM_TYPE_B;
    addr  = 32'd4;
    dataW = 32'h000000EF;
    #1;
    clk = 1;
    #1;

    clk  = 0;
    dwe  = 0;
    size = `DMEM_TYPE_W;
    addr = 32'd4;
    #1;
    expect_32(dataR, 32'hAABBCCEF);
    #1;

    size = `DMEM_TYPE_B;
    #1;
    expect_32(dataR, 32'hFFFFFFEF);
    #1;

    size = `DMEM_TYPE_BU;
    #1;
    expect_32(dataR, 32'h000000EF);
    #1;

    // ----------------------------------------------------------------
    // HALFWORD WRITE
    // ----------------------------------------------------------------
    clk   = 0;
    dwe   = 1;
    size  = `DMEM_TYPE_W;
    addr  = 32'd8;
    dataW = 32'h11223344;
    #1;
    clk = 1;
    #1;

    clk   = 0;
    dwe   = 1;
    size  = `DMEM_TYPE_H;
    addr  = 32'd8;
    dataW = 32'h0000BEEF;
    #1;
    clk = 1;
    #1;

    clk  = 0;
    dwe  = 0;
    size = `DMEM_TYPE_W;
    addr = 32'd8;
    #1;
    expect_32(dataR, 32'h1122BEEF);
    #1;

    size = `DMEM_TYPE_H;
    #1;
    expect_32(dataR, 32'hFFFFBEEF);
    #1;

    size = `DMEM_TYPE_HU;
    #1;
    expect_32(dataR, 32'h0000BEEF);
    #1;

    // ----------------------------------------------------------------
    // FULL WORD OVERWRITE
    // ----------------------------------------------------------------
    clk   = 0;
    dwe   = 1;
    size  = `DMEM_TYPE_W;
    addr  = 32'd8;
    dataW = 32'hDEADBEEF;
    #1;
    clk = 1;
    #1;

    clk  = 0;
    dwe  = 0;
    size = `DMEM_TYPE_W;
    addr = 32'd8;
    #1;
    expect_32(dataR, 32'hDEADBEEF);
    #1;

    size = `DMEM_TYPE_B;
    #1;
    expect_32(dataR, 32'hFFFFFFEF);
    #1;

    size = `DMEM_TYPE_BU;
    #1;
    expect_32(dataR, 32'h000000EF);
    #1;

    size = `DMEM_TYPE_H;
    #1;
    expect_32(dataR, 32'hFFFFBEEF);
    #1;

    size = `DMEM_TYPE_HU;
    #1;
    expect_32(dataR, 32'h0000BEEF);
    #1;

    // ----------------------------------------------------------------
    // WRITE WITH dwe = 0 -> expect no change
    // ----------------------------------------------------------------
    clk   = 0;
    dwe   = 0;
    size  = `DMEM_TYPE_W;
    addr  = 32'd8;
    dataW = 32'hCCCCCCCC;
    #1;
    clk = 1;
    #1;

    clk  = 0;
    dwe  = 0;
    size = `DMEM_TYPE_W;
    addr = 32'd8;
    #1;
    expect_32(dataR, 32'hDEADBEEF);
    #1;

    // ----------------------------------------------------------------
    // WRITE WITH NO RISING EDGE -> expect no change
    // ----------------------------------------------------------------
    clk   = 0;
    dwe   = 1;
    size  = `DMEM_TYPE_W;
    addr  = 32'd8;
    dataW = 32'hAAAAAAAA;
    #1;

    clk  = 0;  // no posedge
    dwe  = 0;
    size = `DMEM_TYPE_W;
    addr = 32'd8;
    #1;
    expect_32(dataR, 32'hDEADBEEF);
    #1;

    $finish;
  end

endmodule
