`include "imm_gen.vh"
`include "constants.vh"

module imm_gen (
    input [31:0] inst,
    output reg [31:0] imm
);

  wire [6:0] opcode = inst[6:0];
  wire sign = inst[31];

  always @(*) begin
    imm = 32'b0;

    case (opcode)
      // R-format
      `OPCODE_ARITH_OP: imm = 32'b0;
      // I-format
      `OPCODE_ARITH_OP_IMM, `OPCODE_LOAD, `OPCODE_JALR, `OPCODE_ENV:
      imm = {{20{sign}}, inst[31:20]};
      // S-format
      `OPCODE_STORE: imm = {{20{sign}}, inst[31:25], inst[11:7]};
      // B-format
      `OPCODE_BRANCH: imm = {{19{sign}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
      // U-format
      `OPCODE_LUI, `OPCODE_AUIPC: imm = {inst[31:12], {12{1'b0}}};
      // J-format
      `OPCODE_JAL: imm = {{11{sign}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
      default: imm = 32'b0;
    endcase

  end

endmodule
