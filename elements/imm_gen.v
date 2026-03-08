`include "imm_gen.vh"
`include "constants.vh"

module imm_gen (
    input [31:0] inst,
    output reg [31:0] imm
);

  wire [6:0] opcode = inst[6:0];
  wire sign = inst[31];
  reg [6:0] format;

  always_comb begin
    format = `FORMAT_INVALID;

    imm = 32'b0;
    case (opcode)
      `OPCODE_ARITH_OP: format = `FORMAT_R;
      `OPCODE_ARITH_OP_IMM: format = `FORMAT_I;
      `OPCODE_LOAD: format = `FORMAT_I;
      `OPCODE_JALR: format = `FORMAT_I;
      `OPCODE_ENV: format = `FORMAT_I;
      `OPCODE_STORE: format = `FORMAT_S;
      `OPCODE_BRANCH: format = `FORMAT_B;
      `OPCODE_LUI: format = `FORMAT_U;
      `OPCODE_AUIPC: format = `FORMAT_U;
      `OPCODE_JAL: format = `FORMAT_J;
      default: format = `FORMAT_INVALID;
    endcase

    case (format)
      `FORMAT_R: imm = 32'b0;
      `FORMAT_I: imm = {{20{sign}}, inst[31:20]};
      `FORMAT_S: imm = {{20{sign}}, inst[31:25], inst[11:7]};
      `FORMAT_B: imm = {{19{sign}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
      `FORMAT_U: imm = {inst[31:12], {12{1'b0}}};
      `FORMAT_J: imm = {{11{sign}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
      `FORMAT_INVALID: imm = 32'b0;
      default: imm = 32'b0;
    endcase

  end

endmodule
