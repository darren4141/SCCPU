module if_reg (
    input wire clk,
    input wire rst,
    input wire [31:0] pc_plus4_in,
    input wire [31:0] pc_in,
    input wire [31:0] inst_in,
    input wire [17:0] control_in,
    output reg [31:0] pc_plus4_out,
    output reg [31:0] pc_out,
    output reg [31:0] inst_out,
    output reg [17:0] control_out
);

  always @(posedge clk) begin
    if (rst) begin
      pc_plus4_out <= 32'b0;
      pc_out <= 32'b0;
      inst_out <= 32'b0;
      control_out <= 18'b0;
    end else begin
      pc_plus4_out <= pc_plus4_in;
      pc_out <= pc_in;
      inst_out <= inst_in;
      control_out <= control_in;
    end
  end

endmodule
