`timescale 1ns / 1ps

module switches(
    input clk, rst,
    input [15:0] btns,
    input [31:0] writeData, 
    input writeEnable, 
    input readEnable,
    input [29:0] memAddress,
    input [15:0] switches,
    output reg [31:0] readData
);
    always @(posedge clk) begin
        if (rst) begin
            readData <= 32'd0;
        end else if (readEnable) begin
            readData <= {16'd0, switches};
        end
    end
endmodule