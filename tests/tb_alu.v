`include "alu_defs.vh"
`timescale 1ns/1ps

module tb_alu;

reg [31:0] a;
reg [31:0] b;
reg [7:0] op;
wire [31:0] result;

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
    op = `OP_PASSTHROUGH_A;
    expect(5);
    #10;

    a = 5; 
    b = 3; 
    op = `OP_PASSTHROUGH_B;
    expect(3);
    #10;

    a = 5; 
    b = 3; 
    op = `OP_ADD;
    expect(8);
    #10;

    a = 5; 
    b = 3; 
    op = `OP_SUB;
    expect(2);
    #10;

    a = 4'b0101;
    b = 4'b1001;
    op = `OP_AND;
    expect(4'b0001);
    #10;

    a = 4'b0101;
    b = 4'b1001;
    op = `OP_OR;
    expect(4'b1101);
    #10;

    a = 4'b0101;
    b = 4'b1001;
    op = `OP_XOR;
    expect(4'b1100);
    #10;

    a = 4'b0101;
    b = 2;
    op = `OP_SLL;
    expect(6'b010100);
    #10;

    a = 4'b0101;
    b = 2;
    op = `OP_SRL;
    expect(1);
    #10;

    a = 4;
    b = 2;
    op = `OP_SLT;
    expect(0);
    #10;

    a = 2;
    b = 4;
    op = `OP_SLT;
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