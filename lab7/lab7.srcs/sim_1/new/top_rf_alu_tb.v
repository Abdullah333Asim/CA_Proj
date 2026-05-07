`timescale 1ns / 1ps

module top_rf_alu_tb();

    reg clk_100MHz;
    reg rst;
    reg [3:0] sw_alu_ctrl;
    reg [4:0] sw_rd;
    reg btn_we;

    wire [11:0] led_result;
    wire [1:0] led_state;
    wire led_zero;

    top_rf_alu uut (
        .clk_100MHz(clk_100MHz),
        .rst(rst),
        .sw_alu_ctrl(sw_alu_ctrl),
        .sw_rd(sw_rd),
        .btn_we(btn_we),
        .led_result(led_result),
        .led_state(led_state),
        .led_zero(led_zero)
    );

    initial begin
        clk_100MHz = 0;
        forever #5 clk_100MHz = ~clk_100MHz; 
    end

    initial begin
        rst = 1;
        sw_alu_ctrl = 4'b0000;
        sw_rd = 5'd0;
        btn_we = 0;
        #20 rst = 0;
        #30; 
        
        // Test ADD Operation
        sw_alu_ctrl = 4'b0010; 
        #20;

        //Test SUB Operation
        sw_alu_ctrl = 4'b0110; 
        #20;

        // Test AND Operation
        sw_alu_ctrl = 4'b0000; 
        #20;
        
        // Test OR Operation
        sw_alu_ctrl = 4'b0001; 
        #20;

        // test Manual Write
        sw_rd = 5'd5;
        btn_we = 1; 
        #10;
        btn_we = 0; 
        #10;
        $finish;
    end

endmodule