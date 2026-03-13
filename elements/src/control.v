`include "constants.vh"
`include "control_defs.vh"
`include "alu_defs.vh"
`include "imm_gen.vh"
`include "mem.vh"

module control (
    input wire [8:0] inst,
    input wire brEQ,
    input wire brLT,
    output reg [17:0] control
);

  wire [6:0] opcode = {inst[4:0], 2'b11};
  wire [2:0] funct3 = inst[7:5];
  wire funct7 = inst[8];

  always @(*) begin
    control = 18'b0;
    case (opcode)

      /* R-Format Arithmetic Operations
        - PCSel = 0
        - ImmSel = DC
        - RegWen = 1
        - BrUN = DC
        - bSel = 0
        - aSel = 0
        - ALUSel based on funct3 and funct7
        - MemRW = 0
        - MemSize = DC
        - WBSel = 1
    */
      `OPCODE_ARITH_OP: begin
        control = {
          1'b0,  // PCSel
          `FORMAT_INVALID,  // ImmSel
          1'b1,  // RegWen
          1'b0,  // brUN
          1'b0,  //bSel
          1'b0,  //aSel
          `OP_INVALID,  //ALUSel
          1'b0,  // MemRW
          `DMEM_TYPE_INVALID,  // MemSize
          2'b01  // WBSel
        };

        case (funct3)
          `FUNCT3_ADD_SUB: begin
            case (funct7)
              7'h0:    `CTRL_ALUSEL(control) = `OP_ADD;
              7'h20:   `CTRL_ALUSEL(control) = `OP_SUB;
              default: `CTRL_ALUSEL(control) = `OP_INVALID;
            endcase
          end
          `FUNCT3_XOR:  `CTRL_ALUSEL(control) = `OP_XOR;
          `FUNCT3_OR:   `CTRL_ALUSEL(control) = `OP_OR;
          `FUNCT3_AND:  `CTRL_ALUSEL(control) = `OP_AND;
          `FUNCT3_SLL:  `CTRL_ALUSEL(control) = `OP_SLL;
          `FUNCT3_SRL_SRA: begin
            case (funct7)
              7'h0:    `CTRL_ALUSEL(control) = `OP_SRL;
              7'h20:   `CTRL_ALUSEL(control) = `OP_SRA;
              default: `CTRL_ALUSEL(control) = `OP_INVALID;
            endcase
          end
          `FUNCT3_SLT:  `CTRL_ALUSEL(control) = `OP_SLT;
          `FUNCT3_SLTU: `CTRL_ALUSEL(control) = `OP_SLTU;
          default: `CTRL_ALUSEL(control) = `OP_INVALID;
        endcase

      end
      /* Immediate Arithmetic Operations
        - PCSel = 0
        - ImmSel = I
        - RegWen = 1
        - BrUN = DC
        - bSel = 1
        - aSel = 0
        - ALUSel based on funct3 and funct7
        - MemRW = 0
        - MemSize = DC
        - WBSel = 1
    */

      `OPCODE_ARITH_OP_IMM: begin
        control = {
          1'b0,  // PCSel
          `FORMAT_I,  // ImmSel
          1'b1,  // RegWen
          1'b0,  // brUN
          1'b1,  //bSel
          1'b0,  //aSel
          `OP_INVALID,  //ALUSel
          1'b0,  // MemRW
          `DMEM_TYPE_INVALID,  // MemSize
          2'b01  // WBSel
        };

        case (funct3)
          `FUNCT3_ADD_SUB: `CTRL_ALUSEL(control) = `OP_ADD;
          `FUNCT3_XOR:     `CTRL_ALUSEL(control) = `OP_XOR;
          `FUNCT3_OR:      `CTRL_ALUSEL(control) = `OP_OR;
          `FUNCT3_AND:     `CTRL_ALUSEL(control) = `OP_AND;
          `FUNCT3_SLL:     `CTRL_ALUSEL(control) = `OP_SLL;
          `FUNCT3_SRL_SRA: begin
            case (funct7)
              7'h0:    `CTRL_ALUSEL(control) = `OP_SRL;
              7'h20:   `CTRL_ALUSEL(control) = `OP_SRA;
              default: `CTRL_ALUSEL(control) = `OP_INVALID;
            endcase
          end
          `FUNCT3_SLT:     `CTRL_ALUSEL(control) = `OP_SLT;
          `FUNCT3_SLTU:    `CTRL_ALUSEL(control) = `OP_SLTU;
          default:         `CTRL_ALUSEL(control) = `OP_INVALID;
        endcase

      end

      /* Load Operations
        - PCSel = 0
        - ImmSel = I
        - RegWen = 1
        - BrUN = DC
        - bSel = 1
        - aSel = 0
        - ALUSel = OP_ADD
        - MemRW = 0
        - MemSize = DC
        - WBSel = 0
    */

      `OPCODE_LOAD: begin
        control = {
          1'b0,  // PCSel
          `FORMAT_I,  // ImmSel
          1'b1,  // RegWen
          1'b0,  // brUN
          1'b1,  //bSel
          1'b0,  //aSel
          `OP_ADD,  //ALUSel
          1'b0,  // MemRW
          `DMEM_TYPE_INVALID,  // MemSize
          2'b00  // WBSel
        };

        case (funct3)
          `FUNCT3_LB: `CTRL_MEMSIZE(control) = `DMEM_TYPE_B;
          `FUNCT3_LH: `CTRL_MEMSIZE(control) = `DMEM_TYPE_H;
          `FUNCT3_LW: `CTRL_MEMSIZE(control) = `DMEM_TYPE_W;
          `FUNCT3_LBU: `CTRL_MEMSIZE(control) = `DMEM_TYPE_BU;
          `FUNCT3_LHU: `CTRL_MEMSIZE(control) = `DMEM_TYPE_HU;
          default: ;
        endcase
      end

      /* Store Operations
        - PCSel = 0
        - ImmSel = S
        - RegWen = 0
        - BrUN = DC
        - bSel = 1
        - aSel = 0
        - ALUSel = OP_ADD
        - MemRW = 1
        - MemSize = DC
        - WBSel = DC
    */

      `OPCODE_STORE: begin
        control = {
          1'b0,  // PCSel
          `FORMAT_S,  // ImmSel
          1'b0,  // RegWen
          1'b0,  // brUN
          1'b1,  //bSel
          1'b0,  //aSel
          `OP_ADD,  //ALUSel
          1'b1,  // MemRW
          `DMEM_TYPE_INVALID,  // MemSize
          2'b00  // WBSel
        };

        case (funct3)
          `FUNCT3_SB: `CTRL_MEMSIZE(control) = `DMEM_TYPE_B;
          `FUNCT3_SH: `CTRL_MEMSIZE(control) = `DMEM_TYPE_H;
          `FUNCT3_SW: `CTRL_MEMSIZE(control) = `DMEM_TYPE_W;
          default: ;
        endcase
      end

      /* Branch Operations
        - PCSel = 0 - no branch, 1 - take the branch. Based on result of brLT, brEQ and funct3
        - ImmSel = B
        - RegWen = 0
        - BrUN = Based on funct3
        - bSel = 1
        - aSel = 1
        - ALUSel = OP_ADD
        - MemRW = 0
        - MemSize = DC
        - WBSel = DC
    */

      `OPCODE_BRANCH: begin
        control = {
          1'b0,  // PCSel
          `FORMAT_B,  // ImmSel
          1'b0,  // RegWen
          1'b0,  // brUN
          1'b1,  //bSel
          1'b1,  //aSel
          `OP_ADD,  //ALUSel
          1'b0,  // MemRW
          `DMEM_TYPE_INVALID,  // MemSize
          2'b00  // WBSel
        };
        case (funct3)
          `FUNCT3_BEQ, `FUNCT3_BNE, `FUNCT3_BLT, `FUNCT3_BGE: `CTRL_BRUN(control) = 0;
          `FUNCT3_BTLU, `FUNCT3_BGEU: `CTRL_BRUN(control) = 1;
          default: `CTRL_BRUN(control) = 0;
        endcase

        case (funct3)
          `FUNCT3_BEQ: `CTRL_PCSEL(control) = brEQ;
          `FUNCT3_BNE: `CTRL_PCSEL(control) = ~brEQ;
          `FUNCT3_BLT, `FUNCT3_BTLU: `CTRL_PCSEL(control) = brLT;
          `FUNCT3_BGE, `FUNCT3_BGEU: `CTRL_PCSEL(control) = ~brLT;
          default: `CTRL_PCSEL(control) = 0;
        endcase

      end

      /* J-format Jump Operations (jal)
        - PCSel = 1
        - ImmSel = J
        - RegWen = 1
        - BrUN = DC
        - bSel = 1
        - aSel = 1
        - ALUSel = OP_ADD
        - MemRW = 0
        - MemSize = DC
        - WBSel = 2
    */

      `OPCODE_JAL: begin
        control = {
          1'b1,  // PCSel
          `FORMAT_J,  // ImmSel
          1'b1,  // RegWen
          1'b0,  // brUN
          1'b1,  //bSel
          1'b1,  //aSel
          `OP_ADD,  //ALUSel
          1'b0,  // MemRW
          `DMEM_TYPE_INVALID,  // MemSize
          2'b10  // WBSel
        };
      end

      /* I-format Jump Operations (jalr)
        - PCSel = 1
        - ImmSel = I
        - RegWen = 1
        - BrUN = DC
        - bSel = 1
        - aSel = 0
        - ALUSel = OP_ADD
        - MemRW = 0
        - MemSize = DC
        - WBSel = 2
    */

      `OPCODE_JALR: begin
        control = {
          1'b1,  // PCSel
          `FORMAT_I,  // ImmSel
          1'b1,  // RegWen
          1'b0,  // brUN
          1'b1,  //bSel
          1'b0,  //aSel
          `OP_ADD,  //ALUSel
          1'b0,  // MemRW
          `DMEM_TYPE_INVALID,  // MemSize
          2'b10  // WBSel
        };
      end

      /* U-format (lui)
        - PCSel = 0
        - ImmSel = U
        - RegWen = 1
        - BrUN = DC
        - bSel = 1
        - aSel = DC
        - ALUSel = OP_PASSTHROUGH_B
        - MemRW = 0
        - MemSize = DC
        - WBSel = 2
    */

      `OPCODE_JALR: begin
        control = {
          1'b0,  // PCSel
          `FORMAT_U,  // ImmSel
          1'b1,  // RegWen
          1'b0,  // brUN
          1'b1,  //bSel
          1'b0,  //aSel
          `OP_PASSTHROUGH_B,  //ALUSel
          1'b0,  // MemRW
          `DMEM_TYPE_INVALID,  // MemSize
          2'b10  // WBSel
        };
      end

      /* U-format (auipc)
        - PCSel = 0
        - ImmSel = U
        - RegWen = 1
        - BrUN = DC
        - bSel = 1
        - aSel = 1
        - ALUSel = OP_ADD
        - MemRW = 0
        - MemSize = DC
        - WBSel = 2
    */

      `OPCODE_AUIPC: begin
        control = {
          1'b0,  // PCSel
          `FORMAT_U,  // ImmSel
          1'b1,  // RegWen
          1'b0,  // brUN
          1'b1,  //bSel
          1'b1,  //aSel
          `OP_ADD,  //ALUSel
          1'b0,  // MemRW
          `DMEM_TYPE_INVALID,  // MemSize
          2'b10  // WBSel
        };
      end

      default: control = 14'b0;
    endcase

  end

endmodule
