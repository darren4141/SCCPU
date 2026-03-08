function automatic [31:0] enc_r;
  input [6:0] funct7;
  input [4:0] rs2;
  input [4:0] rs1;
  input [2:0] funct3;
  input [4:0] rd;
  input [6:0] opcode;

  begin
    enc_r = {funct7, rs2, rs1, funct3, rd, opcode};
  end
endfunction

function automatic [31:0] enc_i;
  input [11:0] imm;
  input [4:0] rs1;
  input [2:0] funct3;
  input [4:0] rd;
  input [6:0] opcode;

  begin
    enc_i = {imm, rs1, funct3, rd, opcode};
  end
endfunction

function automatic [31:0] enc_s;
  input [11:0] imm;
  input [4:0] rs2;
  input [4:0] rs1;
  input [2:0] funct3;
  input [6:0] opcode;

  begin
    enc_s = {imm[11:5], rs2, rs1, funct3, imm[4:0], opcode};
  end
endfunction

function automatic [31:0] enc_b;
  input [12:0] imm;
  input [4:0] rs2;
  input [4:0] rs1;
  input [2:0] funct3;
  input [6:0] opcode;

  begin
    enc_b = {imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], opcode};
  end
endfunction

function automatic [31:0] enc_u;
  input [31:0] imm;
  input [4:0] rd;
  input [6:0] opcode;

  begin
    enc_u = {imm[31:12], rd, opcode};
  end
endfunction

function automatic [31:0] enc_j;
  input [20:0] imm;
  input [4:0] rd;
  input [6:0] opcode;

  begin
    enc_u = {imm[20], imm[10:1], imm[11], imm[19:12], rd, opcode};
  end
endfunction
