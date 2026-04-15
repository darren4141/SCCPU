lui x1, 0x12345
# x1 should be 0x12345000

addi x2, x1, 5
# x2 should be 0x12345005

lui x3, 0xFFFFF
# x3 should be 0xFFFFF000

addi x3, x3, -1
# x3 should be 0xFFFFEFFF

addi x7, x7, 1
