.globl main
.text
main:
    addi x10, x0, 5   # n = 5
    jal x1, factorial    
    
    addi x11, x10, 0
    addi x10, x0, 1
    ecall                

    addi x10, x0, 10
    ecall

factorial:
    addi x5, x10, 0     # Copy n to x5 
    addi x10, x0, 1      # reset x10 to 1

loop:
    ble x5, x0, done   # if iterator <= 0, finish
    mul x10, x10, x5     # result = result* value of n
    addi x5, x5, -1     # decrement n for next call
    jal x0, loop       # loop again

done:
    jalr x0, 0(x1)    # return to function caller