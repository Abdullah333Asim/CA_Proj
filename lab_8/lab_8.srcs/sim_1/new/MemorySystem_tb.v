`timescale 1ns / 1ps
module MemorySystem_tb();
    reg clk;
    reg rst;
    reg [31:0] address;
    reg readEnable;
    reg writeEnable;
    reg [31:0] writeData;
    reg [15:0] switches;

    wire [31:0] readData;
    wire [15:0] leds;
    addressDecoderTop dut (.clk(clk),.rst(rst),.address(address),.readEnable(readEnable),
        .writeEnable(writeEnable),.writeData(writeData), .switches(switches),
        .readData(readData),.leds(leds));

    always #5 clk = ~clk;
    task reset_all;
        begin
            rst = 1;
            address = 32'b0;
            readEnable = 0;
            writeEnable = 0;
            writeData = 32'b0;
            switches = 16'b0;
            @(posedge clk); #1;
            rst = 0;
        end
    endtask
    task write_to(input [31:0] addr, input [31:0] data);
        begin
            address = addr;
            writeData = data;
            writeEnable = 1;
            readEnable = 0;
            @(posedge clk); #1;
            writeEnable = 0;
        end
    endtask
    task read_from(input [31:0] addr);
        begin
            address = addr;
            readEnable = 1;
            writeEnable = 0;
            @(posedge clk); #1;
            readEnable = 0;
        end
    endtask
    initial begin
        clk = 0;
        reset_all();
        
        write_to(32'h000, 32'hDEADBEEF);
        write_to(32'h004, 32'h12345678);
        
        read_from(32'h000);

        read_from(32'h004);

        write_to(32'h100, 32'h0000ABCD);

        write_to(32'h100, 32'h0000FFFF);

        switches = 16'hBEEF;
        read_from(32'h200);

        switches = 16'h1234;
        read_from(32'h200);

        write_to(32'h008, 32'hCAFEBABE);
        write_to(32'h100, 32'h0000AAAA); 
        read_from(32'h008); 

        read_from(32'h100);

        $finish;
    end
endmodule