`include "ss_control_defs.vh"
`include "imm_gen.vh"
`include "mem.vh"
`include "alu_defs.vh"
`include "constants.vh"

`timescale 1ns / 1ps

module tb_pipeline_control;
  `include "expect.vh"

  reg [8:0] inst_ex;
  reg [8:0] inst_m;
  reg [8:0] inst_wb;
  reg brEQ;
  reg brLT;
  wire [17:0] control;

  pipeline_control uut (
      .inst_ex(inst_ex),
      .inst_m(inst_m),
      .inst_wb(inst_wb),
      .brEQ(brEQ),
      .brLT(brLT),
      .control(control)
  );

  function [8:0] make_inst(input [6:0] funct7, input [2:0] funct3, input [6:0] opcode);
    begin
      make_inst = {funct7[5], funct3, opcode[6:2]};
    end
  endfunction

  task test_pipeline(input [8:0] ex_inst, input [8:0] m_inst, input [8:0] wb_inst,
                     input br_eq, input br_lt,
                     input [10:0] expected_ex, input [3:0] expected_m, input [2:0] expected_wb,
                     input string desc);
    begin
      inst_ex = ex_inst;
      inst_m = m_inst;
      inst_wb = wb_inst;
      brEQ = br_eq;
      brLT = br_lt;
      #1;
      $display("%s", desc);
      if (control[17:7] !== expected_ex) begin
        $display("FAIL: EX stage - expected %011b got %011b", expected_ex, control[17:7]);
      end else begin
        $display("PASS: EX stage");
      end
      if (control[6:3] !== expected_m) begin
        $display("FAIL: M stage - expected %04b got %04b", expected_m, control[6:3]);
      end else begin
        $display("PASS: M stage");
      end
      if (control[2:0] !== expected_wb) begin
        $display("FAIL: WB stage - expected %03b got %03b", expected_wb, control[2:0]);
      end else begin
        $display("PASS: WB stage");
      end
    end
  endtask

  initial begin
    $dumpfile("build/vcd/elements/pipeline_control_wave.vcd");
    $dumpvars(0, tb_pipeline_control);

    // ============================================================
    // Test 1: R-format ADD in EX, Load in M, Arithmetic in WB
    // ============================================================
    test_pipeline(
        make_inst(7'h0, `FUNCT3_ADD_SUB, `OPCODE_ARITH_OP),
        make_inst(7'h0, `FUNCT3_LW, `OPCODE_LOAD),
        make_inst(7'h0, `FUNCT3_ADD_SUB, `OPCODE_ARITH_OP_IMM),
        1'b0, 1'b0,
        // EX: ADD {PCSel=0, ImmSel=INVALID, ALUSel=ADD, aSel=0, bSel=0, brUN=0}
        {1'b0, `FORMAT_INVALID, `OP_ADD, 1'b0, 1'b0, 1'b0},
        // M: Load {MemRW=0, MemSize=LW(010)}
        {1'b0, `DMEM_TYPE_W},
        // WB: Arithmetic {RegWen=1, WBSel=01}
        {1'b1, 2'b01},
        "Pipeline: ADD (EX) -> LW (M) -> ADDI (WB)");

    // ============================================================
    // Test 2: R-format SUB in EX, Store in M, Load in WB
    // ============================================================
    test_pipeline(
        make_inst(7'h20, `FUNCT3_ADD_SUB, `OPCODE_ARITH_OP),
        make_inst(7'h0, `FUNCT3_SW, `OPCODE_STORE),
        make_inst(7'h0, `FUNCT3_LW, `OPCODE_LOAD),
        1'b0, 1'b0,
        // EX: SUB {PCSel=0, ImmSel=INVALID, ALUSel=SUB, aSel=0, bSel=0, brUN=0}
        {1'b0, `FORMAT_INVALID, `OP_SUB, 1'b0, 1'b0, 1'b0},
        // M: Store {MemRW=1, MemSize=SW(010)}
        {1'b1, `DMEM_TYPE_W},
        // WB: Load {RegWen=1, WBSel=00}
        {1'b1, 2'b00},
        "Pipeline: SUB (EX) -> SW (M) -> LW (WB)");

    // ============================================================
    // Test 3: I-format ADDI in EX, Load in M, Store in WB
    // ============================================================
    test_pipeline(
        make_inst(7'h0, `FUNCT3_ADD_SUB, `OPCODE_ARITH_OP_IMM),
        make_inst(7'h0, `FUNCT3_LH, `OPCODE_LOAD),
        make_inst(7'h0, `FUNCT3_SB, `OPCODE_STORE),
        1'b0, 1'b0,
        // EX: ADDI {PCSel=0, ImmSel=I, ALUSel=ADD, aSel=0, bSel=1, brUN=0}
        {1'b0, `FORMAT_I, `OP_ADD, 1'b0, 1'b1, 1'b0},
        // M: Load {MemRW=0, MemSize=LH(001)}
        {1'b0, `DMEM_TYPE_H},
        // WB: Store {RegWen=0, WBSel=00}
        {1'b0, 2'b00},
        "Pipeline: ADDI (EX) -> LH (M) -> SB (WB)");

    // ============================================================
    // Test 4: Branch in EX (taken), Arithmetic in M, Jump in WB
    // ============================================================
    test_pipeline(
        make_inst(7'h0, `FUNCT3_BEQ, `OPCODE_BRANCH),
        make_inst(7'h0, `FUNCT3_ADD_SUB, `OPCODE_ARITH_OP),
        make_inst(7'h0, `FUNCT3_BEQ, `OPCODE_JAL),
        1'b1, 1'b0,
        // EX: BEQ taken {PCSel=1, ImmSel=B, ALUSel=ADD, aSel=1, bSel=1, brUN=0}
        {1'b1, `FORMAT_B, `OP_ADD, 1'b1, 1'b1, 1'b0},
        // M: Arithmetic {MemRW=0, MemSize=INVALID}
        {1'b0, `DMEM_TYPE_INVALID},
        // WB: JAL {RegWen=1, WBSel=10}
        {1'b1, 2'b10},
        "Pipeline: BEQ taken (EX) -> ADD (M) -> JAL (WB)");

    // ============================================================
    // Test 5: Branch in EX (not taken), Load in M, JALR in WB
    // ============================================================
    test_pipeline(
        make_inst(7'h0, `FUNCT3_BLT, `OPCODE_BRANCH),
        make_inst(7'h0, `FUNCT3_LBU, `OPCODE_LOAD),
        make_inst(7'h0, `FUNCT3_BEQ, `OPCODE_JALR),
        1'b0, 1'b0,
        // EX: BLT not taken {PCSel=0, ImmSel=B, ALUSel=ADD, aSel=1, bSel=1, brUN=0}
        {1'b0, `FORMAT_B, `OP_ADD, 1'b1, 1'b1, 1'b0},
        // M: Load {MemRW=0, MemSize=LBU(011)}
        {1'b0, `DMEM_TYPE_BU},
        // WB: JALR {RegWen=1, WBSel=10}
        {1'b1, 2'b10},
        "Pipeline: BLT not taken (EX) -> LBU (M) -> JALR (WB)");

    // ============================================================
    // Test 6: LUI in EX, Arithmetic in M, AUIPC in WB
    // ============================================================
    test_pipeline(
        make_inst(7'h0, `FUNCT3_BEQ, `OPCODE_LUI),
        make_inst(7'h0, `FUNCT3_XOR, `OPCODE_ARITH_OP),
        make_inst(7'h0, `FUNCT3_BEQ, `OPCODE_AUIPC),
        1'b0, 1'b0,
        // EX: LUI {PCSel=0, ImmSel=U, ALUSel=PASSTHROUGH_B, aSel=0, bSel=1, brUN=0}
        {1'b0, `FORMAT_U, `OP_PASSTHROUGH_B, 1'b0, 1'b1, 1'b0},
        // M: XOR {MemRW=0, MemSize=INVALID}
        {1'b0, `DMEM_TYPE_INVALID},
        // WB: AUIPC {RegWen=1, WBSel=01}
        {1'b1, 2'b01},
        "Pipeline: LUI (EX) -> XOR (M) -> AUIPC (WB)");

    // ============================================================
    // Test 7: Arithmetic shift in EX, Store in M, Load in WB
    // ============================================================
    test_pipeline(
        make_inst(7'h20, `FUNCT3_SRL_SRA, `OPCODE_ARITH_OP),
        make_inst(7'h0, `FUNCT3_SH, `OPCODE_STORE),
        make_inst(7'h0, `FUNCT3_LB, `OPCODE_LOAD),
        1'b0, 1'b0,
        // EX: SRA {PCSel=0, ImmSel=INVALID, ALUSel=SRA, aSel=0, bSel=0, brUN=0}
        {1'b0, `FORMAT_INVALID, `OP_SRA, 1'b0, 1'b0, 1'b0},
        // M: Store {MemRW=1, MemSize=SH(001)}
        {1'b1, `DMEM_TYPE_H},
        // WB: Load {RegWen=1, WBSel=00}
        {1'b1, 2'b00},
        "Pipeline: SRA (EX) -> SH (M) -> LB (WB)");

    // ============================================================
    // Test 8: I-format shift in EX, Branch in M, Arithmetic in WB
    // ============================================================
    test_pipeline(
        make_inst(7'h20, `FUNCT3_SRL_SRA, `OPCODE_ARITH_OP_IMM),
        make_inst(7'h0, `FUNCT3_BGE, `OPCODE_BRANCH),
        make_inst(7'h0, `FUNCT3_AND, `OPCODE_ARITH_OP),
        1'b0, 1'b0,
        // EX: SRAI {PCSel=0, ImmSel=I, ALUSel=SRA, aSel=0, bSel=1, brUN=0}
        {1'b0, `FORMAT_I, `OP_SRA, 1'b0, 1'b1, 1'b0},
        // M: BGE {MemRW=0, MemSize=INVALID}
        {1'b0, `DMEM_TYPE_INVALID},
        // WB: AND {RegWen=1, WBSel=01}
        {1'b1, 2'b01},
        "Pipeline: SRAI (EX) -> BGE (M) -> AND (WB)");

    $finish;
  end

endmodule
