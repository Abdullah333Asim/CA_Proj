`timescale 1ns / 1ps

module InstructionMemory(
    input [31:0] address,
    output [31:0] read_data
);

    reg [31:0] rom [0:63];
    
    integer i;

    initial begin
        for (i=0; i<64; i=i+1) begin
            rom[i] = 32'd0;
        end
        
        rom[0] = 32'h00500113;
        rom[1] = 32'h00a00193;
        rom[2] = 32'h00310233;
        rom[3] = 32'h00402023;
        rom[4] = 32'h00002283;
        rom[5] = 32'hfe520d63;
    end
    
    assign read_data = rom[address[7:2]];

endmodule