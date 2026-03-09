`include "control_defs.vh"

module cpu_single_cycle (
    input wire clk,
    input wire rst
);

  wire [31:0] pc_cur, pc_next;

  pc u_pc (
      .clk(clk),
      .rst(rst),
      .in (pc_next),
      .out(pc_cur)
  );

  wire [31:0] pc_plus4;

  adder u_pc_adder (
      .a  (pc_cur),
      .b  (32'd4),
      .out(pc_plus4)
  );

  wire [31:0] inst;

  imem u_imem (
      .addr(pc_cur),
      .inst(inst)
  );

  wire brEQ, brLT;
  wire [14:0] control;

  control u_control (
      .inst({inst[30], inst[14:12], inst[6:2]}),
      .brEQ(brEQ),
      .brLT(brLT),
      .control(control)
  );

  wire [31:0] dataA, dataB, dataD;

  regfile u_regfile (
      .clk(clk),
      .we(`CTRL_REGWEN(control)),
      .addrA(inst[19:15]),
      .addrB(inst[24:20]),
      .addrD(inst[11:7]),
      .dataD(dataD),
      .dataA(dataA),
      .dataB(dataB)
  );

  wire brUN;

  bcomp u_bcomp (
      .dataA(dataA),
      .dataB(dataB),
      .brUN (brUN),
      .brEQ (brEQ),
      .brLT (brLT)
  );

  wire [31:0] imm;

  immgen u_immgen (
      .inst(inst),
      .ImmSel(`CTRL_IMMSEL(control)),
      .imm(imm)
  );

  wire [31:0] muxa_out;
  wire [31:0] muxb_out;

  mux_221 u_muxa (
      .in0(dataA),
      .in1(pc_cur),
      .sel(`CTRL_ASEL(control)),
      .out(muxa_out)
  );

  mux_221 u_muxb (
      .in0(dataB),
      .in1(imm),
      .sel(`CTRL_BSEL(control)),
      .out(muxb_out)
  );

  wire [31:0] aluRes;

  alu u_alu (
      .a  (muxa_out),
      .b  (muxb_out),
      .op (`CTRL_ALUSEL(control)),
      .res(aluRes)
  );

  wire [31:0] dataR;

  dmem u_dmem (
      .clk  (clk),
      .dwe  (`CTRL_MEMRW(control)),
      .addr (aluRes),
      .dataW(dataB),
      .dataR(dataR)
  );

  wire [31:0] muxwb_out;

  mux_421 u_muxwb (
      .in00(dataR),
      .in01(aluRes),
      .in10(pc_plus4),
      .in11(32'b0),
      .sel (`CTRL_WBSEL(control)),
      .out (muxwb_out)
  );

  mux_221 u_muxpc (
      .in0(pc_plus4),
      .in1(aluRes),
      .sel(`CTRL_PCSEL(control)),
      .out(pc_next)
  );

endmodule
