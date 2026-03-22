`timescale 1ns / 1ps

module tb_id_reg;
  `include "expect.vh"

  reg clk;
  reg rst;
  reg [31:0] pc_plus4_in;
  reg [31:0] pc_in;
  reg [31:0] dataA_in;
  reg [31:0] dataB_in;
  reg [31:0] inst_in;
  wire [31:0] pc_plus4_out;
  wire [31:0] pc_out;
  wire [31:0] dataA_out;
  wire [31:0] dataB_out;
  wire [31:0] inst_out;

  id_reg uut (
      .clk(clk),
      .rst(rst),
      .pc_plus4_in(pc_plus4_in),
      .pc_in(pc_in),
      .dataA_in(dataA_in),
      .dataB_in(dataB_in),
      .inst_in(inst_in),
      .pc_plus4_out(pc_plus4_out),
      .pc_out(pc_out),
      .dataA_out(dataA_out),
      .dataB_out(dataB_out),
      .inst_out(inst_out)
  );

  initial begin
    $dumpfile("build/vcd/elements/id_reg_wave.vcd");
    $dumpvars(0, tb_id_reg);

    // Initialize
    rst = 0;
    clk = 0;
    pc_plus4_in = 32'd0;
    pc_in = 32'd0;
    dataA_in = 32'd0;
    dataB_in = 32'd0;
    inst_in = 32'd0;
    #1;
    clk = 1;
    #1;
    // After reset release, outputs should be 0
    expect_32(32'd0, pc_plus4_out);
    expect_32(32'd0, pc_out);
    expect_32(32'd0, dataA_out);
    expect_32(32'd0, dataB_out);
    expect_32(32'd0, inst_out);

    // Test 1: Write values and read on next clock
    clk = 0;
    pc_plus4_in = 32'd4;
    pc_in = 32'd0;
    dataA_in = 32'd42;
    dataB_in = 32'd58;
    inst_in = 32'h033;  // add instruction
    #1;
    // Values should not have updated yet
    expect_32(32'd0, pc_plus4_out);
    expect_32(32'd0, pc_out);
    expect_32(32'd0, dataA_out);
    expect_32(32'd0, dataB_out);
    expect_32(32'd0, inst_out);

    clk = 1;
    #1;
    // Now values should be latched
    expect_32(32'd4, pc_plus4_out);
    expect_32(32'd0, pc_out);
    expect_32(32'd42, dataA_out);
    expect_32(32'd58, dataB_out);
    expect_32(32'h033, inst_out);

    // Test 2: Write new values
    clk = 0;
    pc_plus4_in = 32'd8;
    pc_in = 32'd4;
    dataA_in = 32'hDEADBEEF;
    dataB_in = 32'hCAFEBABE;
    inst_in = 32'h3B;  // different instruction
    #1;
    // Old values should still be present
    expect_32(32'd4, pc_plus4_out);
    expect_32(32'd0, pc_out);
    expect_32(32'd42, dataA_out);
    expect_32(32'd58, dataB_out);
    expect_32(32'h033, inst_out);

    clk = 1;
    #1;
    // New values should be latched
    expect_32(32'd8, pc_plus4_out);
    expect_32(32'd4, pc_out);
    expect_32(32'hDEADBEEF, dataA_out);
    expect_32(32'hCAFEBABE, dataB_out);
    expect_32(32'h3B, inst_out);

    // Test 3: Reset functionality
    clk = 0;
    rst = 1;
    #1;
    // Output should not change until clock edge
    expect_32(32'd8, pc_plus4_out);
    expect_32(32'd4, pc_out);
    expect_32(32'hDEADBEEF, dataA_out);
    expect_32(32'hCAFEBABE, dataB_out);
    expect_32(32'h3B, inst_out);

    clk = 1;
    #1;
    // After reset on clock edge, all outputs should be 0
    expect_32(32'd0, pc_plus4_out);
    expect_32(32'd0, pc_out);
    expect_32(32'd0, dataA_out);
    expect_32(32'd0, dataB_out);
    expect_32(32'd0, inst_out);

    #10;
    $finish;
  end

endmodule
