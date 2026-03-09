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
`define FUNCT3_BTLU 3'h6
`define FUNCT3_BGEU 3'h7

// Control macros
`define CTRL_PCSEL(x)   x[14]
`define CTRL_IMMSEL(x)  x[13:11]
`define CTRL_REGWEN(x)  x[10]
`define CTRL_BRUN(x)    x[9]
`define CTRL_BSEL(x)    x[8]
`define CTRL_ASEL(x)    x[7]
`define CTRL_ALUSEL(x)  x[6:3]
`define CTRL_MEMRW(x)   x[2]
`define CTRL_WBSEL(x)   x[1:0]

// verilog_format: on
