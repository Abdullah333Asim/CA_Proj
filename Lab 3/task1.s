.text
.globl main

lw x5, 32(x1)
add x2, x3, x5
addi x4, x2, -1
sw x4, 40(x1)