`include "control_defs.vh"
`include "imm_gen.vh"
`include "mem.vh"
`include "alu_defs.vh"
`include "constants.vh"

`timescale 1ns / 1ps

module tb_control;
  `include "expect.vh"

  reg [8:0] inst;
  reg brEQ;
  reg brLT;
  wire [17:0] control;

  control uut (
      .inst(inst),
      .brEQ(brEQ),
      .brLT(brLT),
      .control(control)
  );

  function [8:0] make_inst(input [6:0] funct7, input [2:0] funct3, input [6:0] opcode);
    begin
      make_inst = {funct7[5], funct3, opcode[6:2]};
    end
  endfunction

  task test_instruction(input [8:0] test_inst, input br_eq, input br_lt,
                        input [17:0] expected_control, input string desc);
    begin
      inst = test_inst;
      brEQ = br_eq;
      brLT = br_lt;
      #1;
      $display("%s", desc);
      expect_17(expected_control, control);
    end
  endtask

  initial begin
    $dumpfile("build/vcd/elements/control_wave.vcd");
    $dumpvars(0, tb_control);

    // ============================================================
    // R-FORMAT ARITHMETIC OPERATIONS
    // ============================================================

    // ADD: opcode=0110011, funct3=000, funct7=0x00
    test_instruction(
        make_inst(7'h0, `FUNCT3_ADD_SUB, `OPCODE_ARITH_OP), 1'b0, 1'b0, {
        1'b0, `FORMAT_INVALID, 1'b1, 1'b0, 1'b0, 1'b0, `OP_ADD, 1'b0, `DMEM_TYPE_INVALID, 2'b01},
        "ADD: R-format add operation");

    // SUB: opcode=0110011, funct3=000, funct7=0x20
    test_instruction(
        make_inst(7'h20, `FUNCT3_ADD_SUB, `OPCODE_ARITH_OP), 1'b0, 1'b0, {
        1'b0, `FORMAT_INVALID, 1'b1, 1'b0, 1'b0, 1'b0, `OP_SUB, 1'b0, `DMEM_TYPE_INVALID, 2'b01},
        "SUB: R-format subtract operation");

    // AND: opcode=0110011, funct3=111, funct7=0x00
    test_instruction(
        make_inst(7'h0, `FUNCT3_AND, `OPCODE_ARITH_OP), 1'b0, 1'b0, {
        1'b0, `FORMAT_INVALID, 1'b1, 1'b0, 1'b0, 1'b0, `OP_AND, 1'b0, `DMEM_TYPE_INVALID, 2'b01},
        "AND: R-format bitwise AND");

    // OR: opcode=0110011, funct3=110, funct7=0x00
    test_instruction(
        make_inst(7'h0, `FUNCT3_OR, `OPCODE_ARITH_OP), 1'b0, 1'b0, {
        1'b0, `FORMAT_INVALID, 1'b1, 1'b0, 1'b0, 1'b0, `OP_OR, 1'b0, `DMEM_TYPE_INVALID, 2'b01},
        "OR: R-format bitwise OR");

    // XOR: opcode=0110011, funct3=100, funct7=0x00
    test_instruction(
        make_inst(7'h0, `FUNCT3_XOR, `OPCODE_ARITH_OP), 1'b0, 1'b0, {
        1'b0, `FORMAT_INVALID, 1'b1, 1'b0, 1'b0, 1'b0, `OP_XOR, 1'b0, `DMEM_TYPE_INVALID, 2'b01},
        "XOR: R-format bitwise XOR");

    // SLL: opcode=0110011, funct3=001, funct7=0x00
    test_instruction(
        make_inst(7'h0, `FUNCT3_SLL, `OPCODE_ARITH_OP), 1'b0, 1'b0, {
        1'b0, `FORMAT_INVALID, 1'b1, 1'b0, 1'b0, 1'b0, `OP_SLL, 1'b0, `DMEM_TYPE_INVALID, 2'b01},
        "SLL: R-format shift left logical");

    // SRL: opcode=0110011, funct3=101, funct7=0x00
    test_instruction(
        make_inst(7'h0, `FUNCT3_SRL_SRA, `OPCODE_ARITH_OP), 1'b0, 1'b0, {
        1'b0, `FORMAT_INVALID, 1'b1, 1'b0, 1'b0, 1'b0, `OP_SRL, 1'b0, `DMEM_TYPE_INVALID, 2'b01},
        "SRL: R-format shift right logical");

    // SRA: opcode=0110011, funct3=101, funct7=0x20
    test_instruction(
        make_inst(7'h20, `FUNCT3_SRL_SRA, `OPCODE_ARITH_OP), 1'b0, 1'b0, {
        1'b0, `FORMAT_INVALID, 1'b1, 1'b0, 1'b0, 1'b0, `OP_SRA, 1'b0, `DMEM_TYPE_INVALID, 2'b01},
        "SRA: R-format shift right arithmetic");

    // SLT: opcode=0110011, funct3=010, funct7=0x00
    test_instruction(
        make_inst(7'h0, `FUNCT3_SLT, `OPCODE_ARITH_OP), 1'b0, 1'b0, {
        1'b0, `FORMAT_INVALID, 1'b1, 1'b0, 1'b0, 1'b0, `OP_SLT, 1'b0, `DMEM_TYPE_INVALID, 2'b01},
        "SLT: R-format set less than (signed)");

    // SLTU: opcode=0110011, funct3=011, funct7=0x00
    test_instruction(
        make_inst(7'h0, `FUNCT3_SLTU, `OPCODE_ARITH_OP), 1'b0, 1'b0, {
        1'b0, `FORMAT_INVALID, 1'b1, 1'b0, 1'b0, 1'b0, `OP_SLTU, 1'b0, `DMEM_TYPE_INVALID, 2'b01},
        "SLTU: R-format set less than unsigned");

    // ============================================================
    // I-FORMAT ARITHMETIC OPERATIONS
    // ============================================================

    // ADDI: opcode=0010011, funct3=000, funct7=DC
    test_instruction(
        make_inst(7'h0, `FUNCT3_ADD_SUB, `OPCODE_ARITH_OP_IMM), 1'b0, 1'b0, {
        1'b0, `FORMAT_I, 1'b1, 1'b0, 1'b1, 1'b0, `OP_ADD, 1'b0, `DMEM_TYPE_INVALID, 2'b01},
        "ADDI: I-format add immediate");

    // ANDI: opcode=0010011, funct3=111, funct7=DC
    test_instruction(
        make_inst(7'h0, `FUNCT3_AND, `OPCODE_ARITH_OP_IMM), 1'b0, 1'b0, {
        1'b0, `FORMAT_I, 1'b1, 1'b0, 1'b1, 1'b0, `OP_AND, 1'b0, `DMEM_TYPE_INVALID, 2'b01},
        "ANDI: I-format bitwise AND immediate");

    // ORI: opcode=0010011, funct3=110, funct7=DC
    test_instruction(
        make_inst(7'h0, `FUNCT3_OR, `OPCODE_ARITH_OP_IMM), 1'b0, 1'b0, {
        1'b0, `FORMAT_I, 1'b1, 1'b0, 1'b1, 1'b0, `OP_OR, 1'b0, `DMEM_TYPE_INVALID, 2'b01},
        "ORI: I-format bitwise OR immediate");

    // XORI: opcode=0010011, funct3=100, funct7=DC
    test_instruction(
        make_inst(7'h0, `FUNCT3_XOR, `OPCODE_ARITH_OP_IMM), 1'b0, 1'b0, {
        1'b0, `FORMAT_I, 1'b1, 1'b0, 1'b1, 1'b0, `OP_XOR, 1'b0, `DMEM_TYPE_INVALID, 2'b01},
        "XORI: I-format bitwise XOR immediate");

    // SLLI: opcode=0010011, funct3=001, funct7=0x00
    test_instruction(
        make_inst(7'h0, `FUNCT3_SLL, `OPCODE_ARITH_OP_IMM), 1'b0, 1'b0, {
        1'b0, `FORMAT_I, 1'b1, 1'b0, 1'b1, 1'b0, `OP_SLL, 1'b0, `DMEM_TYPE_INVALID, 2'b01},
        "SLLI: I-format shift left logical immediate");

    // SRLI: opcode=0010011, funct3=101, funct7=0x00
    test_instruction(
        make_inst(7'h0, `FUNCT3_SRL_SRA, `OPCODE_ARITH_OP_IMM), 1'b0, 1'b0, {
        1'b0, `FORMAT_I, 1'b1, 1'b0, 1'b1, 1'b0, `OP_SRL, 1'b0, `DMEM_TYPE_INVALID, 2'b01},
        "SRLI: I-format shift right logical immediate");

    // SRAI: opcode=0010011, funct3=101, funct7=0x20
    test_instruction(
        make_inst(7'h20, `FUNCT3_SRL_SRA, `OPCODE_ARITH_OP_IMM), 1'b0, 1'b0, {
        1'b0, `FORMAT_I, 1'b1, 1'b0, 1'b1, 1'b0, `OP_SRA, 1'b0, `DMEM_TYPE_INVALID, 2'b01},
        "SRAI: I-format shift right arithmetic immediate");

    // SLTI: opcode=0010011, funct3=010, funct7=DC
    test_instruction(
        make_inst(7'h0, `FUNCT3_SLT, `OPCODE_ARITH_OP_IMM), 1'b0, 1'b0, {
        1'b0, `FORMAT_I, 1'b1, 1'b0, 1'b1, 1'b0, `OP_SLT, 1'b0, `DMEM_TYPE_INVALID, 2'b01},
        "SLTI: I-format set less than signed immediate");

    // SLTIU: opcode=0010011, funct3=011, funct7=DC
    test_instruction(
        make_inst(7'h0, `FUNCT3_SLTU, `OPCODE_ARITH_OP_IMM), 1'b0, 1'b0, {
        1'b0, `FORMAT_I, 1'b1, 1'b0, 1'b1, 1'b0, `OP_SLTU, 1'b0, `DMEM_TYPE_INVALID, 2'b01},
        "SLTIU: I-format set less than unsigned immediate");

    // ============================================================
    // LOAD OPERATIONS
    // ============================================================

    // LB: opcode=0000011, funct3=000
    test_instruction(make_inst(7'h0, `FUNCT3_LB, `OPCODE_LOAD), 1'b0, 1'b0, {
                     1'b0, `FORMAT_I, 1'b1, 1'b0, 1'b1, 1'b0, `OP_ADD, 1'b0, `DMEM_TYPE_B, 2'b00},
                     "LB: Load byte (signed)");

    // LH: opcode=0000011, funct3=001
    test_instruction(make_inst(7'h0, `FUNCT3_LH, `OPCODE_LOAD), 1'b0, 1'b0, {
                     1'b0, `FORMAT_I, 1'b1, 1'b0, 1'b1, 1'b0, `OP_ADD, 1'b0, `DMEM_TYPE_H, 2'b00},
                     "LH: Load half-word (signed)");

    // LW: opcode=0000011, funct3=010
    test_instruction(make_inst(7'h0, `FUNCT3_LW, `OPCODE_LOAD), 1'b0, 1'b0, {
                     1'b0, `FORMAT_I, 1'b1, 1'b0, 1'b1, 1'b0, `OP_ADD, 1'b0, `DMEM_TYPE_W, 2'b00},
                     "LW: Load word");

    // LBU: opcode=0000011, funct3=100
    test_instruction(make_inst(7'h0, `FUNCT3_LBU, `OPCODE_LOAD), 1'b0, 1'b0, {
                     1'b0, `FORMAT_I, 1'b1, 1'b0, 1'b1, 1'b0, `OP_ADD, 1'b0, `DMEM_TYPE_BU, 2'b00},
                     "LBU: Load byte (unsigned)");

    // LHU: opcode=0000011, funct3=101
    test_instruction(make_inst(7'h0, `FUNCT3_LHU, `OPCODE_LOAD), 1'b0, 1'b0, {
                     1'b0, `FORMAT_I, 1'b1, 1'b0, 1'b1, 1'b0, `OP_ADD, 1'b0, `DMEM_TYPE_HU, 2'b00},
                     "LHU: Load half-word (unsigned)");

    // ============================================================
    // STORE OPERATIONS
    // ============================================================

    // SB: opcode=0100011, funct3=000
    test_instruction(make_inst(7'h0, `FUNCT3_SB, `OPCODE_STORE), 1'b0, 1'b0, {
                     1'b0, `FORMAT_S, 1'b0, 1'b0, 1'b1, 1'b0, `OP_ADD, 1'b1, `DMEM_TYPE_B, 2'b00},
                     "SB: Store byte");

    // SH: opcode=0100011, funct3=001
    test_instruction(make_inst(7'h0, `FUNCT3_SH, `OPCODE_STORE), 1'b0, 1'b0, {
                     1'b0, `FORMAT_S, 1'b0, 1'b0, 1'b1, 1'b0, `OP_ADD, 1'b1, `DMEM_TYPE_H, 2'b00},
                     "SH: Store half-word");

    // SW: opcode=0100011, funct3=010
    test_instruction(make_inst(7'h0, `FUNCT3_SW, `OPCODE_STORE), 1'b0, 1'b0, {
                     1'b0, `FORMAT_S, 1'b0, 1'b0, 1'b1, 1'b0, `OP_ADD, 1'b1, `DMEM_TYPE_W, 2'b00},
                     "SW: Store word");

    // ============================================================
    // BRANCH OPERATIONS
    // ============================================================

    // BEQ with condition TRUE (brEQ=1)
    test_instruction(
        make_inst(7'h0, `FUNCT3_BEQ, `OPCODE_BRANCH), 1'b1, 1'b0, {
        1'b1, `FORMAT_B, 1'b0, 1'b0, 1'b1, 1'b1, `OP_ADD, 1'b0, `DMEM_TYPE_INVALID, 2'b00},
        "BEQ: Branch if equal (condition true)");

    // BEQ with condition FALSE (brEQ=0)
    test_instruction(
        make_inst(7'h0, `FUNCT3_BEQ, `OPCODE_BRANCH), 1'b0, 1'b0, {
        1'b0, `FORMAT_B, 1'b0, 1'b0, 1'b1, 1'b1, `OP_ADD, 1'b0, `DMEM_TYPE_INVALID, 2'b00},
        "BEQ: Branch if equal (condition false)");

    // BNE with condition TRUE (brEQ=0, inverted)
    test_instruction(
        make_inst(7'h0, `FUNCT3_BNE, `OPCODE_BRANCH), 1'b0, 1'b0, {
        1'b1, `FORMAT_B, 1'b0, 1'b0, 1'b1, 1'b1, `OP_ADD, 1'b0, `DMEM_TYPE_INVALID, 2'b00},
        "BNE: Branch if not equal (condition true)");

    // BNE with condition FALSE (brEQ=1, inverted)
    test_instruction(
        make_inst(7'h0, `FUNCT3_BNE, `OPCODE_BRANCH), 1'b1, 1'b0, {
        1'b0, `FORMAT_B, 1'b0, 1'b0, 1'b1, 1'b1, `OP_ADD, 1'b0, `DMEM_TYPE_INVALID, 2'b00},
        "BNE: Branch if not equal (condition false)");

    // BLT with condition TRUE (brLT=1, signed)
    test_instruction(
        make_inst(7'h0, `FUNCT3_BLT, `OPCODE_BRANCH), 1'b0, 1'b1, {
        1'b1, `FORMAT_B, 1'b0, 1'b0, 1'b1, 1'b1, `OP_ADD, 1'b0, `DMEM_TYPE_INVALID, 2'b00},
        "BLT: Branch if less than signed (condition true)");

    // BLT with condition FALSE (brLT=0, signed)
    test_instruction(
        make_inst(7'h0, `FUNCT3_BLT, `OPCODE_BRANCH), 1'b0, 1'b0, {
        1'b0, `FORMAT_B, 1'b0, 1'b0, 1'b1, 1'b1, `OP_ADD, 1'b0, `DMEM_TYPE_INVALID, 2'b00},
        "BLT: Branch if less than signed (condition false)");

    // BGE with condition TRUE (brLT=0, inverted, signed)
    test_instruction(
        make_inst(7'h0, `FUNCT3_BGE, `OPCODE_BRANCH), 1'b0, 1'b0, {
        1'b1, `FORMAT_B, 1'b0, 1'b0, 1'b1, 1'b1, `OP_ADD, 1'b0, `DMEM_TYPE_INVALID, 2'b00},
        "BGE: Branch if greater or equal signed (condition true)");

    // BGE with condition FALSE (brLT=1, inverted, signed)
    test_instruction(
        make_inst(7'h0, `FUNCT3_BGE, `OPCODE_BRANCH), 1'b0, 1'b1, {
        1'b0, `FORMAT_B, 1'b0, 1'b0, 1'b1, 1'b1, `OP_ADD, 1'b0, `DMEM_TYPE_INVALID, 2'b00},
        "BGE: Branch if greater or equal signed (condition false)");

    // BLTU with condition TRUE (brLT=1, unsigned)
    test_instruction(
        make_inst(7'h0, `FUNCT3_BLTU, `OPCODE_BRANCH), 1'b0, 1'b1, {
        1'b1, `FORMAT_B, 1'b0, 1'b1, 1'b1, 1'b1, `OP_ADD, 1'b0, `DMEM_TYPE_INVALID, 2'b00},
        "BLTU: Branch if less than unsigned (condition true)");

    // BLTU with condition FALSE (brLT=0, unsigned)
    test_instruction(
        make_inst(7'h0, `FUNCT3_BLTU, `OPCODE_BRANCH), 1'b0, 1'b0, {
        1'b0, `FORMAT_B, 1'b0, 1'b1, 1'b1, 1'b1, `OP_ADD, 1'b0, `DMEM_TYPE_INVALID, 2'b00},
        "BLTU: Branch if less than unsigned (condition false)");

    // BGEU with condition TRUE (brLT=0, inverted, unsigned)
    test_instruction(
        make_inst(7'h0, `FUNCT3_BGEU, `OPCODE_BRANCH), 1'b0, 1'b0, {
        1'b1, `FORMAT_B, 1'b0, 1'b1, 1'b1, 1'b1, `OP_ADD, 1'b0, `DMEM_TYPE_INVALID, 2'b00},
        "BGEU: Branch if greater or equal unsigned (condition true)");

    // BGEU with condition FALSE (brLT=1, inverted, unsigned)
    test_instruction(
        make_inst(7'h0, `FUNCT3_BGEU, `OPCODE_BRANCH), 1'b0, 1'b1, {
        1'b0, `FORMAT_B, 1'b0, 1'b1, 1'b1, 1'b1, `OP_ADD, 1'b0, `DMEM_TYPE_INVALID, 2'b00},
        "BGEU: Branch if greater or equal unsigned (condition false)");

    // ============================================================
    // JUMP OPERATIONS
    // ============================================================

    // JAL: opcode=1101111
    test_instruction(
        make_inst(7'h0, `FUNCT3_BEQ, `OPCODE_JAL), 1'b0, 1'b0, {
        1'b1, `FORMAT_J, 1'b1, 1'b0, 1'b1, 1'b1, `OP_ADD, 1'b0, `DMEM_TYPE_INVALID, 2'b10},
        "JAL: Jump and link");

    // JALR: opcode=1100111
    test_instruction(
        make_inst(7'h0, `FUNCT3_BEQ, `OPCODE_JALR), 1'b0, 1'b0, {
        1'b1, `FORMAT_I, 1'b1, 1'b0, 1'b1, 1'b0, `OP_ADD, 1'b0, `DMEM_TYPE_INVALID, 2'b10},
        "JALR: Jump and link register");

    // ============================================================
    // U-FORMAT OPERATIONS
    // ============================================================

    // LUI: opcode=0110111
    test_instruction(
        make_inst(7'h0, `FUNCT3_BEQ, `OPCODE_LUI), 1'b0, 1'b0, {
        1'b0, `FORMAT_U, 1'b1, 1'b0, 1'b1, 1'b0, `OP_PASSTHROUGH_B, 1'b0, `DMEM_TYPE_INVALID, 2'b01
        }, "LUI: Load upper immediate");

    // AUIPC: opcode=0010111
    test_instruction(
        make_inst(7'h0, `FUNCT3_BEQ, `OPCODE_AUIPC), 1'b0, 1'b0, {
        1'b0, `FORMAT_U, 1'b1, 1'b0, 1'b1, 1'b1, `OP_ADD, 1'b0, `DMEM_TYPE_INVALID, 2'b01},
        "AUIPC: Add upper immediate to PC");

    $finish;
  end

endmodule
