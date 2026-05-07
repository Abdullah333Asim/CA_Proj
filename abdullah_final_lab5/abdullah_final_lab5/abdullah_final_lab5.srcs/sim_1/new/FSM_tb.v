`timescale 1ns / 1ps
module fsm_testbench;
    reg clk, reset;
    reg [15:0] switches;
    wire [15:0] leds;
    FSM uut(
        .clk(clk), 
        .reset(reset), 
        .switches(switches), 
        .leds(leds)
    );  
    always #5 clk = ~clk; 
    initial begin
        clk = 0;
        reset = 1;
        switches = 16'h0000;       
        #20;
        reset = 0;
        #20;
        switches = 16'h0003; // Countdown from 0x0003
        #10;
        switches = 16'h0000;
        #50;        
        switches = 16'h0007;  // Countdown from 0x0007
        #10;
        switches = 16'h0000;
        #90;     
        switches = 16'h000A; // Countdown from 0x000A with reset mid-count
        #10;
        switches = 16'h0000;
        #40;
        reset = 1;
        #10;
        reset = 0;
        #20;   
        switches = 16'h0005;  // Countdown from 0x0005
        #10;
        switches = 16'h0000;
        #70;  
        $finish;
    end
endmodule