addi x1, x0, 0
addi x6, x0, 0

jal x5, func

# execution should resume here after jalr return
addi x1, x1, 10
# final expected x1 = 15
beq x0, x0, done

func:
addi x1, x1, 5
jalr x0, x5, 0

done:
addi x7, x7, 1