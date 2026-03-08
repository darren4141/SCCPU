`include "mem.vh"

module dmem (
    input wire clk,
    input wire dwe,
    input wire [31:0] addr,
    input wire [31:0] dataW,
    output wire [31:0] dataR
);

  // Array of 32 bit memory
  reg [31:0] dyna_mem[`DMEM_SIZE];

  // Leave out the bottom 2 bits - dividing by 4
  assign dataR = dyna_mem[addr[31:2]];

  always @(posedge clk) begin
    if (dwe) dyna_mem[addr[31:2]] <= dataW;
  end


endmodule
