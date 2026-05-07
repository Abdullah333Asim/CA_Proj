.globl main
.text
main:
    addi x10, x0, 5    # n = 5
    jal x1, sum_square      
    
    addi x11, x10, 0    #Resultto x11
    addi x10, x0, 1      # Print Integer
    ecall                
    addi x10, x0, 10  
    ecall

sum_square:
    addi x2, x2, -8
    sw x1, 4(x2)
    sw x10, 0(x2)

    beq x10, x0, basecase
    addi x10, x10, -1    # n = n - 1
    jal x1, sum_square     #Recursive call
    
    lw x5, 0(x2)        #Restore original n from stack to x5
    mul x6, x5, x5     # x6 = n*n
    add x10, x10, x6    # add result to n*n
    
    jal x0, exit_sum 

basecase:
    addi x10, x0, 0 # Return 0

exit_sum:
    lw x1, 4(x2)    # Restore return address
    addi x2, x2, 8      # Restore stack pointer
    jalr x0, 0(x1)  