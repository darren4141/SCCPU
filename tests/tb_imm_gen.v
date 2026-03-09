`include "imm_gen.vh"
`include "constants.vh"

`timescale 1ns / 1ps

module tb_imm_gen;
  `include "inst_encode.vh"
  `include "expect.vh"

  reg  [31:0] inst;
  reg  [ 2:0] ImmSel;
  wire [31:0] imm;

  imm_gen uut (
      .inst(inst),
      .ImmSel(ImmSel),
      .imm(imm)
  );

  initial begin
    $dumpfile("build/vcd/imm_gen_wave.vcd");
    $dumpvars(0, tb_imm_gen);
    #10;

    inst   = enc_r(7'b0, 5'd5, 5'd6, 3'b0, 5'd7, `OPCODE_ARITH_OP);
    ImmSel = `FORMAT_R;
    #1;
    expect_32(32'b0, imm);
    #10;

    inst   = enc_i(12'd10, 5'd6, 3'b0, 5'd7, `OPCODE_ARITH_OP_IMM);
    ImmSel = `FORMAT_I;
    #1;
    expect_32(12'd10, imm);
    #10;

    inst   = enc_i(-12'd10, 5'd6, 3'b0, 5'd7, `OPCODE_ARITH_OP_IMM);
    ImmSel = `FORMAT_I;
    #1;
    expect_32(-12'd10, imm);
    #10;

    inst   = enc_s(12'd14, 5'd5, 5'd6, 3'b0, `OPCODE_STORE);
    ImmSel = `FORMAT_S;
    #1;
    expect_32(12'd14, imm);
    #10;

    inst   = enc_s(-12'd14, 5'd5, 5'd6, 3'b0, `OPCODE_STORE);
    ImmSel = `FORMAT_S;
    #1;
    expect_32(-12'd14, imm);
    #10;

    inst   = enc_b(12'd16, 5'd5, 5'd6, 3'b0, `OPCODE_BRANCH);
    ImmSel = `FORMAT_B;
    #1;
    expect_32(12'd16, imm);
    #10;

    inst   = enc_b(-12'd16, 5'd5, 5'd6, 3'b0, `OPCODE_BRANCH);
    ImmSel = `FORMAT_B;
    #1;
    expect_32(-12'd16, imm);
    #10;

    inst   = enc_u(32'hDEADBEEF, 5'd5, `OPCODE_LUI);
    ImmSel = `FORMAT_U;
    #1;
    expect_32(32'hDEADB000, imm);
    #10;

    inst   = enc_u(32'hFACE, 5'd5, `OPCODE_LUI);
    ImmSel = `FORMAT_U;
    #1;
    expect_32(32'hF000, imm);
    #10;

    inst   = enc_u(32'h0ACE, 5'd5, `OPCODE_AUIPC);
    ImmSel = `FORMAT_U;
    #1;
    expect_32(32'h0000, imm);
    #10;

    inst   = enc_j(20'hFFFE, 5'd5, `OPCODE_JAL);
    ImmSel = `FORMAT_J;
    #5;
    expect_32(20'hFFFE, imm);
    #10;

    // Bit 0 in J-format instructions is always ignored
    inst   = enc_j(20'hFFFF, 5'd5, `OPCODE_JAL);
    ImmSel = `FORMAT_J;
    #5;
    expect_32(20'hFFFE, imm);
    #10;

    // JALR is I-format and only accepts up to 12-bit immediates
    inst   = enc_j(20'hFFFF, 5'd5, `OPCODE_JALR);
    ImmSel = `FORMAT_I;
    #5;
    expect_32(12'h7FF, imm);
    #10;

    $finish;
  end

endmodule
