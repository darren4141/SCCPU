module pipeline_control (
    input wire [13:0] inst_ex,
    input wire [13:0] inst_m,
    input wire [13:0] inst_wb,
    input wire brEQ,
    input wire brLT,
    output reg [17:0] control
);

  wire [6:0] opcode_ex = {inst_ex[4:0], 2'b11};
  wire [2:0] funct3_ex = inst_ex[12:10];
  wire funct7_ex = inst_ex[13];

  wire [6:0] opcode_m = {inst_m[4:0], 2'b11};
  wire [2:0] funct3_m = inst_m[12:10];
  wire funct7_m = inst_m[13];

  wire [6:0] opcode_wb = {inst_wb[4:0], 2'b11};
  wire [6:0] rd_wb = inst_wb[9:5];
  wire [2:0] funct3_wb = inst_wb[12:10];
  wire funct7_wb = inst_wb[13];

  always @(*) begin

  end

endmodule
