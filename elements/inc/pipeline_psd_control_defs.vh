// verilog_format: off

// R-format funct3 definitions
`define FUNCT3_ADD_SUB 3'h0
`define FUNCT3_XOR 3'h4
`define FUNCT3_OR 3'h6
`define FUNCT3_AND 3'h7
`define FUNCT3_SLL 3'h1
`define FUNCT3_SRL_SRA 3'h5
`define FUNCT3_SLT 3'h2
`define FUNCT3_SLTU 3'h3

// B-format funct3 definitions
`define FUNCT3_BEQ 3'h0
`define FUNCT3_BNE 3'h1
`define FUNCT3_BLT 3'h4
`define FUNCT3_BGE 3'h5
`define FUNCT3_BLTU 3'h6
`define FUNCT3_BGEU 3'h7

// I-format load funct3 definitions
`define FUNCT3_LB 3'h0
`define FUNCT3_LH 3'h1
`define FUNCT3_LW 3'h2
`define FUNCT3_LBU 3'h4
`define FUNCT3_LHU 3'h5

// S-format store funct3 definitions
`define FUNCT3_SB 3'h0
`define FUNCT3_SH 3'h1
`define FUNCT3_SW 3'h2

// Control macros
// Fields modified with inst_ex
`define CTRL_PCSEL(x)   x[17]
`define CTRL_IMMSEL(x)  x[16:14]
`define CTRL_ALUSEL(x)  x[13:10]
`define CTRL_ASEL(x)    x[9]
`define CTRL_BSEL(x)    x[8]
`define CTRL_BRUN(x)    x[7]

// Fields modified with inst_m
`define CTRL_MEMRW(x)   x[6]
`define CTRL_MEMSIZE(x) x[5:3]

// Fields modified with inst_wb
`define CTRL_REGWEN(x)  x[2]
`define CTRL_WBSEL(x)   x[1:0]

// control_ex specific macros
`define CTRL_EX_PCSEL(x)   x[10]
`define CTRL_EX_IMMSEL(x)  x[9:7]
`define CTRL_EX_ALUSEL(x)  x[6:3]
`define CTRL_EX_ASEL(x)    x[2]
`define CTRL_EX_BSEL(x)    x[1]
`define CTRL_EX_BRUN(x)    x[0]

// control_m specific macros
`define CTRL_M_MEMRW(x)   x[3]
`define CTRL_M_MEMSIZE(x) x[2:0]

// control_wb specific macros
`define CTRL_WB_REGWEN(x)  x[2]
`define CTRL_WB_WBSEL(x)   x[1:0]

// verilog_format: on
