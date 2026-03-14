`include "mem.vh"
`timescale 1ns / 1ps

module tb_cpu_auipc;
  `include "expect.vh"
  `include "regfile_access.vh"

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
    $readmemh("build/hex/cpu_auipc_program.hex", dut.u_imem.inst_mem, 0, `IMEM_SIZE - 1);
  end

  initial begin
    $dumpfile("build/vcd/projects/tb_cpu_auipc.vcd");
    $dumpvars(0, tb_cpu_auipc);

    #10;
    rst = 1;
    #10;
    rst = 0;

    repeat (10) @(posedge clk);

    // TEST CODE

    expect_32(32'd0, `REG_X0);
    expect_32(32'd0, `REG_X1);
    expect_32(32'd4, `REG_X2);
    expect_32(32'h1008, `REG_X3);

    $finish;
  end

endmodule
