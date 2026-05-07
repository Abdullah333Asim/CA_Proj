.globl main
.text

main:
    # 1. Setup the Value to Print in x11 (NOT x10)
    addi x11, x0, 99     # Argument = 99
    
    # 2. Setup the System Call ID in x10 (NOT x17)
    addi x10, x0, 1      # ID = 1 (Print Integer)
    
    # 3. Execute
    ecall                # Should print "99"

    # 4. Exit
    addi x10, x0, 10     # ID = 10 (Exit)
    ecall