`timescale 1ns / 1ps

module debouncer (
    input clk,
    input pbin,
    output pbout
);
    reg [19:0] debounce_count = 20'h00000;
    reg pb_state = 1'b0;
    reg sync_0 = 1'b0;
    reg sync_1 = 1'b0;

    always @(posedge clk) begin
        sync_0 <= pbin;
        sync_1 <= sync_0;
    end

    always @(posedge clk) begin
        if (pb_state == sync_1) begin
            debounce_count <= 20'h00000; 
        end else begin
            debounce_count <= debounce_count + 20'h00001;
            if (debounce_count == 20'hFFFFF) begin
                pb_state <= sync_1;      
                debounce_count <= 20'h00000;
            end
        end
    end

    assign pbout = pb_state;
endmodule