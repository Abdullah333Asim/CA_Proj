`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/26/2026 03:51:13 PM
// Design Name: 
// Module Name: switches
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


module switches(
    input clk, rst,
    input [15:0] switches,
    input readEnable,
    output reg [31:0] readData
);
    always @(posedge clk) begin
        if (rst) 
            readData <= 32'b0;
        else if (readEnable) // Capture switches into the register
            readData <= {16'b0, switches};
        // No 'else' means it holds the previous value
    end
endmodule