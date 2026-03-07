`timescale 1ns/1ps

module tb_adder;

reg [31:0] a;
reg [31:0] b;
wire [31:0] sum;

adder uut(a, b, sum);

initial begin
    $dumpfile("build/vcd/adder_wave.vcd");
    $dumpvars(0, tb_adder);

    a = 5; b = 3;
    #10;

    a = 10; b = 7;
    #10;

    $finish;
end

endmodule