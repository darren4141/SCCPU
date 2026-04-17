`include "pipeline_psd_control_defs.vh"

module cpu_pipelined (
    input wire clk,
    input wire rst
);

  wire brEQ, brLT;
  wire [17:0] control;

  wire [31:0] inst_if_reg;
  wire [31:0] inst_id_reg;
  wire [31:0] inst_ex_reg;
  wire [31:0] inst_m_reg;
  wire [31:0] inst_wb_reg;

  pipeline_psd_control u_pipeline_psd_control (
      .inst_ex({inst_ex_reg[30], inst_ex_reg[14:12], inst_ex_reg[6:2]}),
      .inst_m({inst_m_reg[30], inst_m_reg[14:12], inst_m_reg[6:2]}),
      .inst_wb({inst_wb_reg[30], inst_wb_reg[14:12], inst_wb_reg[6:2]}),
      .brEQ(brEQ),
      .brLT(brLT),
      .control(control)
  );

  wire [1:0] fwdA;
  wire [1:0] fwdB;
  wire fwdM;

  forwarding u_forwarding (
      .inst_ex(inst_ex_reg),
      .inst_m(inst_m_reg),
      .inst_wb(inst_wb_reg),
      .RegWen(`CTRL_REGWEN(control)),
      .fwdA(fwdA),
      .fwdB(fwdB),
      .fwdM(fwdM)
  );

  wire [31:0] pc_next;
  wire [31:0] pc_if_reg;
  wire [31:0] pc_id_reg;
  wire [31:0] pc_ex_reg;

  pc u_pc (
      .clk(clk),
      .rst(rst),
      .in (pc_next),
      .out(pc_if_reg)
  );

  wire [31:0] pc_plus4_if_reg;
  wire [31:0] pc_plus4_id_reg;
  wire [31:0] pc_plus4_ex_reg;
  wire [31:0] pc_plus4_m_reg;
  wire [31:0] pc_plus4_wb_reg;

  adder u_pc_adder (
      .a  (pc_if_reg),
      .b  (32'd4),
      .sum(pc_plus4_if_reg)
  );

  imem u_imem (
      .addr(pc_if_reg),
      .inst(inst_if_reg)
  );


  if_reg u_if_reg (
      .clk(clk),
      .rst(rst),
      .pc_plus4_in(pc_plus4_if_reg),
      .pc_in(pc_if_reg),
      .inst_in(inst_if_reg),
      .pc_plus4_out(pc_plus4_id_reg),
      .pc_out(pc_id_reg),
      .inst_out(inst_id_reg)
  );

  wire [31:0] dataA_id_reg;
  wire [31:0] dataB_id_reg;
  wire [31:0] dataD;

  wire [31:0] dataA_ex_reg;
  wire [31:0] dataB_ex_reg;
  wire [31:0] dataB_m_reg;

  regfile u_regfile (
      .clk(clk),
      .we(`CTRL_REGWEN(control)),
      .addrA(inst_id_reg[19:15]),
      .addrB(inst_id_reg[24:20]),
      .addrD(inst_wb_reg[11:7]),
      .dataD(dataD),
      .dataA(dataA_id_reg),
      .dataB(dataB_id_reg)
  );

  id_reg u_id_reg (
      .clk(clk),
      .rst(rst),
      .pc_plus4_in(pc_plus4_id_reg),
      .pc_in(pc_id_reg),
      .dataA_in(dataA_id_reg),
      .dataB_in(dataB_id_reg),
      .inst_in(inst_id_reg),
      .pc_plus4_out(pc_plus4_ex_reg),
      .pc_out(pc_ex_reg),
      .dataA_out(dataA_ex_reg),
      .dataB_out(dataB_ex_reg),
      .inst_out(inst_ex_reg)
  );

  bcomp u_bcomp (
      .dataA(dataA_ex_reg),
      .dataB(dataB_ex_reg),
      .brUN (`CTRL_BRUN(control)),
      .brEQ (brEQ),
      .brLT (brLT)
  );

  wire [31:0] imm;

  imm_gen u_imm_gen (
      .inst(inst_ex_reg),
      .ImmSel(`CTRL_IMMSEL(control)),
      .imm(imm)
  );

  wire [31:0] muxa_out;
  wire [31:0] muxb_out;

  mux_421 u_muxa (
      .in00(dataA_ex_reg),
      .in01(pc_ex_reg),
      .in10(aluRes_m),
      .in11(dataD),
      .sel (fwdA[1] == 1 ? fwdA : {1'b0, `CTRL_ASEL(control)}),
      .out (muxa_out)
  );

  mux_421 u_muxb (
      .in00(dataB_ex_reg),
      .in01(imm),
      .in10(aluRes_m),
      .in11(dataD),
      .sel (fwdB[1] == 1 ? fwdB : {1'b0, `CTRL_BSEL(control)}),
      .out (muxb_out)
  );

  wire [31:0] aluRes_ex;
  wire [31:0] aluRes_m;
  wire [31:0] aluRes_wb;

  alu u_alu (
      .a  (muxa_out),
      .b  (muxb_out),
      .op (`CTRL_ALUSEL(control)),
      .res(aluRes_ex)
  );

  ex_reg u_ex_reg (
      .clk(clk),
      .rst(rst),
      .pc_plus4_in(pc_plus4_ex_reg),
      .alu_in(aluRes_ex),
      .dataB_in(dataB_ex_reg),
      .inst_in(inst_ex_reg),
      .pc_plus4_out(pc_plus4_m_reg),
      .alu_out(aluRes_m),
      .dataB_out(dataB_m_reg),
      .inst_out(inst_m_reg)
  );

  wire [31:0] dataR_m_reg;
  wire [31:0] dataR_wb_reg;

  dmem u_dmem (
      .clk  (clk),
      .dwe  (`CTRL_MEMRW(control)),
      .size (`CTRL_MEMSIZE(control)),
      .addr (aluRes_m),
      .dataW(dataB_m_reg),
      .dataR(dataR_m_reg)
  );

  m_reg u_m_reg (
      .clk(clk),
      .rst(rst),
      .pc_plus4_in(pc_plus4_m_reg),
      .alu_in(aluRes_m),
      .dataR_in(dataR_m_reg),
      .inst_in(inst_m_reg),
      .pc_plus4_out(pc_plus4_wb_reg),
      .alu_out(aluRes_wb),
      .dataR_out(dataR_wb_reg),
      .inst_out(inst_wb_reg)
  );

  mux_421 u_muxwb (
      .in00(dataR_wb_reg),
      .in01(aluRes_wb),
      .in10(pc_plus4_wb_reg),
      .in11(32'b0),
      .sel (`CTRL_WBSEL(control)),
      .out (dataD)
  );

  mux_221 u_muxpc (
      .in0(pc_plus4_if_reg),
      .in1(aluRes_wb),
      .sel(`CTRL_PCSEL(control)),
      .out(pc_next)
  );

endmodule
