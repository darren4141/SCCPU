`include "constants.vh"

module stalling (
    input wire [31:0] inst_ex,
    input wire [31:0] inst_m,
    input wire RegWen_m,
    output reg stall
);

  wire [6:0] opcode_ex = inst_ex[6:0];
  wire [6:0] opcode_m = inst_m[6:0];

  wire [4:0] rs1_ex = inst_ex[19:15];
  wire [4:0] rs2_ex = inst_ex[24:20];

  wire [4:0] rd_m = inst_m[11:7];

  /*
    Stall Procedure:
    - Do not increment PC -> we must add another input to the PCSel mux that keeps the current PC
    - Disable writes on intermediate registers
*/

  always @(*) begin
    stall = 1'b0;
    if (RegWen_m && (rd_m == rs1_ex) && (opcode_m == `OPCODE_LOAD) &&
      (opcode_ex == `OPCODE_ARITH_OP ||
      opcode_ex == `OPCODE_ARITH_OP_IMM ||
      opcode_ex == `OPCODE_LOAD ||
      opcode_ex == `OPCODE_STORE ||
      opcode_ex == `OPCODE_BRANCH ||
      opcode_ex == `OPCODE_JALR)) begin
      stall = 1'b1;
    end

    if (RegWen_m && (rd_m == rs2_ex) && (opcode_m == `OPCODE_LOAD) &&
      (opcode_ex == `OPCODE_ARITH_OP ||
      opcode_ex == `OPCODE_STORE ||
      opcode_ex == `OPCODE_BRANCH)) begin
      stall = 1'b1;
    end

  end

endmodule
