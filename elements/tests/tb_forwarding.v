`timescale 1ns / 1ps

module tb_forwarding;
  `include "expect.vh"
  `include "constants.vh"

  // Signals
  reg [31:0] inst_ex;
  reg [31:0] inst_m;
  reg [31:0] inst_wb;
  reg RegWen_m;
  reg RegWen_wb;
  wire [1:0] fwdA;
  wire [1:0] fwdB;
  wire fwdM;

  forwarding uut (
      .inst_ex(inst_ex),
      .inst_m(inst_m),
      .inst_wb(inst_wb),
      .RegWen_m(RegWen_m),
      .RegWen_wb(RegWen_wb),
      .fwdA(fwdA),
      .fwdB(fwdB),
      .fwdM(fwdM)
  );

  // Helper function to create instruction with specific rd, rs1, rs2, and opcode
  function [31:0] create_inst(input [6:0] opcode, input [4:0] rd, input [4:0] rs1, input [4:0] rs2);
    create_inst = {rs2, rs1, 3'b0, rd, opcode};
  endfunction

  // Helper function to create immediate instruction with rd, rs1, and opcode
  function [31:0] create_inst_imm(input [6:0] opcode, input [4:0] rd, input [4:0] rs1);
    create_inst_imm = {12'b0, rs1, 3'b0, rd, opcode};
  endfunction

  initial begin
    $dumpfile("build/vcd/elements/forwarding_wave.vcd");
    $dumpvars(0, tb_forwarding);

    // Test 1: No forwarding - no register writes enabled
    $display("\n=== Test 1: No forwarding - RegWen disabled ===");
    inst_wb = create_inst(`OPCODE_ARITH_OP, 5'd7, 5'd8, 5'd9);
    inst_m = create_inst(`OPCODE_ARITH_OP, 5'd4, 5'd5, 5'd6);
    inst_ex = create_inst(`OPCODE_ARITH_OP, 5'd1, 5'd2, 5'd3);
    RegWen_m = 1'b0;
    RegWen_wb = 1'b0;
    #1;
    expect_2(2'b0, fwdA);
    expect_2(2'b0, fwdB);
    expect_1(1'b0, fwdM);

    // Test 2: No forwarding - rd doesn't match any rs
    $display("\n=== Test 2: No forwarding - rd doesn't match rs ===");
    inst_wb = create_inst(`OPCODE_ARITH_OP, 5'd11, 5'd8, 5'd9);
    inst_m = create_inst(`OPCODE_ARITH_OP, 5'd10, 5'd5, 5'd6);
    inst_ex = create_inst(`OPCODE_ARITH_OP, 5'd1, 5'd2, 5'd3);
    RegWen_m = 1'b1;
    RegWen_wb = 1'b1;
    #1;
    expect_2(2'b0, fwdA);
    expect_2(2'b0, fwdB);
    expect_1(1'b0, fwdM);

    // Test 3: MX_A forwarding (rs1_ex = rd_m)
    $display("\n=== Test 3: MX_A forwarding (rs1_ex = rd_m) ===");
    inst_wb = create_inst(`OPCODE_ARITH_OP, 5'd11, 5'd8, 5'd9);
    inst_m = create_inst(`OPCODE_ARITH_OP, 5'd5, 5'd6, 5'd7);
    inst_ex = create_inst(`OPCODE_ARITH_OP, 5'd1, 5'd5, 5'd3);
    RegWen_m = 1'b1;
    RegWen_wb = 1'b0;
    #1;
    expect_2(2'b01, fwdA);
    expect_2(2'b0, fwdB);
    expect_1(1'b0, fwdM);

    // Test 4: MX_B forwarding (rs2_ex = rd_m)
    $display("\n=== Test 4: MX_B forwarding (rs2_ex = rd_m) ===");
    inst_wb = create_inst(`OPCODE_ARITH_OP, 5'd11, 5'd8, 5'd9);
    inst_m = create_inst(`OPCODE_ARITH_OP, 5'd6, 5'd5, 5'd7);
    inst_ex = create_inst(`OPCODE_ARITH_OP, 5'd1, 5'd2, 5'd6);
    RegWen_m = 1'b1;
    RegWen_wb = 1'b0;
    #1;
    expect_2(2'b0, fwdA);
    expect_2(2'b01, fwdB);
    expect_1(1'b0, fwdM);

    // Test 5: WX_A forwarding (rs1_ex = rd_wb)
    $display("\n=== Test 5: WX_A forwarding (rs1_ex = rd_wb) ===");
    inst_wb = create_inst(`OPCODE_ARITH_OP, 5'd8, 5'd11, 5'd12);
    inst_m = create_inst(`OPCODE_ARITH_OP, 5'd10, 5'd5, 5'd6);
    inst_ex = create_inst(`OPCODE_ARITH_OP, 5'd1, 5'd8, 5'd3);
    RegWen_m = 1'b1;
    RegWen_wb = 1'b1;
    #1;
    expect_2(2'b10, fwdA);
    expect_2(2'b0, fwdB);
    expect_1(1'b0, fwdM);

    // Test 6: WX_B forwarding (rs2_ex = rd_wb)
    $display("\n=== Test 6: WX_B forwarding (rs2_ex = rd_wb) ===");
    inst_wb = create_inst(`OPCODE_ARITH_OP, 5'd9, 5'd11, 5'd12);
    inst_m = create_inst(`OPCODE_ARITH_OP, 5'd10, 5'd5, 5'd6);
    inst_ex = create_inst(`OPCODE_ARITH_OP, 5'd1, 5'd2, 5'd9);
    RegWen_m = 1'b1;
    RegWen_wb = 1'b1;
    #1;
    expect_2(2'b0, fwdA);
    expect_2(2'b10, fwdB);
    expect_1(1'b0, fwdM);

    // Test 7: WM_B forwarding (rs2_m = rd_wb)
    $display("\n=== Test 7: WM_B forwarding (rs2_m = rd_wb) ===");
    inst_wb = create_inst(`OPCODE_ARITH_OP, 5'd12, 5'd11, 5'd13);
    inst_m = create_inst(`OPCODE_ARITH_OP, 5'd10, 5'd5, 5'd12);
    inst_ex = create_inst(`OPCODE_ARITH_OP, 5'd1, 5'd2, 5'd3);
    RegWen_m = 1'b1;
    RegWen_wb = 1'b1;
    #1;
    expect_2(2'b0, fwdA);
    expect_2(2'b0, fwdB);
    expect_1(1'b1, fwdM);

    // Test 8: MX_A and MX_B forwarding (both match m stage)
    $display("\n=== Test 8: MX_A and MX_B forwarding ===");
    inst_wb = create_inst(`OPCODE_ARITH_OP, 5'd11, 5'd9, 5'd10);
    inst_m = create_inst(`OPCODE_ARITH_OP, 5'd5, 5'd7, 5'd8);
    inst_ex = create_inst(`OPCODE_ARITH_OP, 5'd1, 5'd5, 5'd5);
    RegWen_m = 1'b1;
    RegWen_wb = 1'b0;
    #1;
    expect_2(2'b01, fwdA);
    expect_2(2'b01, fwdB);
    expect_1(1'b0, fwdM);

    // Test 9: Load instruction in wb stage (should forward)
    $display("\n=== Test 9: Load instruction in wb stage ===");
    inst_wb = create_inst(`OPCODE_LOAD, 5'd7, 5'd8, 5'd9);
    inst_m = create_inst(`OPCODE_ARITH_OP, 5'd10, 5'd5, 5'd6);
    inst_ex = create_inst(`OPCODE_ARITH_OP, 5'd1, 5'd7, 5'd3);
    RegWen_m = 1'b1;
    RegWen_wb = 1'b1;
    #1;
    expect_2(2'b10, fwdA);
    expect_2(2'b0, fwdB);
    expect_1(1'b0, fwdM);

    // Test 10: LUI instruction in wb stage (should forward)
    $display("\n=== Test 10: LUI instruction in wb stage ===");
    inst_wb = {12'b0, 5'b0, 3'b0, 5'd9, `OPCODE_LUI};
    inst_m = create_inst(`OPCODE_ARITH_OP, 5'd10, 5'd5, 5'd6);
    inst_ex = create_inst(`OPCODE_ARITH_OP, 5'd1, 5'd9, 5'd3);
    RegWen_m = 1'b1;
    RegWen_wb = 1'b1;
    #1;
    expect_2(2'b10, fwdA);
    expect_2(2'b0, fwdB);
    expect_1(1'b0, fwdM);

    // Test 11: Store instruction in ex stage with rs2_m = rd_wb
    $display("\n=== Test 11: Store instruction in ex with forwarding ===");
    inst_wb = create_inst(`OPCODE_ARITH_OP, 5'd13, 5'd11, 5'd12);
    inst_m = create_inst(`OPCODE_STORE, 5'd10, 5'd5, 5'd13);
    inst_ex = create_inst(`OPCODE_STORE, 5'd1, 5'd2, 5'd3);
    RegWen_m = 1'b1;
    RegWen_wb = 1'b1;
    #1;
    expect_2(2'b0, fwdA);
    expect_2(2'b0, fwdB);
    expect_1(1'b1, fwdM);

    // Test 12: Branch instruction in ex stage (should forward for both rs1 and rs2)
    $display("\n=== Test 12: Branch instruction with forwarding ===");
    inst_wb = create_inst(`OPCODE_ARITH_OP, 5'd15, 5'd11, 5'd12);
    inst_m = create_inst(`OPCODE_ARITH_OP, 5'd14, 5'd5, 5'd6);
    inst_ex = create_inst(`OPCODE_BRANCH, 5'd1, 5'd14, 5'd15);
    RegWen_m = 1'b1;
    RegWen_wb = 1'b1;
    #1;
    expect_2(2'b01, fwdA);
    expect_2(2'b10, fwdB);
    expect_1(1'b0, fwdM);

    // Test 13: JALR instruction in ex stage (should forward for rs1)
    $display("\n=== Test 13: JALR instruction with forwarding ===");
    inst_wb = create_inst(`OPCODE_ARITH_OP, 5'd11, 5'd12, 5'd13);
    inst_m = create_inst(`OPCODE_ARITH_OP, 5'd16, 5'd5, 5'd6);
    inst_ex = {12'b0, 5'd16, 3'b0, 5'd1, `OPCODE_JALR};
    RegWen_m = 1'b1;
    RegWen_wb = 1'b1;
    #1;
    expect_2(2'b01, fwdA);
    expect_2(2'b0, fwdB);
    expect_1(1'b0, fwdM);

    // Test 14: Priority: m stage forwarding takes precedence over wb stage for WX/MX override
    $display("\n=== Test 14: MX overrides WX for rs1 ===");
    inst_wb = create_inst(`OPCODE_ARITH_OP, 5'd17, 5'd11, 5'd12);
    inst_m = create_inst(`OPCODE_ARITH_OP, 5'd17, 5'd5, 5'd6);
    inst_ex = create_inst(`OPCODE_ARITH_OP, 5'd1, 5'd17, 5'd3);
    RegWen_m = 1'b1;
    RegWen_wb = 1'b1;
    #1;
    expect_2(2'b01, fwdA);
    expect_2(2'b0, fwdB);
    expect_1(1'b0, fwdM);

    // Test 15: AUIPC instruction in wb stage
    $display("\n=== Test 15: AUIPC instruction in wb stage ===");
    inst_wb = {12'b0, 5'b0, 3'b0, 5'd18, `OPCODE_AUIPC};
    inst_m = create_inst(`OPCODE_ARITH_OP, 5'd10, 5'd5, 5'd6);
    inst_ex = create_inst(`OPCODE_ARITH_OP, 5'd1, 5'd18, 5'd3);
    RegWen_m = 1'b1;
    RegWen_wb = 1'b1;
    #1;
    expect_2(2'b10, fwdA);
    expect_2(2'b0, fwdB);
    expect_1(1'b0, fwdM);

    // Test 16: Instruction that shouldn't forward (ENV opcode)
    $display("\n=== Test 16: ENV instruction (no forward) ===");
    inst_wb = {12'b0, 5'b0, 3'b0, 5'd19, `OPCODE_ENV};
    inst_m = create_inst(`OPCODE_ARITH_OP, 5'd10, 5'd5, 5'd6);
    inst_ex = create_inst(`OPCODE_ARITH_OP, 5'd1, 5'd19, 5'd3);
    RegWen_m = 1'b1;
    RegWen_wb = 1'b1;
    #1;
    expect_2(2'b0, fwdA);
    expect_2(2'b0, fwdB);
    expect_1(1'b0, fwdM);

    // Test 17: MX override - rs2_ex matches both rd_m and rd_wb, MX should be selected
    $display("\n=== Test 17: MX overrides WX for rs2 ===");
    inst_wb = create_inst(`OPCODE_ARITH_OP, 5'd20, 5'd11, 5'd12);
    inst_m = create_inst(`OPCODE_ARITH_OP, 5'd20, 5'd5, 5'd6);
    inst_ex = create_inst(`OPCODE_ARITH_OP, 5'd1, 5'd2, 5'd20);
    RegWen_m = 1'b1;
    RegWen_wb = 1'b1;
    #1;
    expect_2(2'b0, fwdA);
    expect_2(2'b01, fwdB);
    expect_1(1'b0, fwdM);

    // Test 18: Both rs1 and rs2 with MX override
    $display("\n=== Test 18: MX overrides WX for both rs1 and rs2 ===");
    inst_wb = create_inst(`OPCODE_ARITH_OP, 5'd21, 5'd11, 5'd12);
    inst_m = create_inst(`OPCODE_ARITH_OP, 5'd21, 5'd5, 5'd22);
    inst_ex = create_inst(`OPCODE_ARITH_OP, 5'd1, 5'd21, 5'd21);
    RegWen_m = 1'b1;
    RegWen_wb = 1'b1;
    #1;
    expect_2(2'b01, fwdA);
    expect_2(2'b01, fwdB);
    expect_1(1'b0, fwdM);

    $finish;
  end

endmodule
