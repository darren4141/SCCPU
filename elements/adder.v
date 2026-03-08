module adder (
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] sum
);

  always_comb begin
    sum = a + b;
  end


endmodule
