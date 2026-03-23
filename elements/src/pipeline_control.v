`include "constants.vh"
`include "pipeline_control_defs.vh"
`include "alu_defs.vh"
`include "imm_gen.vh"
`include "mem.vh"

module pipeline_control (
    input wire [8:0] inst_ex,
    input wire [8:0] inst_m,
    input wire [8:0] inst_wb,
    input wire brEQ,
    input wire brLT,
    output reg [17:0] control
);

  wire [6:0] opcode_ex = {inst_ex[4:0], 2'b11};
  wire [2:0] funct3_ex = inst_ex[7:5];
  wire funct7_ex = inst_ex[8];

  wire [6:0] opcode_m = {inst_m[4:0], 2'b11};
  wire [2:0] funct3_m = inst_m[7:5];
  wire funct7_m = inst_m[8];

  wire [6:0] opcode_wb = {inst_wb[4:0], 2'b11};
  wire [2:0] funct3_wb = inst_wb[7:5];
  wire funct7_wb = inst_wb[8];

  reg [10:0] control_ex;
  reg [3:0] control_m;
  reg [2:0] control_wb;

  always @(*) begin
    control = 18'b0;

    case (opcode_ex)

      /* R-Format Arithmetic Operations
        - PCSel = 0
        - ImmSel = DC
        - ALUSel based on funct3 and funct7
        - aSel = 0
        - bSel = 0
        - BrUN = DC
    */
      `OPCODE_ARITH_OP: begin
        control_ex = {
          1'b0,  // PCSel
          `FORMAT_INVALID,  // ImmSel
          `OP_INVALID,
          1'b0,  //aSel
          1'b0,  //bSel
          1'b0  // brUN
        };

        case (funct3_ex)
          `FUNCT3_ADD_SUB: begin
            case (funct7_ex)
              1'h0:    `CTRL_EX_ALUSEL(control_ex) = `OP_ADD;
              1'h1:   `CTRL_EX_ALUSEL(control_ex) = `OP_SUB;
              default: `CTRL_EX_ALUSEL(control_ex) = `OP_INVALID;
            endcase
          end
          `FUNCT3_XOR:  `CTRL_EX_ALUSEL(control_ex) = `OP_XOR;
          `FUNCT3_OR:   `CTRL_EX_ALUSEL(control_ex) = `OP_OR;
          `FUNCT3_AND:  `CTRL_EX_ALUSEL(control_ex) = `OP_AND;
          `FUNCT3_SLL:  `CTRL_EX_ALUSEL(control_ex) = `OP_SLL;
          `FUNCT3_SRL_SRA: begin
            case (funct7_ex)
              1'h0:    `CTRL_EX_ALUSEL(control_ex) = `OP_SRL;
              1'h1:   `CTRL_EX_ALUSEL(control_ex) = `OP_SRA;
              default: `CTRL_EX_ALUSEL(control_ex) = `OP_INVALID;
            endcase
          end
          `FUNCT3_SLT:  `CTRL_EX_ALUSEL(control_ex) = `OP_SLT;
          `FUNCT3_SLTU: `CTRL_EX_ALUSEL(control_ex) = `OP_SLTU;
          default: `CTRL_EX_ALUSEL(control_ex) = `OP_INVALID;
        endcase
      end

      /* Immediate Arithmetic Operations
        - PCSel = 0
        - ImmSel = I
        - ALUSel based on funct3 and funct7
        - aSel = 0
        - bSel = 1
        - BrUN = DC
    */
      `OPCODE_ARITH_OP_IMM: begin
        control_ex = {
          1'b0,  // PCSel
          `FORMAT_I,  // ImmSel
          `OP_INVALID,
          1'b0,  //aSel
          1'b1,  //bSel
          1'b0  // brUN
        };

        case (funct3_ex)
          `FUNCT3_ADD_SUB: `CTRL_EX_ALUSEL(control_ex) = `OP_ADD;
          `FUNCT3_XOR:     `CTRL_EX_ALUSEL(control_ex) = `OP_XOR;
          `FUNCT3_OR:      `CTRL_EX_ALUSEL(control_ex) = `OP_OR;
          `FUNCT3_AND:     `CTRL_EX_ALUSEL(control_ex) = `OP_AND;
          `FUNCT3_SLL:     `CTRL_EX_ALUSEL(control_ex) = `OP_SLL;
          `FUNCT3_SRL_SRA: begin
            case (funct7_ex)
              1'h0:    `CTRL_EX_ALUSEL(control_ex) = `OP_SRL;
              1'h1:   `CTRL_EX_ALUSEL(control_ex) = `OP_SRA;
              default: `CTRL_EX_ALUSEL(control_ex) = `OP_INVALID;
            endcase
          end
          `FUNCT3_SLT:     `CTRL_EX_ALUSEL(control_ex) = `OP_SLT;
          `FUNCT3_SLTU:    `CTRL_EX_ALUSEL(control_ex) = `OP_SLTU;
          default:         `CTRL_EX_ALUSEL(control_ex) = `OP_INVALID;
        endcase

      end

      /* Load Operations
        - PCSel = 0
        - ImmSel = I
        - ALUSel = OP_ADD
        - aSel = 0
        - bSel = 1
        - BrUN = DC
    */

      `OPCODE_LOAD: begin
        control_ex = {
          1'b0,  // PCSel
          `FORMAT_I,  // ImmSel
          `OP_ADD,
          1'b0,  //aSel
          1'b1,  //bSel
          1'b0  // brUN
        };
      end

      /* Store Operations
        - PCSel = 0
        - ImmSel = S
        - ALUSel = OP_ADD
        - aSel = 0
        - bSel = 1
        - BrUN = DC
    */

      `OPCODE_STORE: begin
        control_ex = {
          1'b0,  // PCSel
          `FORMAT_S,  // ImmSel
          `OP_ADD,
          1'b0,  //aSel
          1'b1,  //bSel
          1'b0  // brUN
        };
      end

      /* Branch Operations
        - PCSel = 0 - no branch, 1 - take the branch. Based on result of brLT, brEQ and funct3
        - ImmSel = B
        - ALUSel = OP_ADD
        - aSel = 1
        - bSel = 1
        - BrUN = Based on funct3
    */
      `OPCODE_BRANCH: begin
        control_ex = {
          1'b0,  // PCSel
          `FORMAT_B,  // ImmSel
          `OP_ADD,
          1'b1,  //aSel
          1'b1,  //bSel
          1'b0  // brUN
        };

        case (funct3_ex)
          `FUNCT3_BEQ, `FUNCT3_BNE, `FUNCT3_BLT, `FUNCT3_BGE: `CTRL_EX_BRUN(control_ex) = 0;
          `FUNCT3_BLTU, `FUNCT3_BGEU: `CTRL_EX_BRUN(control_ex) = 1;
          default: `CTRL_EX_BRUN(control_ex) = 0;
        endcase

        case (funct3_ex)
          `FUNCT3_BEQ: `CTRL_EX_PCSEL(control_ex) = brEQ;
          `FUNCT3_BNE: `CTRL_EX_PCSEL(control_ex) = ~brEQ;
          `FUNCT3_BLT, `FUNCT3_BLTU: `CTRL_EX_PCSEL(control_ex) = brLT;
          `FUNCT3_BGE, `FUNCT3_BGEU: `CTRL_EX_PCSEL(control_ex) = ~brLT;
          default: `CTRL_EX_PCSEL(control_ex) = 0;
        endcase
      end

      /* J-format Jump Operations (jal)
        - PCSel = 1
        - ImmSel = J
        - ALUSel = OP_ADD
        - aSel = 1
        - bSel = 1
        - BrUN = DC
    */

      `OPCODE_JAL: begin
        control_ex = {
          1'b1,  // PCSel
          `FORMAT_J,  // ImmSel
          `OP_ADD,
          1'b1,  //aSel
          1'b1,  //bSel
          1'b0  // brUN
        };
      end

      /* I-format Jump Operations (jalr)
        - PCSel = 1
        - ImmSel = I
        - ALUSel = OP_ADD
        - aSel = 0
        - bSel = 1
        - BrUN = DC
    */

      `OPCODE_JALR: begin
        control_ex = {
          1'b1,  // PCSel
          `FORMAT_I,  // ImmSel
          `OP_ADD,
          1'b0,  //aSel
          1'b1,  //bSel
          1'b0  // brUN
        };
      end


      /* U-format (lui)
        - PCSel = 0
        - ImmSel = U
        - ALUSel = OP_PASSTHROUGH_B
        - aSel = DC
        - bSel = 1
        - BrUN = DC
    */

      `OPCODE_LUI: begin
        control_ex = {
          1'b0,  // PCSel
          `FORMAT_U,  // ImmSel
          `OP_PASSTHROUGH_B,
          1'b0,  //aSel
          1'b1,  //bSel
          1'b0  // brUN
        };
      end

      /* U-format (auipc)
        - PCSel = 0
        - ImmSel = U
        - ALUSel = OP_ADD
        - aSel = 1
        - bSel = 1
        - BrUN = DC
    */
      `OPCODE_AUIPC: begin
        control_ex = {
          1'b0,  // PCSel
          `FORMAT_U,  // ImmSel
          `OP_ADD,
          1'b1,  //aSel
          1'b1,  //bSel
          1'b0  // brUN
        };
      end

      default: control_ex = 11'b0;

    endcase

    case (opcode_m)
      /* R-Format Arithmetic Operations
        - MemRW = 0
        - MemSize = DC
    */

      `OPCODE_ARITH_OP: begin
        control_m = {
          1'b0,  // MemRW
          `DMEM_TYPE_INVALID  // MemSize
        };
      end

      /* Immediate Arithmetic Operations
        - MemRW = 0
        - MemSize = DC
    */

      `OPCODE_ARITH_OP_IMM: begin
        control_m = {
          1'b0,  // MemRW
          `DMEM_TYPE_INVALID  // MemSize
        };
      end

      /* Load Operations
        - MemRW = 0
        - MemSize = depends on funct3
    */

      `OPCODE_LOAD: begin
        control_m = {
          1'b0,  // MemRW
          `DMEM_TYPE_INVALID  // MemSize
        };

        case (funct3_m)
          `FUNCT3_LB: `CTRL_M_MEMSIZE(control_m) = `DMEM_TYPE_B;
          `FUNCT3_LH: `CTRL_M_MEMSIZE(control_m) = `DMEM_TYPE_H;
          `FUNCT3_LW: `CTRL_M_MEMSIZE(control_m) = `DMEM_TYPE_W;
          `FUNCT3_LBU: `CTRL_M_MEMSIZE(control_m) = `DMEM_TYPE_BU;
          `FUNCT3_LHU: `CTRL_M_MEMSIZE(control_m) = `DMEM_TYPE_HU;
          default: ;
        endcase

      end

      /* Store Operations
        - MemRW = 1
        - MemSize = depends on funct3
    */

      `OPCODE_STORE: begin
        control_m = {
          1'b1,  // MemRW
          `DMEM_TYPE_INVALID  // MemSize
        };

        case (funct3_m)
          `FUNCT3_SB: `CTRL_M_MEMSIZE(control_m) = `DMEM_TYPE_B;
          `FUNCT3_SH: `CTRL_M_MEMSIZE(control_m) = `DMEM_TYPE_H;
          `FUNCT3_SW: `CTRL_M_MEMSIZE(control_m) = `DMEM_TYPE_W;
          default: ;
        endcase
      end

      /* Branch Operations
        - MemRW = 0
        - MemSize = DC
    */

      `OPCODE_BRANCH: begin
        control_m = {
          1'b0,  // MemRW
          `DMEM_TYPE_INVALID  // MemSize
        };
      end

      /* J-format Jump Operations (jal)
        - MemRW = 0
        - MemSize = DC
    */

      `OPCODE_JAL: begin
        control_m = {
          1'b0,  // MemRW
          `DMEM_TYPE_INVALID  // MemSize
        };
      end

      /* I-format Jump Operations (jalr)
        - MemRW = 0
        - MemSize = DC
    */

      `OPCODE_JALR: begin
        control_m = {
          1'b0,  // MemRW
          `DMEM_TYPE_INVALID  // MemSize
        };
      end

      /* U-format (lui)
        - MemRW = 0
        - MemSize = DC
    */

      `OPCODE_LUI: begin
        control_m = {
          1'b0,  // MemRW
          `DMEM_TYPE_INVALID  // MemSize
        };
      end

      /* U-format (auipc)
        - MemRW = 0
        - MemSize = DC
    */

      `OPCODE_AUIPC: begin
        control_m = {
          1'b0,  // MemRW
          `DMEM_TYPE_INVALID  // MemSize
        };
      end

      default: control_m = 4'b0;
    endcase

    case (opcode_wb)
      /* R-Format Arithmetic Operations
        - RegWen = 1
        - WBSel = 1
    */

      `OPCODE_ARITH_OP: begin
        control_wb = {
          1'b1,  // RegWen
          2'b01  // WBSel
        };
      end

      /* Immediate Arithmetic Operations
        - RegWen = 1
        - WBSel = 1
    */

      `OPCODE_ARITH_OP_IMM: begin
        control_wb = {
          1'b1,  // RegWen
          2'b01  // WBSel
        };
      end

      /* Load Operations
        - RegWen = 1
        - WBSel = 0
    */

      `OPCODE_LOAD: begin
        control_wb = {
          1'b1,  // RegWen
          2'b00  // WBSel
        };
      end

      /* Store Operations
        - RegWen = 0
        - WBSel = DC
    */

      `OPCODE_STORE: begin
        control_wb = {
          1'b0,  // RegWen
          2'b00  // WBSel
        };
      end

      /* Branch Operations
        - RegWen = 0
        - WBSel = DC
    */

      `OPCODE_BRANCH: begin
        control_wb = {
          1'b0,  // RegWen
          2'b00  // WBSel
        };
      end

      /* J-format Jump Operations (jal)
        - RegWen = 1
        - WBSel = 2
    */

      `OPCODE_JAL: begin
        control_wb = {
          1'b1,  // RegWen
          2'b10  // WBSel
        };
      end

      /* I-format Jump Operations (jalr)
        - RegWen = 1
        - WBSel = 2
    */

      `OPCODE_JALR: begin
        control_wb = {
          1'b1,  // RegWen
          2'b10  // WBSel
        };
      end

      /* U-format (lui)
        - RegWen = 1
        - WBSel = 1
    */

      `OPCODE_LUI: begin
        control_wb = {
          1'b1,  // RegWen
          2'b01  // WBSel
        };
      end

      /* U-format (auipc)
        - RegWen = 1
        - WBSel = 1
    */

      `OPCODE_AUIPC: begin
        control_wb = {
          1'b1,  // RegWen
          2'b01  // WBSel
        };
      end

      default: control_wb = 3'b0;
    endcase

    control = {control_ex, control_m, control_wb};

  end

endmodule
