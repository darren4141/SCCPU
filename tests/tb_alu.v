`timescale 1ns/1ps

`include "alu_defs.vh"

module tb_alu;
    `include "expect.vh"

    reg [31:0] a;
    reg [31:0] b;
    reg [7:0] op;
    wire [31:0] result;

    alu_32b uut(a, b, op, result);

    initial begin
        $dumpfile("build/vcd/alu_wave.vcd");
        $dumpvars(0, tb_alu);

        a = 5; 
        b = 3; 
        op = `OP_PASSTHROUGH_A;
        #1
        expect_32(5, result);
        #10;

        a = 5; 
        b = 3; 
        op = `OP_PASSTHROUGH_B;
        #1
        expect_32(3, result);
        #10;

        a = 5; 
        b = 3; 
        op = `OP_ADD;
        #1
        expect_32(8, result);
        #10;

        a = 5; 
        b = 3; 
        op = `OP_SUB;
        #1
        expect_32(2, result);
        #10;

        a = 4'b0101;
        b = 4'b1001;
        op = `OP_AND;
        #1
        expect_32(4'b0001, result);
        #10;

        a = 4'b0101;
        b = 4'b1001;
        op = `OP_OR;
        #1
        expect_32(4'b1101, result);
        #10;

        a = 4'b0101;
        b = 4'b1001;
        op = `OP_XOR;
        #1
        expect_32(4'b1100, result);
        #10;

        a = 4'b0101;
        b = 2;
        op = `OP_SLL;
        #1
        expect_32(6'b010100, result);
        #10;

        a = 4'b0101;
        b = 2;
        op = `OP_SRL;
        #1
        expect_32(1, result);
        #10;

        a = 4;
        b = 2;
        op = `OP_SLT;
        #1
        expect_32(0, result);
        #10;

        a = 2;
        b = 4;
        op = `OP_SLT;
        #1
        expect_32(1, result);
        #10;

        a = 2;
        b = 4;
        op = 8'b11111111;
        #1
        expect_32(0, result);
        #10;

        $finish;
    end

endmodule