module pc (
    input wire clk,
    input wire rst,
    input wire [31:0] in,
    output reg [31:0] out
);

  always @(posedge clk) begin
    if (rst) out <= 32'b0;
    else out <= in;
  end

endmodule
