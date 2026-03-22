addi x1, x0, 10
addi x2, x0, 10
# test bge: 10 >= 10 should be true
bge x1, x2, branch1
addi x1, x1, 100  # should not execute
branch1:

addi x3, x0, 5
addi x4, x0, 8
# test bge: 5 >= 8 should be false
bge x3, x4, branch2
addi x3, x3, 1    # should execute
# x3 should be 6
branch2:

addi x5, x0, -3
addi x6, x0, -5
# test bgeu (unsigned): -3 (4294967293) >= -5 (4294967291) should be true
bgeu x5, x6, branch3
addi x5, x5, 100  # should not execute
branch3:

addi x7, x0, 3
addi x8, x0, 7
# test bltu (unsigned): 3 < 7 should be true
bltu x7, x8, branch4
addi x7, x7, 100  # should not execute
branch4:

addi x9, x0, 9
addi x10, x0, 5
# test bltu (unsigned): 9 < 5 should be false
bltu x9, x10, branch5
addi x9, x9, 10   # should execute
# x9 should be 19
branch5:
