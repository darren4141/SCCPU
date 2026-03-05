module alu_32b(
    input [31:0] a,
    input [31:0] b,
    input [7:0] op,
    output reg [31:0] res
);

always @(*) begin
    res = 32'b0;
    case (op)
    8'b00000000: res = a; // PASSTHROUGH_A
    8'b00000001: res = b; // PASSTHROUGH_B
    8'b00000010: res = a + b; // ADD
    8'b00000011: res = a - b; // SUB
    8'b00000100: res = a & b; // AND
    8'b00000101: res = a | b; // OR
    8'b00000110: res = a ^ b; // XOR
    8'b00000111: res = a << b[4:0]; // SLL
    8'b00001000: res = a >> b[4:0]; // SRL
    8'b00001001: res = (a < b) ? 1 : 0; // SLT
    default: res = 32'h0;
    endcase
end

endmodule