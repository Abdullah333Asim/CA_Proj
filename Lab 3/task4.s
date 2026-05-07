.text
.globl main

main:
    li x5, 0x00616554   # "tea"
    li x6, 0x200        
    sw x5, 0(x6) 
    li x10, 0x100    
    li x11, 0x200     
    jal x1, strcpy 

exit:
    j exit 

strcpy:
    addi sp, sp, -8   
    sw x19, 0(sp)
    addi x19, x0, 0 

loop_start:
    add x5, x19, x11   
    lbu x6, 0(x5)      
    
    add x7, x19, x10  
    sb x6, 0(x7)   
    
    beq x6, x0, end
    
    addi x19, x19, 1  
    jal x0, loop_start  

end:
    lw x19, 0(sp) 
    addi sp, sp, 8
    jalr x0, 0(x1)  