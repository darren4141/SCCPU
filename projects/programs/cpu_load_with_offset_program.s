addi x1, x0, 0      # x1 = base address 0

# Store different values at different offsets
addi x2, x0, 0x111
sw x2, 0(x1)        # Store 0x111 at offset 0

addi x2, x0, 0x222
sw x2, 4(x1)        # Store 0x222 at offset 4

addi x2, x0, 0x333
sw x2, 8(x1)        # Store 0x333 at offset 8

addi x2, x0, 0x444
sw x2, 12(x1)       # Store 0x444 at offset 12

# Load back using base registser with offsets
lw x3, 0(x1)        # Load from offset 0 -> x3
lw x4, 4(x1)        # Load from offset 4 -> x4
lw x5, 8(x1)        # Load from offset 8 -> x5
lw x6, 12(x1)       # Load from offset 12 -> x6

# Test half-word loads with offsets
lhu x7, 0(x1)       # Load bits 15:0 from offset 0
lhu x8, 2(x1)       # Load bits 15:0 from offset 2
