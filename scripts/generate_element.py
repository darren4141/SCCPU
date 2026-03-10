# scripts/generate_element.py
from pathlib import Path
import sys

if len(sys.argv) < 2:
    print("Usage: python scripts/new_element.py <element_name>")
    sys.exit(1)

name = sys.argv[1]

files = {
    Path(f"elements/{name}.v"): f"""module {name}();

always @(*) begin

end

endmodule
""",
    Path(f"tests/tb_{name}.v"): f"""`timescale 1ns/1ps

module tb_{name};
    `include "expect.vh"
    
    {name} uut();

    initial begin
        $dumpfile("build/vcd/elements/{name}_wave.vcd");
        $dumpvars(0, tb_{name});

        #10;
        $finish;
    end

endmodule
"""
}

for path, content in files.items():
    if path.exists():
        print(f"Error: {path} already exists")
        sys.exit(1)

for path, content in files.items():
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content)

print(f"Generated files for {name}")