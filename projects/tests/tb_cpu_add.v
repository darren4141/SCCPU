`include "mem.vh"
`timescale 1ns / 1ps

module tb_cpu_add;
  `include "expect.vh"

  reg clk;
  reg rst;

  cpu_single_cycle dut (
      .clk(clk),
      .rst(rst)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $readmemh("build/hex/cpu_add_program.hex", dut.u_imem.inst_mem, 0, `IMEM_SIZE - 1);
  end

  initial begin
    $dumpfile("build/vcd/projects/tb_cpu_add.vcd");
    $dumpvars(0, tb_cpu_add);

    #10;
    rst = 1;
    #10;
    rst = 0;

    repeat (20) @(posedge clk);

    expect_32(32'd5, dut.u_regfile.regfile[1]);
    expect_32(32'd14, dut.u_regfile.regfile[2]);
    expect_32(32'd19, dut.u_regfile.regfile[3]);

    $finish;
  end

endmodule
