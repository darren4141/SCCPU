module mux_221(
    input [31:0] in0,
    input [31:0] in1,
    input sel,
    output reg [31:0] out
);

always @(*) begin
    case (sel)
    1'b0: out = in0;
    1'b1: out = in1;
    default: out = 32'b0;
    endcase
end

endmodule

module mux_421(
    input [31:0] in00,
    input [31:0] in01,
    input [31:0] in10,
    input [31:0] in11,
    input [1:0] sel,
    output reg [31:0] out
);

always @(*) begin
    case (sel)
    2'b00: out = in00;
    2'b01: out = in01;
    2'b10: out = in10;
    2'b11: out = in11;
    default: out = 32'b0;
    endcase
end

endmodule

module mux_821(
    input [31:0] in000,
    input [31:0] in001,
    input [31:0] in010,
    input [31:0] in011,
    input [31:0] in100,
    input [31:0] in101,
    input [31:0] in110,
    input [31:0] in111,
    input [2:0] sel,
    output reg [31:0] out
);

always @(*) begin
    case (sel)
    3'b000: out = in000;
    3'b001: out = in001;
    3'b010: out = in010;
    3'b011: out = in011;
    3'b100: out = in100;
    3'b101: out = in101;
    3'b110: out = in110;
    3'b111: out = in111;
    default: out = 32'b0;
    endcase
end

endmodule
