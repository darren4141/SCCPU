addi x1, x0, 0
addi x2, x0, 0

# Build target address into x5
addi x5, x5, 20

# jalr should:
# 1. set x6 = address of next instruction
# 2. jump to target
jalr x6, x5, 4
# this will jump to the second addi

# should be skipped
addi x1, x1, 100

target:
addi x1, x1, 1
addi x1, x1, 1

# x1 should now be 1, not 101
# x6 should contain return address (16)

addi x2, x2, 9
# x2 should be 9