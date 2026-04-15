addi x1, x0, 0
addi x1, x1, 1
# we should take this branch
bne x1, x0, jump1
addi x1, x1, 1
jump1:
addi x1, x1, -1
# expect x1 = 0

addi x2, x0, 5
addi x3, x0, 6
# we should not take this branch (5 > 6)
bgt x2, x3, jump2
addi x2, x2, 5
# x2 should be 10
jump2:

# we should take this branch, x3 = 6, x2 = 10
blt x3, x2, jump3
addi x2, x2, 100
# x2 should still be 10

jump3:
beq x3, x2, jump4
addi x2, x2, 50
# x2 should be 60

jump4:
addi x7, x7, 9
