addi x1, x0, 7
# x1 = 7 (0b00111)

slli x2, x1, 1
# x2 = 14 (0b01110)

addi x3, x0, 16
# x3 = 16 (0b10000)

srli x4, x3, 2
# x4 = 4 (0b00100)

addi x5, x0, 32
# x5 = 32

srai x6, x5, 3
# x6 = 4 (32 >> 3)

addi x7, x0, -16
# x7 = -16 (0xFFFFFFF0)

srai x8, x7, 2
# x8 = -4 (arithmetic right shift preserves sign)

addi x9, x0, 3
slli x10, x9, 5
# x10 = 96 (3 << 5)
