module ex_reg (
    input wire clk,
    input wire rst,
    input wire [31:0] pc_plus4_in,
    input wire [31:0] alu_in,
    input wire [31:0] dataB_in,
    input wire [31:0] inst_in,
    output reg [31:0] pc_plus4_out,
    output reg [31:0] alu_out,
    output reg [31:0] dataB_out,
    output reg [31:0] inst_out
);

  always @(posedge clk) begin
    if (rst) begin
      pc_plus4_out <= 32'b0;
      alu_out <= 32'b0;
      dataB_out <= 32'b0;
      inst_out <= 32'b0;
    end else begin
      pc_plus4_out <= pc_plus4_in;
      alu_out <= alu_in;
      dataB_out <= dataB_in;
      inst_out <= inst_in;
    end
  end

endmodule
