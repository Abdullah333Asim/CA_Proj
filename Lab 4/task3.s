.globl main
.data
    arr: .word 3, 10, 1, 5
    len: .word 4

.text
main:
    la x10, arr  
    lw x11, len  
    
    jal x1, bubble 
    

    la x20, arr   
    lw x21, len
    
print_loop:
    beq x21, x0, exit_prog # If counter is 0 then exit

    lw x11, 0(x20)  
    addi x10, x0, 1     #Print Integer
    ecall                

    addi x20, x20, 4     # offset
    addi x21, x21, -1    # counter - 1
    jal x0, print_loop

exit_prog:
    addi x10, x0, 10    
    ecall

bubble:
    beq x10, x0, return_func  # if a == NULL, return
    beq x11, x0, return_func  # if len == 0, return

    addi x5, x0, 0  # i = 0

outer_loop:
    bge x5, x11, return_func  # if i >= len, return
    addi x6, x5, 0        # j = i

inner_loop:
    bge x6, x11, next_outer   # if j >= len, go to next outer loop
    slli x7, x5, 2        # offset
    add x7, x10, x7     
    lw x28, 0(x7)        # x28 = a[i]

    slli x29, x6, 2      # offset
    add x29, x10, x29     # 
    lw x30, 0(x29)      # x30 = a[j]
    bge x28, x30, no_swap 

    sw x30, 0(x7)     #swap
    sw x28, 0(x29)    #swap

no_swap:
    addi x6, x6, 1       # j++
    jal x0, inner_loop

next_outer:
    addi x5, x5, 1       # i++
    jal x0, outer_loop

return_func:
    jalr x0, 0(x1)  # Return