module alu_control (
input [1:0] ALUOp,
input [2:0] funct3,
input [6:0] funct7,
output reg [3:0] ALUControl
);

always @(*) begin
    ALUControl = 4'b0000;
    
    case (ALUOp)
        2'b00: begin // lw, sw, jalr
            ALUControl = 4'b0010; // add
        end
        2'b01: begin // beq, bne
            ALUControl = 4'b0110; // sub
        end
        2'b10: begin // R-type
            case(funct3)
                3'b000: begin
                    // Only check for subtract if it is an R-Type instruction
                    if (funct7[5] == 1'b1)
                        ALUControl = 4'b0110; // sub
                    else
                        ALUControl = 4'b0010; // add
                end
                3'b111: ALUControl = 4'b0000; // and
                3'b110: ALUControl = 4'b0001; // or
                default: ALUControl = 4'b0000;
            endcase
        end
        2'b11: begin // I-type (ADDI)
            case(funct3)
                3'b000: ALUControl = 4'b0010; // ADDI is ALWAYS add, ignore bit 30!
                3'b111: ALUControl = 4'b0000; // andi
                3'b110: ALUControl = 4'b0001; // ori
                default: ALUControl = 4'b0000;
            endcase
        end
        default: ALUControl = 4'b0000;
    endcase
end
endmodule
