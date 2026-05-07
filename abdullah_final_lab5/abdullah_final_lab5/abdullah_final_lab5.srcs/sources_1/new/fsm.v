`timescale 1ns / 1ps
module FSM(
    input clk, reset,
    input [15:0] switches,
    output [15:0] leds
);
    reg state = 1'b0;
    reg [15:0] latchval = 0;
    wire [15:0] counter;
    reg load;
    startcounter c(clk, reset, state, load, latchval, counter);
    assign leds = (state == 1'b1) ? {16'b0, counter} : 32'b0;
    always @(posedge clk) begin
        if (reset) begin
            state<= 1'b0;
            load<= 1'b0;
            latchval<= 0;
        end else if (state==1'b0) begin
            load<= 1'b0;
            if (switches>0) begin
                state <= 1'b1;
                latchval <= switches[15:0];
                load <= 1'b1;
            end
        end else if (state==1'b1) begin
            load <= 1'b0;
            if (counter==0) begin
                state <= 1'b0;
            end
        end
    end
endmodule