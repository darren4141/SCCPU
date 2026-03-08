module bcomp (
    input wire [31:0] dataA,
    input wire [31:0] dataB,
    input wire brUN,
    output wire brEQ,
    output wire brLT
);
  assign brEQ = (dataA == dataB);
  assign brLT = brUN ? (dataA < dataB) : ($signed(dataA) < $signed(dataB));

endmodule
