`timescale 1ns / 1ps

module addressDecoderTop (
    input clk, 
    input rst,
    input [31:0] address,
    input readEnable, 
    input writeEnable,
    input [31:0] writeData,
    input [15:0] switches,
    output [31:0] readData,
    output [15:0] leds
);
    wire [31:0] dm_readData;
    wire [31:0] sw_readData;

    wire dataMemSelect = (address[9:8] == 2'b00);
    wire ledSelect     = (address[9:8] == 2'b01);
    wire switchSelect  = (address[9:8] == 2'b10);

    wire dataMemWrite  = dataMemSelect & writeEnable;
    wire dataMemRead   = dataMemSelect & readEnable;
    wire ledWrite      = ledSelect & writeEnable;
    wire switchRead    = switchSelect & readEnable;

    DataMemory dm_inst (.clk(clk),.MemWrite(dataMemWrite),.MemRead(dataMemRead), .address(address), 
    .writeData(writeData), .readData(dm_readData) );

    leds led_inst (.clk(clk),.rst(rst),.writeData(writeData),.writeEnable(ledWrite),
        .readEnable(1'b0),  .memAddress(address[31:2]),  .leds(leds)  );
    SevenSegController display_inst (
        .clk(clk),
        .rst(rst),
        .value(readData[15:0]), // Display the lower 16 bits of whatever is being read
        .an(an),
        .seg(seg)
    );
    switches sw_inst (.clk(clk),.rst(rst),.btns(16'd0),.writeData(32'd0),.writeEnable(1'b0),
     .readEnable(switchRead), .memAddress(address[31:2]), .switches(switches), .readData(sw_readData) );

    assign readData = (dataMemSelect) ? dm_readData : (switchSelect)  ? sw_readData :  32'd0; 

endmodule