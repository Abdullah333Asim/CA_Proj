`timescale 1ns / 1ps
module ALUControl(
    input [1:0] ALUOp,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg [3:0] ALUControl
);

    always @(*) begin
        case(ALUOp)
            2'b00: ALUControl = 4'b0010; // ADD
            2'b01: ALUControl = 4'b0110; // SUB
            2'b10: begin // R-type
                case(funct3)
                    3'b000: begin
                        if (funct7 == 7'b0100000) 
                            ALUControl = 4'b0110; // SUB
                        else if (funct7 == 7'b0000000)
                            ALUControl = 4'b0010; // ADD
                        else 
                            ALUControl = 4'b1111; 
                    end
                    3'b001: ALUControl = 4'b0100; // SLL
                    3'b101: ALUControl = 4'b0101; // SRL
                    3'b111: ALUControl = 4'b0000; // AND
                    3'b110: ALUControl = 4'b0001; // OR
                    3'b100: ALUControl = 4'b0011; // XOR
                    default: ALUControl = 4'b1111;
                endcase
            end
            2'b11: begin // I-type
                if (funct3 == 3'b000) ALUControl = 4'b0010; //  ADD
                else ALUControl = 4'b1111;
            end
            default: ALUControl = 4'b1111;
        endcase
    end
endmodule
