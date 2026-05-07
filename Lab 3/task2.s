.text
.globl main


main:
    addi x10, x0, 10  #g
    addi x11, x0, 5   #h
    addi x12, x0, 7   #i
    addi x13, x0, 2   #j
    jal x1, leaf

    li x10, 1
    ecall
    j exit

leaf:
    add x18, x10, x11
    add x19, x12, x13
    sub x20, x18, x19
    addi sp, sp, -12
    sw x18, 8(sp)
    sw x19, 4(sp)
    sw x20, 0(sp)

    addi x11, x20, 0
    lw x20, 0(sp)
    lw x19, 4(sp)
    lw x18, 8(sp)
    addi sp, sp, 12
    jalr x0, 0(x1)
exit: