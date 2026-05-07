`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/26/2026 04:32:00 PM
// Design Name: 
// Module Name: debouncer
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


module debouncer(
    input clk, btn_in,
    output reg btn_out
);
    reg [19:0] counter; // ~10ms delay at 100MHz
    always @(posedge clk) begin
        if (btn_in) counter <= counter + 1;
        else counter <= 0;
        
        if (counter == 20'hFFFFF) btn_out <= 1;
        else if (counter == 0) btn_out <= 0;
    end
endmodule