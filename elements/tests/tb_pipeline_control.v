`timescale 1ns/1ps

module tb_pipeline_control;
    `include "expect.vh"
    
    pipeline_control uut();

    initial begin
        $dumpfile("build/vcd/elements/pipeline_control_wave.vcd");
        $dumpvars(0, tb_pipeline_control);

        #10;
        $finish;
    end

endmodule
