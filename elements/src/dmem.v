`include "mem.vh"

module dmem (
    input wire clk,
    input wire dwe,
    input wire [2:0] size,
    input wire [31:0] addr,
    input wire [31:0] dataW,
    output wire [31:0] dataR
);

  // Array of 32 bit memory
  reg [31:0] dyna_mem[`DMEM_SIZE];

  // Leave out the bottom 2 bits - dividing by 4
  wire [31:0] target = dyna_mem[addr[31:2]];

  assign dataR =
  (size == `DMEM_TYPE_B) ? {{24{target[7]}}, target[7:0]} :
  (size == `DMEM_TYPE_BU) ? {{24{1'b0}}, target[7:0]} :
  (size == `DMEM_TYPE_H) ? {{16{target[15]}}, target[15:0]} :
  (size == `DMEM_TYPE_HU) ? {{16{1'b0}}, target[15:0]} :
  (size == `DMEM_TYPE_W) ? target : 32'b0;

  always @(posedge clk) begin
    if (dwe) begin
      case (size)
        `DMEM_TYPE_B, `DMEM_TYPE_BU: dyna_mem[addr[31:2]][7:0] <= dataW[7:0];
        `DMEM_TYPE_H, `DMEM_TYPE_HU: dyna_mem[addr[31:2]][15:0] <= dataW[15:0];
        `DMEM_TYPE_W: dyna_mem[addr[31:2]] <= dataW;
        default: ;
      endcase

    end
  end

endmodule
