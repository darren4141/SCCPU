`include "mem.vh"

module imem (
    input  wire [31:0] addr,
    output reg  [31:0] inst
);

  // Array of 32 bit instructions
  reg [31:0] inst_mem[`IMEM_SIZE];

  initial begin
    $readmemh("program/program1.hex", inst_mem, 0, `IMEM_SIZE - 1);
  end

  always @(*) begin
    if (addr < `IMEM_SIZE) begin
      // Leave out the bottom 2 bits - dividing by 4
      inst = inst_mem[addr[31:2]];
    end
  end

endmodule
