module regfile_pipelined (
    input wire clk,
    input wire we,
    input wire [4:0] addrA,
    input wire [4:0] addrB,
    input wire [4:0] addrD,

    input  wire [31:0] dataD,
    output reg  [31:0] dataA,
    output reg  [31:0] dataB
);

  // Array of 32 bit registers
  reg [31:0] regfile[32];

  // Initialize all register values to 0
  integer i;
  initial begin
    for (i = 0; i < 32; i = i + 1) begin
      regfile[i] = 32'b0;
    end
  end

  // On rising edge of clk, update rd if we = 1
  always @(posedge clk) begin
    if (we && addrD != 0) begin
      regfile[addrD] <= dataD;
    end

  end

  // Update dataA and dataB outputs
  always @(*) begin

    if (we && addrD != 0 && addrA == addrD) begin
      dataA = dataD;
    end else begin
      dataA = (addrA != 0) ? regfile[addrA] : 32'b0;
    end

    if (we && addrD != 0 && addrB == addrD) begin
      dataB = dataD;
    end else begin
      dataB = (addrB != 0) ? regfile[addrB] : 32'b0;
    end
  end

endmodule
