`timescale 1ns / 1ps

module ProgramCounter(
    input clk,
    input reset,
    input [31:0] next_pc,
    output reg [31:0] pc
);

    // PC updates on positive clock edge, asynchronous reset
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'd0;
        else
            pc <= next_pc;
    end

endmodule
