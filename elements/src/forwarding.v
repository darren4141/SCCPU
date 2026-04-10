`include "constants.vh"

module forwarding (
    input wire [31:0] inst_ex,
    input wire [31:0] inst_m,
    input wire [31:0] inst_wb,
    input wire RegWen_m,
    input wire RegWen_wb,
    output reg [1:0] fwdA,
    output reg [1:0] fwdB,
    output reg fwdM
);

  wire [6:0] opcode_ex = inst_ex[6:0];
  wire [6:0] opcode_m = inst_m[6:0];
  wire [6:0] opcode_wb = inst_wb[6:0];

  wire [4:0] rs1_ex = inst_ex[19:15];
  wire [4:0] rs2_ex = inst_ex[24:20];

  wire [4:0] rs2_m = inst_m[24:20];

  wire [4:0] rd_m = inst_m[11:7];
  wire [4:0] rd_wb = inst_wb[11:7];

  /*
    rs1_ex = rd_m (MX_A forward)
    rs2_ex = rd_m (MX_B forward)

    rs1_ex = rd_wb (WX_A forward)
    rs2_ex = rd_wb (WX_B forward)

    rs2_m = rd_wb (WM_B forward)
*/

  always @(*) begin
    fwdA = 1'b0;
    fwdB = 1'b0;
    fwdM = 1'b0;

    // Condition to check if wb instruction is writing a valid rd
    if (RegWen_wb &&
    (opcode_wb == `OPCODE_ARITH_OP ||
    opcode_wb == `OPCODE_ARITH_OP_IMM ||
    opcode_wb == `OPCODE_LOAD ||
    opcode_wb == `OPCODE_LUI ||
    opcode_wb == `OPCODE_AUIPC)) begin

      if ((rd_wb == rs1_ex) &&
      (opcode_ex == `OPCODE_ARITH_OP ||
      opcode_ex == `OPCODE_ARITH_OP_IMM ||
      opcode_ex == `OPCODE_LOAD ||
      opcode_ex == `OPCODE_STORE ||
      opcode_ex == `OPCODE_BRANCH ||
      opcode_ex == `OPCODE_JALR))
        fwdA = 2'b10;

      if ((rd_wb == rs2_ex) &&
      (opcode_ex == `OPCODE_ARITH_OP ||
      opcode_ex == `OPCODE_STORE ||
      opcode_ex == `OPCODE_BRANCH))
        fwdB = 2'b10;

      if ((rd_wb == rs2_m) &&
      (opcode_m == `OPCODE_ARITH_OP ||
      opcode_m == `OPCODE_STORE ||
      opcode_m == `OPCODE_BRANCH))
        fwdM = 1'b1;

    end

    // Condition to check if m instruction is writing a valid rd (m instruction cannot be load)
    if (RegWen_m &&
    (opcode_m == `OPCODE_ARITH_OP ||
    opcode_m == `OPCODE_ARITH_OP_IMM ||
    opcode_m == `OPCODE_LUI ||
    opcode_m == `OPCODE_AUIPC)) begin

      if ((rd_m == rs1_ex) &&
      (opcode_ex == `OPCODE_ARITH_OP ||
      opcode_ex == `OPCODE_ARITH_OP_IMM ||
      opcode_ex == `OPCODE_LOAD ||
      opcode_ex == `OPCODE_STORE ||
      opcode_ex == `OPCODE_BRANCH ||
      opcode_ex == `OPCODE_JALR))
        fwdA = 2'b01;

      if ((rd_m == rs2_ex) &&
      (opcode_ex == `OPCODE_ARITH_OP ||
      opcode_ex == `OPCODE_STORE ||
      opcode_ex == `OPCODE_BRANCH))
        fwdB = 2'b01;

    end
  end

endmodule
