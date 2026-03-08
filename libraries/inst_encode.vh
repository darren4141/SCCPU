function [31:0] enc_r;
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

function [31:0] enc_i;
    input [11:0] imm;
    input [4:0] rs1;
    input [2:0] funct3;
    input [4:0] rd;
    input [6:0] opcode;

    begin
        enc_i = {imm, rs1, funct3, rd, opcode};
    end
endfunction