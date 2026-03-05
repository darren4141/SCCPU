`timescale 1ns/1ps

module tb_alu;

reg [31:0] a;
reg [31:0] b;
reg [7:0] op;
wire [31:0] result;

localparam OP_PASSTHROUGH_A = 8'b00000000;
localparam OP_PASSTHROUGH_B = 8'b00000001;
localparam OP_ADD = 8'b00000010;
localparam OP_SUB = 8'b00000011;
localparam OP_AND = 8'b00000100;
localparam OP_OR = 8'b00000101;
localparam OP_XOR = 8'b00000110;
localparam OP_SLL = 8'b00000111;
localparam OP_SRL = 8'b00001000;
localparam OP_SLT = 8'b00001001;

alu_32b uut(a, b, op, result);

task expect;
    input [31:0] expected;
    begin
        #1;
        if (result != expected) begin
            $display("FAIL: expected %0d got %0d", expected, result);
            $finish;
        end
        else
            $display("PASS");
    end
endtask

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_alu);

    a = 5; 
    b = 3; 
    op = OP_PASSTHROUGH_A;
    expect(5);
    #10;

    a = 5; 
    b = 3; 
    op = OP_PASSTHROUGH_B;
    expect(3);
    #10;

    a = 5; 
    b = 3; 
    op = OP_ADD;
    expect(8);
    #10;

    a = 5; 
    b = 3; 
    op = OP_SUB;
    expect(2);
    #10;

    a = 4'b0101;
    b = 4'b1001;
    op = OP_AND;
    expect(4'b0001);
    #10;

    a = 4'b0101;
    b = 4'b1001;
    op = OP_OR;
    expect(4'b1101);
    #10;

    a = 4'b0101;
    b = 4'b1001;
    op = OP_XOR;
    expect(4'b1100);
    #10;

    a = 4'b0101;
    b = 2;
    op = OP_SLL;
    expect(6'b010100);
    #10;

    a = 4'b0101;
    b = 2;
    op = OP_SRL;
    expect(1);
    #10;

    a = 4;
    b = 2;
    op = OP_SLT;
    expect(0);
    #10;

    a = 2;
    b = 4;
    op = OP_SLT;
    expect(1);
    #10;

    a = 2;
    b = 4;
    op = 8'b11111111;
    expect(0);
    #10;

    $finish;
end

endmodule