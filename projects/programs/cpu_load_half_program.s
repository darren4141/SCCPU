addi x1, x0, 0

# Store 0x12345678 at address 0
addi x2, x0, 0x1000
addi x2, x2, -1
addi x2, x2, 1  # x2 now has some non-zero value, use for shifted left
addi x3, x0, 0x400
addi x3, x3, 0x234
slli x3, x3, 8
addi x4, x0, 0x56
addi x4, x4, 12
or x3, x3, x4
sw x3, 0(x1)

# Load half unsigned from 0 (lower half)
lhu x5, 0(x1)

# Load half unsigned from 2 (upper half)
lhu x6, 2(x1)

# Simple additional test
addi x7, x0, 0x100
addi x7, x7, 7
sw x7, 4(x1)

lhu x8, 4(x1)

