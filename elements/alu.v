`include "alu_defs.vh"

module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [ 7:0] op,
    output reg  [31:0] res
);

  always @(*) begin
    res = 32'b0;
    case (op)
      `OP_PASSTHROUGH_A: res = a;
      `OP_PASSTHROUGH_B: res = b;
      `OP_ADD: res = a + b;
      `OP_SUB: res = a - b;
      `OP_AND: res = a & b;
      `OP_OR: res = a | b;
      `OP_XOR: res = a ^ b;
      `OP_SLL: res = a << b[4:0];
      `OP_SRL: res = a >> b[4:0];
      `OP_SLT: res = (a < b) ? 1 : 0;
      default: res = 32'h0;
    endcase
  end

endmodule
