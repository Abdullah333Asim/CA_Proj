`timescale 1ns / 1ps

module SevenSegController(
    input clk,
    input rst,
    input [15:0] value, // The 16-bit value to display
    output reg [3:0] an,  // Anodes (Active Low)
    output reg [6:0] seg  // Segments (Active Low)
);

    // Refresh counter to cycle through the 4 digits
    // Using 20 bits gives a refresh rate of ~95Hz on a 100MHz clock
    reg [19:0] refresh_counter;
    
    always @(posedge clk or posedge rst) begin
        if (rst) 
            refresh_counter <= 0;
        else 
            refresh_counter <= refresh_counter + 1;
    end
    
    // The top 2 bits determine which digit is currently active
    wire [1:0] active_digit = refresh_counter[19:18];
    reg [3:0] hex_digit;
    
    // Multiplexer to select the anode and the corresponding 4 bits of the value
    always @(*) begin
        case(active_digit)
            2'b00: begin
                an = 4'b1110; // Activate Digit 0 (Rightmost)
                hex_digit = value[3:0];
            end
            2'b01: begin
                an = 4'b1101; // Activate Digit 1
                hex_digit = value[7:4];
            end
            2'b10: begin
                an = 4'b1011; // Activate Digit 2
                hex_digit = value[11:8];
            end
            2'b11: begin
                an = 4'b0111; // Activate Digit 3 (Leftmost)
                hex_digit = value[15:12];
            end
        endcase
    end
    
    // Hex to 7-Segment Decoder (Active Low for Basys 3)
    always @(*) begin
        case(hex_digit)
            4'h0: seg = 7'b1000000; 
            4'h1: seg = 7'b1111001; 
            4'h2: seg = 7'b0100100; 
            4'h3: seg = 7'b0110000; 
            4'h4: seg = 7'b0011001; 
            4'h5: seg = 7'b0010010; 
            4'h6: seg = 7'b0000010; 
            4'h7: seg = 7'b1111000; 
            4'h8: seg = 7'b0000000; 
            4'h9: seg = 7'b0010000; 
            4'hA: seg = 7'b0001000; 
            4'hB: seg = 7'b0000011; 
            4'hC: seg = 7'b1000110; 
            4'hD: seg = 7'b0100001; 
            4'hE: seg = 7'b0000110; 
            4'hF: seg = 7'b0001110; 
            default: seg = 7'b1111111; // Blank
        endcase
    end

endmodule