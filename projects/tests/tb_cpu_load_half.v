`include "mem.vh"
`timescale 1ns / 1ps

module tb_cpu_load_half;
  `include "expect.vh"
  `include "regfile_access.vh"

  reg clk;
  reg rst;

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
    $readmemh("build/hex/cpu_load_half_program.hex", dut.u_imem.inst_mem, 0, `IMEM_SIZE - 1);
  end

  initial begin
`ifdef CPU_PIPELINED
    $dumpfile("build/vcd/projects/pipelined/tb_cpu_load_half.vcd");
    $dumpvars(0, tb_cpu_load_half);
`else
    $dumpfile("build/vcd/projects/single_cycle/tb_cpu_load_half.vcd");
    $dumpvars(0, tb_cpu_load_half);
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

    repeat (50) @(posedge clk);

    // TEST CODE
    // Stored value: 0x1234
    // x4 = lhu from address 0 (lower half-word) = 0x1234
    // x5 = lhu from address 2 (upper half-word) = 0x0000

    expect_32(32'd0, `REG_X0);  // x0 alwsays 0
    expect_32(32'h1234, `REG_X4);  // Lower half-word loaded
    expect_32(32'h0000, `REG_X5);  // Upper half-word (zero-extended)

    $finish;
  end

endmodule
