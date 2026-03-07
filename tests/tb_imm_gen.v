`timescale 1ns/1ps

module tb_imm_gen;

    imm_gen uut();

    initial begin
        $dumpfile("build/vcd/imm_gen_wave.vcd");
        $dumpvars(0, tb_imm_gen);

        #10;
        $finish;
    end

endmodule
