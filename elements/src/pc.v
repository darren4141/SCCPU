module pc (
    input wire clk,
    input wire rst,
    input wire en,
    input wire [31:0] in,
    output reg [31:0] out
);

  always @(posedge clk) begin
    if (rst) begin
      out <= 32'b0;
    end else if (en) begin
      out <= in;
    end
  end

endmodule
