`timescale 1ns / 1ps

module top_rf_alu (
    input wire clk_100MHz,       
    input wire rst,        // Reset (SW15)
    input wire [3:0] sw_alu_ctrl,  // ALU Control (SW0-SW3)
    input wire [4:0] sw_rd,       // destination Register for writes (SW4-SW8)
    input wire btn_we,             
    output wire [11:0] led_result, // ALU Result display (LED0-LED11)
    output wire [1:0] led_state,  // FSM State display (Mapped to LED14-LED15)
    output wire led_zero        // Zero Flag  (LED13)
);
    wire [31:0] rf_rdata1, rf_rdata2;
    wire [31:0] alu_result;
    wire alu_zero;
    
    reg [4:0] rf_rs1, rf_rs2, rf_rd;
    reg [31:0] rf_wdata;
    reg internal_we;

    // FSM States
    localparam INIT_X1     = 2'd0;
    localparam INIT_X2     = 2'd1;
    localparam OPERATIONAL = 2'd2;

    reg [1:0] state = INIT_X1;

    RegisterFile rf_inst (
        .clk(clk_100MHz),
        .rst(rst),
        .WriteEnable(internal_we),
        .rs1(rf_rs1),
        .rs2(rf_rs2),
        .rd(rf_rd),
        .WriteData(rf_wdata),
        .ReadData1(rf_rdata1),
        .ReadData2(rf_rdata2)
    );

    ALU alu_inst (
        .A(rf_rdata1),
        .B(rf_rdata2),
        .control(sw_alu_ctrl), 
        .result(alu_result),
        .Zero(alu_zero)
    );

    always @(posedge clk_100MHz) begin
        if (rst) begin
            state <= INIT_X1;
            internal_we <= 0;
            rf_rs1 <= 5'd0;
            rf_rs2 <= 5'd0;
        end else begin
            case (state)
                INIT_X1: begin
                    internal_we <= 1;
                    rf_rd <= 5'd1;
                    rf_wdata <= 32'h10101010;
                    state <= INIT_X2;
                end
                
                INIT_X2: begin
                    internal_we <= 1;
                    rf_rd <= 5'd2;
                    rf_wdata <= 32'h01010101;
                    state <= OPERATIONAL;
                end
                
                OPERATIONAL: begin
                    rf_rs1 <= 5'd1;
                    rf_rs2 <= 5'd2;
                    internal_we <= btn_we; 
                    rf_rd <= sw_rd;
                    rf_wdata <= alu_result;
                    
                    state <= OPERATIONAL;
                end
                
                default: state <= INIT_X1;
            endcase
        end
    end

    assign led_state = state;
    assign led_result = alu_result[11:0];
    assign led_zero = alu_zero;

endmodule