.text
.globl main

main: 
    li x10, 0x100
    li x5, 2
    sw x5, 0(x10)
    li x5, 4
    sw x5, 4(x10)
    li x5, 8
    sw x5, 8(x10)
    li x5, 6
    sw x5, 12(x10)
    li x5, 10
    sw x5, 16(x10)
    li x5, 12
    sw x5, 20(x10)

    li x11, 2
    jal x1, swap    
    addi x17, x0, 10
    ecall
    
swap:
    slli x5, x11, 2
    add  x5, x10, x5

    lw x6, 0(x5) 
    lw x7, 4(x5) 

    sw x7, 0(x5) 
    sw x6, 4(x5) 

    jalr x0, 0(x1)

exit:
    j exit