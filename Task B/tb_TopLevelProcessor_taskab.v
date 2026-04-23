`timescale 1ns / 1ps

module tb_TopLevelProcessor();

    // Inputs
    reg clk;
    reg rst;
    reg [15:0] sw;

    // Outputs
    wire [15:0] led;

    // Instantiate your processor (Unit Under Test)
    TopLevelProcessor uut (
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .led(led)
    );

    // 1. Generate a 100 MHz Clock (Toggles every 5 nanoseconds)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // 2. The Test Sequence
    initial begin
        // Initialize Inputs
        rst = 1;
        sw = 16'd0;

        // Hold reset for 100ns to let the system stabilize
        #100;
        rst = 0; // Release reset, processor starts running!

        // If you are testing Part A/B (Countdown), you can simulate flipping a switch here:
        // #50;          // Wait a bit
        // sw = 16'd8;   // Flip the switch to 8 to start the countdown

        // Let the simulation run for 2000 nanoseconds, then stop
        #2000;
        $finish;
    end

endmodule