`timescale 1ns / 1ps

module RF_ALU_FSM_tb();
    reg clk;
    reg rst;
    reg rf_we;
    reg [4:0] rf_rs1, rf_rs2, rf_rd;
    reg [31:0] rf_wdata;
    
    wire [31:0] rf_rdata1, rf_rdata2;
    wire [31:0] alu_result;
    wire alu_zero;
    reg [3:0] alu_ctrl;

    RegisterFile rf (
        .clk(clk), .rst(rst), .WriteEnable(rf_we),
        .rs1(rf_rs1), .rs2(rf_rs2), .rd(rf_rd), .WriteData(rf_wdata),
        .ReadData1(rf_rdata1), .ReadData2(rf_rdata2)
    );

    ALU alu_inst (
        .A(rf_rdata1), .B(rf_rdata2), .control(alu_ctrl),
        .result(alu_result), .Zero(alu_zero)
    );

    localparam IDLE            = 3'd0;
    localparam INIT_REGS       = 3'd1; 
    localparam READ_REGISTERS  = 3'd2;
    localparam ALU_OPERATION   = 3'd3;
    localparam WRITE_REGISTERS = 3'd4;
    localparam DONE            = 3'd5;

    reg [2:0] state;
    reg [3:0] op_count; 

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            op_count <= 0;
            rf_we <= 0;
        end else begin
            case (state)
                IDLE: begin
                    rf_we <= 0;
                    state <= INIT_REGS;
                end
                
                INIT_REGS: begin
                    rf_we <= 1;
                    if (op_count == 0) begin
                        rf_rd <= 5'd1; rf_wdata <= 32'h10101010; op_count <= 1;
                    end else if (op_count == 1) begin
                        rf_rd <= 5'd2; rf_wdata <= 32'h01010101; op_count <= 2;
                    end else if (op_count == 2) begin
                        rf_rd <= 5'd3; rf_wdata <= 32'h00000005; op_count <= 0; 
                        state <= READ_REGISTERS;
                    end
                end

                READ_REGISTERS: begin
                    rf_we <= 0;
                    rf_rs1 <= 5'd1; 
                    rf_rs2 <= 5'd2; 
                    
                    if (op_count == 5 || op_count == 6) begin 
                        rf_rs2 <= 5'd3;
                    end else if (op_count == 7) begin 
                        rf_rs2 <= 5'd1;
                    end else if (op_count == 8) begin 
                        rf_rs1 <= 5'd11; 
                        rf_rs2 <= 5'd0;
                    end
                    
                    state <= ALU_OPERATION;
                end
                ALU_OPERATION: begin
                    case (op_count)
                        0: alu_ctrl <= 4'b0010; // ADD
                        1: alu_ctrl <= 4'b0110; // SUB
                        2: alu_ctrl <= 4'b0000; // AND
                        3: alu_ctrl <= 4'b0001; // OR
                        4: alu_ctrl <= 4'b0111; // XOR
                        5: alu_ctrl <= 4'b1000; // SLL
                        6: alu_ctrl <= 4'b1001; // SRL
                        7: alu_ctrl <= 4'b0110; // BEQ check
                        8: alu_ctrl <= 4'b0010; // RAW check
                    endcase
                    state <= WRITE_REGISTERS;
                end

                WRITE_REGISTERS: begin
                    rf_we <= 1; 
                    
                    if (op_count == 7) begin
                        rf_rd <= 5'd11; 
                        rf_wdata <= {31'b0, alu_zero}; 
                    end else if (op_count == 8) begin
                        rf_rd <= 5'd12;
                        rf_wdata <= alu_result;
                    end else begin
                        rf_rd <= 5'd4 + op_count; 
                        rf_wdata <= alu_result;
                    end

                    if (op_count == 8) begin
                        state <= DONE;
                    end else begin
                        op_count <= op_count + 1;
                        state <= READ_REGISTERS; 
                    end
                end

                DONE: begin
                    rf_we <= 0;
                end
            endcase
        end
    end
    initial begin
        rst = 1;
        #15 rst = 0;
        wait(state == DONE);
        #10;
        $finish;
    end
endmodule