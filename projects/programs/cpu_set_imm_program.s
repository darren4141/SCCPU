addi x1, x0, 5
# test slti: 5 < 10 should be true
slti x2, x1, 10
# x2 = 1

addi x3, x0, 15
# test slti: 15 < 10 should be false
slti x4, x3, 10
# x4 = 0

addi x5, x0, -5
# test slti: -5 < 0 should be true
slti x6, x5, 0
# x6 = 1

# test sltiu (unsigned)
addi x7, x0, 10
# test sltiu: 10 < 5 (unsigned) should be false
sltiu x8, x7, 5
# x8 = 0

addi x9, x0, 3
# test sltiu: 3 < 8 (unsigned) should be true
sltiu x10, x9, 8
# x10 = 1

addi x11, x0, -1
# test sltiu: -1 (4294967295 unsigned) < 100 should be false
sltiu x12, x11, 100
# x12 = 0
