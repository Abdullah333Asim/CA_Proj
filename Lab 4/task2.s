.globl main
.text

main:
    addi x10, x0, 5  # Set argument n = 5
    jal x1, ntri        # Call the function
    
    addi x11, x10, 0   # result to x11
    addi x10, x0, 1      # to printe integer
    ecall 
    addi x10, x0, 10   # Exit
    ecall

ntri:
    addi x2, x2, -8
    sw x1, 4(x2)
    sw x10, 0(x2) 

    addi x5, x0, 1    # x5 = 1
    ble x10, x5, baseCase

    addi x10, x10, -1    # n = n - 1
    jal x1, ntri     # Recursive Call
    
    lw x6, 0(x2)
    add x10, x10, x6
    jal x0, exit_ntri

baseCase:
    addi x10, x0, 1  # Return 1

exit_ntri:
    lw x1, 4(x2)
    addi x2, x2, 8
    jalr x0, 0(x1)