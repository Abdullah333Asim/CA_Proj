`timescale 1ns / 1ps
module InstructionMemory(
    input [31:0] address,
    output [31:0] read_data
);
    reg [31:0] rom [0:63];
    integer i;

    initial begin
        for (i=0; i<64; i=i+1) begin
            rom[i] = 32'd0;
        end
        
        // 1. SETUP & INITIALIZE STACK
        rom[0]  = 32'h10000313; // addi t1, x0, 256  (LED Address)
        rom[1]  = 32'h08000113; // addi sp, x0, 128  (Initialize Stack Pointer to RAM address 128)
        rom[2]  = 32'h000003B3; // add  t2, x0, x0   (Seed F_n-2 = 0)
        rom[3]  = 32'h00100513; // addi a0, x0, 1    (Seed F_n-1 = 1)
        
        // 2. PUSH INITIAL VALUES TO STACK
        rom[4]  = 32'hFF810113; // addi sp, sp, -8   (Allocate 2 words in memory)
        rom[5]  = 32'h00712223; // sw   t2, 4(sp)    (Push 0)
        rom[6]  = 32'h00A12023; // sw   a0, 0(sp)    (Push 1)
        
        // ---------------- MAIN LOOP ----------------
        // 3. POP VALUES FROM STACK
        // (LOOP_START is index 7)
        rom[7]  = 32'h00012503; // lw   a0, 0(sp)    (Load F_n-1)
        rom[8]  = 32'h00412383; // lw   t2, 4(sp)    (Load F_n-2)
        rom[9]  = 32'h00810113; // addi sp, sp, 8    (Deallocate memory)
        
        // DISPLAY
        rom[10] = 32'h00A32023; // sw   a0, 0(t1)    (Display F_n-1 on LEDs)
        
        // BNE DELAY LOOP (Sped up for 10MHz visibility) 
        rom[11] = 32'h3E800E93; // addi t4, x0, 1000
        // DELAY_OUTER:
        rom[12] = 32'h3E800F13; // addi t5, x0, 1000
        // DELAY_INNER:
        rom[13] = 32'hFFFF0F13; // addi t5, t5, -1
        rom[14] = 32'hFE0F1EE3; // bne t5, x0, DELAY_INNER
        rom[15] = 32'hFFFE8E93; // addi t4, t4, -1
        rom[16] = 32'hFE0E98E3; // bne t4, x0, DELAY_OUTER
        
        // 4. CALCULATE NEXT FIBONACCI
        rom[17] = 32'h00A385B3; // add  a1, t2, a0   (Temp = F_n-2 + F_n-1)
        
        // 5. PUSH NEW VALUES TO STACK
        rom[18] = 32'hFF810113; // addi sp, sp, -8   (Allocate 2 words)
        rom[19] = 32'h00A12223; // sw   a0, 4(sp)    (Push old F_n-1 as new F_n-2)
        rom[20] = 32'h00B12023; // sw   a1, 0(sp)    (Push Temp as new F_n-1)
        
        // REPEAT (Jump backwards exactly 56 bytes to index 7)
        rom[21] = 32'hFC0004E3; // beq x0, x0, LOOP_START  <--- FIXED HEX!
    end
    
    assign read_data = rom[address[7:2]];
endmodule