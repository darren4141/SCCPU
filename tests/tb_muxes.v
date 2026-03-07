`timescale 1ns/1ps

module tb_muxes;

reg [31:0] m2_in0;
reg [31:0] m2_in1;
reg m2_sel;
wire [31:0] m2_out;

mux_221 u_mux2(
  .in0(m2_in0),
  .in1(m2_in1),
  .sel(m2_sel),
  .out(m2_out)
);

reg [31:0] m4_in00;
reg [31:0] m4_in01;
reg [31:0] m4_in10;
reg [31:0] m4_in11;
reg [1:0] m4_sel;
wire [31:0] m4_out;

mux_421 u_mux4(
  .in00(m4_in00),
  .in01(m4_in01),
  .in10(m4_in10),
  .in11(m4_in11),
  .sel(m4_sel),
  .out(m4_out)
);

reg [31:0] m8_in000;
reg [31:0] m8_in001;
reg [31:0] m8_in010;
reg [31:0] m8_in011;
reg [31:0] m8_in100;
reg [31:0] m8_in101;
reg [31:0] m8_in110;
reg [31:0] m8_in111;

reg [2:0]  m8_sel;
wire [31:0] m8_out;

mux_821 u_mux8(
  .in000(m8_in000),
  .in001(m8_in001),
  .in010(m8_in010),
  .in011(m8_in011),
  .in100(m8_in100),
  .in101(m8_in101),
  .in110(m8_in110),
  .in111(m8_in111),
  .sel(m8_sel),
  .out(m8_out)
);

task expect;
    input [31:0] actual;
    input [31:0] expected;
    begin
        #1;
        if (actual !== expected) begin
            $display("FAIL: expected %0d got %0d", expected, actual);
            $display("DEBUG t=%0t sel=%b in0=%h in1=%h out=%h", $time, m2_sel, m2_in0, m2_in1, m2_out);
            $finish;
        end
        else
            $display("PASS");
    end
endtask

initial begin
    $dumpfile("build/vcd/muxes_wave.vcd");
    $dumpvars(0, tb_muxes);

    m2_in0 = 5; m2_in1 = 3; m2_sel = 1'b0;
    #1;
    expect(m2_out, 5);

    m2_in0 = 5; m2_in1 = 3; m2_sel = 1'b1;
    #1;
    expect(m2_out, 3);

    m4_in00 = 10;
    m4_in01 = 11;
    m4_in10 = 12;
    m4_in11 = 13;

    m4_sel = 2'b00; 
    #1
    expect(m4_out, 10);

    m4_sel = 2'b01; 
    #1
    expect(m4_out, 11);

    m4_sel = 2'b10; 
    #1
    expect(m4_out, 12);

    m4_sel = 2'b11; 
    #1
    expect(m4_out, 13);

    m8_in000 = 20;
    m8_in001 = 21;
    m8_in010 = 22;
    m8_in011 = 23;
    m8_in100 = 24;
    m8_in101 = 25;
    m8_in110 = 26;
    m8_in111 = 27;

    m8_sel = 3'b000; 
    #1
    expect(m8_out, 20);

    m8_sel = 3'b001; 
    #1
    expect(m8_out, 21);

    m8_sel = 3'b010; 
    #1
    expect(m8_out, 22);

    m8_sel = 3'b011; 
    #1
    expect(m8_out, 23);

    m8_sel = 3'b100; 
    #1
    expect(m8_out, 24);

    m8_sel = 3'b101; 
    #1
    expect(m8_out, 25);

    m8_sel = 3'b110; 
    #1
    expect(m8_out, 26);

    m8_sel = 3'b111; 
    #1
    expect(m8_out, 27);

    $finish;
end

endmodule