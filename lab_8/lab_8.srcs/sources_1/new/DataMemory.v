`timescale 1ns / 1ps

module DataMemory (
    input clk,
    input MemWrite,
    input MemRead,
    input [31:0] address,
    input [31:0] writeData,
    output [31:0] readData
);
    reg [31:0] mem [0:511];

    always @(posedge clk) begin
        if (MemWrite) begin
            mem[address[8:0]] <= writeData;
        end
    end

    assign readData = (MemRead) ? mem[address[8:0]] : 32'd0;

endmodule