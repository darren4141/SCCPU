auipc x1, 0
# x1 should equal PC of this instruction (0)

addi x2, x1, 4
# x2 should equal address of next instruction (4)

auipc x3, 0x1
# x3 = PC + 0x10000 (0x1008)

addi x7, x7, 2