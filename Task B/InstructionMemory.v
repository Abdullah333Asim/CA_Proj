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
        
        // 1. SETUP
        rom[0]  = 32'h20000293; // addi t0, x0, 512
        rom[1]  = 32'h10000313; // addi t1, x0, 256
        
        // 2. POLL_IN
        rom[2]  = 32'h0002A503; // lw a0, 0(t0)
        rom[3]  = 32'hFE050EE3; // beq a0, x0, POLL_IN
        
        rom[4]  = 32'h000503B3; // add t2, a0, x0      (Seed counter with switch value)
        rom[5]  = 32'h008000EF; // jal ra, COUNT_UP    (Jump to subroutine!)
        rom[6]  = 32'hFE0008E3; // beq x0, x0, POLL_IN (When it returns, wait for new input)
        
        // 3. COUNT_UP SUBROUTINE
        rom[7]  = 32'hFF810113; // addi sp, sp, -8
        rom[8]  = 32'h00112223; // sw ra, 4(sp)
        
        // --- LOOP TICK ---
        rom[9]  = 32'h00732023; // sw t2, 0(t1)        (Update LEDs)
        
        // BNE DELAY LOOP (Runs at 10MHz)
        rom[10] = 32'h7D000E93; // addi t4, x0, 2000  
        // DELAY_OUTER:
        rom[11] = 32'h7D000F13; // addi t5, x0, 2000  
        // DELAY_INNER:
        rom[12] = 32'hFFFF0F13; // addi t5, t5, -1
        rom[13] = 32'hFE0F1EE3; // bne t5, x0, DELAY_INNER 
        rom[14] = 32'hFFFE8E93; // addi t4, t4, -1
        rom[15] = 32'hFE0E98E3; // bne t4, x0, DELAY_OUTER
        
        // INCREMENT & CHECK
        rom[16] = 32'h00138393; // addi t2, t2, 1      (ADD 1 to count UP)
        rom[17] = 32'h0002A503; // lw a0, 0(t0)        (Read switches again)
        rom[18] = 32'hFC051EE3; // bne a0, x0, LOOP_TICK (If switches aren't 0, keep counting!)
        
        // 4. RETURN FROM SUBROUTINE
        rom[19] = 32'h00032023; // sw x0, 0(t1)        (Turn off LEDs)
        rom[20] = 32'h00412083; // lw ra, 4(sp)
        rom[21] = 32'h00810113; // addi sp, sp, 8
        rom[22] = 32'h00008067; // jalr x0, ra, 0      (Return!)
    end
    
    assign read_data = rom[address[7:2]];

endmodule