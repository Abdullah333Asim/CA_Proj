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

        

        // SETUP

        rom[0]  = 32'h20000293; // addi t0, x0, 512  (Switch address)

        rom[1]  = 32'h10000313; // addi t1, x0, 256  (LED address)

        

        // POLL_IN

        rom[2]  = 32'h0002A503; // lw a0, 0(t0)      (Read switches)

        rom[3]  = 32'hFE050EE3; // beq a0, x0, POLL_IN (Wait for input)

        rom[4]  = 32'h000503B3; // add t2, a0, x0    (Move to counter)

        

        // LOOP_TICK

        rom[5]  = 32'h00732023; // sw t2, 0(t1)      (Update LEDs)



        // BEQ-ONLY DELAY LOOP (Runs at 10MHz without BNE!)

        rom[6]  = 32'h7D000E93; // addi t4, x0, 2000 (Outer Counter)

        // DELAY_OUTER:

        rom[7]  = 32'h7D000F13; // addi t5, x0, 2000 (Inner Counter)

        // DELAY_INNER:

        rom[8]  = 32'hFFFF0F13; // addi t5, t5, -1

        rom[9]  = 32'h000F0463; // beq t5, x0, INNER_DONE 

        rom[10] = 32'hFE000CE3; // beq x0, x0, DELAY_INNER 

        // INNER_DONE:

        rom[11] = 32'hFFFE8E93; // addi t4, t4, -1

        rom[12] = 32'h000E8463; // beq t4, x0, OUTER_DONE 

        rom[13] = 32'hFE0004E3; // beq x0, x0, DELAY_OUTER 

        // OUTER_DONE:



        // DECREMENT & RESTART

        rom[14] = 32'hFFF38393; // addi t2, t2, -1

        rom[15] = 32'h00038463; // beq t2, x0, FINISH 

        rom[16] = 32'hFC000AE3; // beq x0, x0, LOOP_TICK  <--- FIXED HEX!

        

        // FINISH

        rom[17] = 32'h00032023; // sw x0, 0(t1)      (Turn off LEDs)

        rom[18] = 32'hFC0000E3; // beq x0, x0, POLL_IN 

    end

    

    assign read_data = rom[address[7:2]];

endmodule