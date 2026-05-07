`timescale 1ns / 1ps

module RegisterFile_tb;

    // Testbench signals
    reg clk;
    reg rst;
    reg WriteEnable;
    reg [4:0] rs1;
    reg [4:0] rs2;
    reg [4:0] rd;
    reg [31:0] WriteData;
    wire [31:0] ReadData1;
    wire [31:0] ReadData2;

    // Instantiate the DUT (Device Under Test)
    RegisterFile uut (
        .clk(clk),
        .rst(rst),
        .WriteEnable(WriteEnable),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .WriteData(WriteData),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );

    // Clock generation: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        // Initialize inputs
        rst = 1;
        WriteEnable = 0;
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        WriteData = 0;
        
        // Apply initial reset
        #10;
        rst = 0;

        $display("--- Starting Lab 7 Test Cases ---");

        // Test i: Write a value to a register and check
        @(posedge clk);
        WriteEnable = 1;
        rd = 5;
        WriteData = 32'hDEADBEEF;
        @(posedge clk);
        WriteEnable = 0;
        rs1 = 5;
        #1; // Brief delay for combinational read
        $display("Test i [Basic Write]: ReadData1 (reg5) = %h (Expected: deadbeef)", ReadData1);

        // Test ii: Attempt to write to x0 and verify it remains zero
        @(posedge clk);
        WriteEnable = 1;
        rd = 0;
        WriteData = 32'hFFFFFFFF;
        @(posedge clk);
        WriteEnable = 0;
        rs1 = 0;
        #1;
        $display("Test ii [x0 Protect]:   ReadData1 (reg0) = %h (Expected: 00000000)", ReadData1);

        // Setup for Test iii: Write a second value to register 10
        @(posedge clk);
        WriteEnable = 1;
        rd = 10;
        WriteData = 32'hCAFEBABE;
        @(posedge clk);
        WriteEnable = 0;

        // Test iii: Simultaneous two read ports
        rs1 = 5;
        rs2 = 10;
        #1;
        $display("Test iii [Dual Read]:   ReadData1 (reg5) = %h, ReadData2 (reg10) = %h", ReadData1, ReadData2);

        // Test iv: Overwrite a register and verify old value is replaced
        @(posedge clk);
        WriteEnable = 1;
        rd = 5;
        WriteData = 32'h12345678;
        @(posedge clk);
        WriteEnable = 0;
        rs1 = 5;
        #1;
        $display("Test iv [Overwrite]:    ReadData1 (reg5) = %h (Expected: 12345678)", ReadData1);

        // Test v: Reset behavior check
        @(posedge clk);
        rst = 1; // Assert reset
        @(posedge clk);
        rst = 0; // Deassert reset
        rs1 = 5; // Check previously written registers
        rs2 = 10;
        #1;
        $display("Test v [Reset Check]:   ReadData1 (reg5) = %h, ReadData2 (reg10) = %h (Expected: 00000000 for both)", ReadData1, ReadData2);

        // Finish simulation
        #20;
        $display("--- Testing Complete ---");
        $finish;
    end
endmodule