`include "mem.vh"
`timescale 1ns / 1ps

module tb_cpu_add;
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
    $readmemh("build/hex/cpu_add_program.hex", dut.u_imem.inst_mem, 0, `IMEM_SIZE - 1);
  end

  initial begin
`ifdef CPU_PIPELINED
    $dumpfile("build/vcd/projects/pipelined/tb_cpu_add.vcd");
    $dumpvars(0, tb_cpu_add);
`else
    $dumpfile("build/vcd/projects/single_cycle/tb_cpu_add.vcd");
    $dumpvars(0, tb_cpu_add);
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
      // $display(
      //     "inst_if_reg: %d\ninst_id_reg: %d\ninst_ex_reg: %d\ninst_m_reg: %d\ninst_wb_reg: %d\n",
      //     dut.inst_if_reg, dut.inst_id_reg, dut.inst_ex_reg, dut.inst_m_reg, dut.inst_wb_reg);
      // $display("rd: %d rs1: %d rs2: %d\n dataD: %d reg[rs1]: $d reg[rs2]: %d\n",
      //          dut.u_regfile.addrD, dut.u_regfile.addrA, dut.u_regfile.addrB, dut.u_regfile.dataD,
      //          dut.u_regfile.dataA, dut.u_regfile.dataB);
      // $display("immGen: %d aluin1: %d aluin2: %d aluOp: %d aluRes: %d\n", dut.u_imm_gen.imm,
      //          dut.u_alu.a, dut.u_alu.b, dut.u_alu.op, dut.u_alu.res);

      // $display(
      //     "CONTROL: PCSEL=%b IMMSEL=%b REGWEN=%b BRUN=%b BSEL=%b ASEL=%b ALUSEL=%b MEMRW=%b MEMSIZE=%b WBSEL=%b\n",
      //     `CTRL_PCSEL(dut.control), `CTRL_IMMSEL(dut.control), `CTRL_REGWEN(dut.control),
      //     `CTRL_BRUN(dut.control), `CTRL_BSEL(dut.control), `CTRL_ASEL(dut.control),
      //     `CTRL_ALUSEL(dut.control), `CTRL_MEMRW(dut.control), `CTRL_MEMSIZE(dut.control),
      //     `CTRL_WBSEL(dut.control));
    end

    // TEST CODE

    expect_32(32'd0, `REG_X0);
    expect_32(32'd5, `REG_X1);
    expect_32(32'd14, `REG_X2);
    expect_32(32'd19, `REG_X3);

    $finish;
  end

endmodule
