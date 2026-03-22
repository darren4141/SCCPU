`timescale 1ns / 1ps

module tb_m_reg;
  `include "expect.vh"

  reg clk;
  reg rst;
  reg [31:0] pc_plus4_in;
  reg [31:0] alu_in;
  reg [31:0] dataR_in;
  reg [31:0] inst_in;
  wire [31:0] pc_plus4_out;
  wire [31:0] alu_out;
  wire [31:0] dataR_out;
  wire [31:0] inst_out;

  m_reg uut (
      .clk(clk),
      .rst(rst),
      .pc_plus4_in(pc_plus4_in),
      .alu_in(alu_in),
      .dataR_in(dataR_in),
      .inst_in(inst_in),
      .pc_plus4_out(pc_plus4_out),
      .alu_out(alu_out),
      .dataR_out(dataR_out),
      .inst_out(inst_out)
  );

  initial begin
    $dumpfile("build/vcd/elements/m_reg_wave.vcd");
    $dumpvars(0, tb_m_reg);

    // Initialize
    rst = 0;
    clk = 0;
    pc_plus4_in = 32'd0;
    alu_in = 32'd0;
    dataR_in = 32'd0;
    inst_in = 32'd0;
    #1;
    clk = 1;
    #1;
    // After reset release, outputs should be 0
    expect_32(32'd0, pc_plus4_out);
    expect_32(32'd0, alu_out);
    expect_32(32'd0, dataR_out);
    expect_32(32'd0, inst_out);

    // Test 1: Write values and read on next clock
    clk = 0;
    pc_plus4_in = 32'd4;
    alu_in = 32'h11111111;
    dataR_in = 32'h22222222;
    inst_in = 32'h0000003B;  // add instruction
    #1;
    // Values should not have updated yet
    expect_32(32'd0, pc_plus4_out);
    expect_32(32'd0, alu_out);
    expect_32(32'd0, dataR_out);
    expect_32(32'd0, inst_out);

    clk = 1;
    #1;
    // Now values should be latched
    expect_32(32'd4, pc_plus4_out);
    expect_32(32'h11111111, alu_out);
    expect_32(32'h22222222, dataR_out);
    expect_32(32'h0000003B, inst_out);

    // Test 2: Write new values
    clk = 0;
    pc_plus4_in = 32'd8;
    alu_in = 32'hFFFFFFFF;
    dataR_in = 32'h00000000;
    inst_in = 32'h00000023;  // store instruction
    #1;
    // Old values should still be present
    expect_32(32'd4, pc_plus4_out);
    expect_32(32'h11111111, alu_out);
    expect_32(32'h22222222, dataR_out);
    expect_32(32'h0000003B, inst_out);

    clk = 1;
    #1;
    // New values should be latched
    expect_32(32'd8, pc_plus4_out);
    expect_32(32'hFFFFFFFF, alu_out);
    expect_32(32'h00000000, dataR_out);
    expect_32(32'h00000023, inst_out);

    // Test 3: Reset functionality
    clk = 0;
    rst = 1;
    #1;
    // Output should not change until clock edge
    expect_32(32'd8, pc_plus4_out);
    expect_32(32'hFFFFFFFF, alu_out);
    expect_32(32'h00000000, dataR_out);
    expect_32(32'h00000023, inst_out);

    clk = 1;
    #1;
    // After reset on clock edge, all outputs should be 0
    expect_32(32'd0, pc_plus4_out);
    expect_32(32'd0, alu_out);
    expect_32(32'd0, dataR_out);
    expect_32(32'd0, inst_out);

    #10;
    $finish;
  end

endmodule
