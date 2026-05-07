`timescale 1ns / 1ps

module TopLevel(
    input clk, btnU, // btnU is our reset
    input [15:0] sw,
    input btnC, // center button to step the FSM
    output [15:0] led
);

    // internal wires for schematic layout
    wire [31:0] saved_sw;
    reg [31:0] led_bus;
    reg read_en, write_en;
    wire btnC_clean;

    // debounce the push button
    debouncer db (.clk(clk), .btn_in(btnC), .btn_out(btnC_clean));

    // split up the instruction fields from the switches
    wire [6:0] opcode = saved_sw[6:0];
    wire [2:0] funct3 = saved_sw[9:7];
    wire [6:0] funct7 = {1'b0, saved_sw[15:10]}; // pad to 7 bits

    // datapath control signals
    wire RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;

    // main control block
    MainControl MC (
        .opcode(opcode), 
        .RegWrite(RegWrite), .ALUSrc(ALUSrc), .MemRead(MemRead), 
        .MemWrite(MemWrite), .MemtoReg(MemtoReg), .Branch(Branch), 
        .ALUOp(ALUOp)
    );
    
    // ALU control block
    ALUControl AC (
        .ALUOp(ALUOp), .funct3(funct3), .funct7(funct7), 
        .ALUControl(ALUControl)
    );

    // i/o modules
    switches sw_if (.clk(clk), .rst(btnU), .switches(sw), .readEnable(read_en), .readData(saved_sw));
    leds led_if (.clk(clk), .rst(btnU), .writeData(led_bus), .writeEnable(write_en), .leds(led));

    // simple FSM
    reg [1:0] state, next_state;
    parameter IDLE = 2'b00, READ_SW = 2'b01, UPDATE_LED = 2'b10;

    always @(posedge clk) begin
        if (btnU) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        read_en = 0; 
        write_en = 0;
        led_bus = 32'b0; 
        
        case(state)
            IDLE: next_state = btnC_clean ? READ_SW : IDLE;
                
            READ_SW: begin
                read_en = 1;
                next_state = UPDATE_LED;
            end
            
            UPDATE_LED: begin
                write_en = 1;
                // pack the signals together to show on the physical LEDs
                led_bus = {6'b0, ALUControl, Branch, MemtoReg, MemWrite, MemRead, ALUSrc, RegWrite};
                next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
endmodule