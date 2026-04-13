addi x1, x0, 0      # x1 = base address 0

# Construct and store a simple value
addi x2, x0, 0x12   # x2 = 0x12
slli x2, x2, 8      # x2 = 0x1200
addi x3, x0, 0x34   # x3 = 0x34
or x2, x2, x3       # x2 = 0x1234
sw x2, 0(x1)        # Store x2 at address 0

# Load the value using lhu from different offsets
lhu x4, 0(x1)       # Load bits 15:0 from address 0
lhu x5, 2(x1)       # Load bits 15:0 from address 2 (upper half of original word)

