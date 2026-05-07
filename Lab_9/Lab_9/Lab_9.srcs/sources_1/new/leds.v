`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/26/2026 03:50:34 PM
// Design Name: 
// Module Name: leds
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module leds(
    input clk, 
    input rst,
    input [31:0] writeData, // Control signals from FSM
    input writeEnable,      // From FSM
    output [15:0] leds      // Physical LEDs
);
    reg [15:0] led_reg;

    always @(posedge clk) begin
        if (rst) 
            led_reg <= 16'b0;
        else if (writeEnable)
            led_reg <= writeData[15:0];
    end

    assign leds = led_reg;
endmodule
