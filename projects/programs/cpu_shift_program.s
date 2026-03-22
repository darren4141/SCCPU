addi x1, x0, 7
addi x2, x0, 2
sll x3, x1, x2
addi x2, x2, -1
srl x4, x1, x2

# Test sra (shift right arithmetic) with positive number
addi x5, x0, 32
addi x6, x0, 3
sra x7, x5, x6
# x7 = 32 >> 3 = 4 (positive, fills with 0s)

# Test sra with negative number
addi x8, x0, -16
# x8 = -16 (0xFFFFFFF0)
addi x9, x0, 2
sra x10, x8, x9
# x10 = -16 >> 2 = -4 (negative, fills with 1s, result is 0xFFFFFFFC)
