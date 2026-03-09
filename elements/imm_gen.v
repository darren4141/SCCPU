`include "imm_gen.vh"
`include "constants.vh"

module imm_gen (
    input  wire [31:0] inst,
    input  wire [ 2:0] ImmSel,
    output reg  [31:0] imm
);

  wire sign = inst[31];

  always @(*) begin
    imm = 32'b0;

    case (ImmSel)
      // R-format
      `FORMAT_R: imm = 32'b0;
      // I-format
      `FORMAT_I: imm = {{20{sign}}, inst[31:20]};
      // S-format
      `FORMAT_S: imm = {{20{sign}}, inst[31:25], inst[11:7]};
      // B-format
      `FORMAT_B: imm = {{19{sign}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
      // U-format
      `FORMAT_U: imm = {inst[31:12], {12{1'b0}}};
      // J-format
      `FORMAT_J: imm = {{11{sign}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
      default:   imm = 32'b0;
    endcase

  end

endmodule
