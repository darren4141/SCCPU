To build a sim file:

iverilog -I inc -o sim <element>.v <testbench>.v

to run a sim file:

vvp sim

to display a waveform:

gtkwave wave.vcd