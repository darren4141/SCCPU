`include "mem.vh"
`timescale 1ns / 1ps

module tb_cpu_auipc;
  `include "expect.vh"
  `include "regfile_access.vh"

  reg clk;
  reg rst;
  integer i;

`ifdef CPU_PIPELINED
  cpu_pipelined dut (
      .clk(clk),
      .rst(rst)
  );
`else
  cpu_single_cycle dut (
      .clk(clk),
      .rst(rst)
  );
`endif

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $readmemh("build/hex/cpu_auipc_program.hex", dut.u_imem.inst_mem, 0, `IMEM_SIZE - 1);
  end

  initial begin
`ifdef CPU_PIPELINED
    $dumpfile("build/vcd/projects/pipelined/tb_cpu_auipc.vcd");
    $dumpvars(0, tb_cpu_auipc);
`else
    $dumpfile("build/vcd/projects/single_cycle/tb_cpu_auipc.vcd");
    $dumpvars(0, tb_cpu_auipc);
`endif

`ifdef CPU_PIPELINED
    $display("PIPELINED CPU TEST");
`else
    $display("SINGLE CYCLE CPU TEST");
`endif

    #10;
    rst = 1;
    #10;
    rst = 0;

    for (i = 1; i < 50; i = i + 1) begin
      repeat (1) @(posedge clk);
      // Add debugging messages here...
    end

    // TEST CODE

    expect_32(32'd0, `REG_X0);
    expect_32(32'd0, `REG_X1);
    expect_32(32'd4, `REG_X2);
    expect_32(32'h1008, `REG_X3);

    $finish;
  end

endmodule
