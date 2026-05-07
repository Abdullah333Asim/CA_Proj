`timescale 1ns / 1ps
module MainControl(
    input  [6:0] opcode,
    output reg  RegWrite,
    output reg  ALUSrc,
    output reg MemRead,
    output reg  MemWrite,
    output reg   MemtoReg,
    output reg  Branch,
    output reg [1:0] ALUOp
);

    always @(*) begin
        RegWrite = 0; ALUSrc = 0; MemRead = 0; MemWrite = 0; 
        MemtoReg = 0; Branch = 0; ALUOp = 2'b00;

        case(opcode)
            7'b0110011: begin // R type (ADD, SUB,SLL, SRL, AND,OR, XOR)
                RegWrite = 1; ALUSrc = 0; MemtoReg = 0; ALUOp = 2'b10;
            end
            7'b0010011: begin // I type (ADDI)
                RegWrite = 1; ALUSrc = 1; MemtoReg = 0; ALUOp = 2'b11; 
            end
            7'b0000011: begin // Load (LW,LH, LB)
                RegWrite = 1; ALUSrc = 1; MemRead = 1; MemtoReg = 1; ALUOp = 2'b00;
            end
            7'b0100011: begin // Store (SW, SH,SB)
                ALUSrc   = 1; MemWrite = 1; ALUOp = 2'b00;
            end
            7'b1100011: begin // Branch (BEQ)
                Branch   = 1; ALUOp = 2'b01;
            end
            default: ;
        endcase
    end
endmodule