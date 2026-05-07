module main_control (
    input [6:0] opcode,
    output reg RegWrite,
    output reg [1:0] ALUOp,
    output reg MemRead,
    output reg MemWrite,
    output reg ALUSrc,
    output reg MemtoReg,
    output reg Branch
);

always @(*) begin
    RegWrite = 1'b0;
    ALUOp = 2'b00;
    MemRead = 1'b0;
    MemWrite = 1'b0;
    ALUSrc = 1'b0;
    MemtoReg = 1'b0;
    Branch = 1'b0;

    case(opcode)
        7'b0110011: begin
            RegWrite = 1'b1;
            ALUOp = 2'b10;
        end
        7'b0000011: begin
            RegWrite = 1'b1;
            ALUOp = 2'b00;
            ALUSrc = 1'b1;
            MemRead = 1'b1;
            MemtoReg = 1'b1;
        end
        7'b0100011: begin
            ALUOp = 2'b00;
            ALUSrc = 1'b1;
            MemWrite = 1'b1;
        end
        7'b1100011: begin
            ALUOp = 2'b01;
            Branch = 1'b1;
        end
        7'b0010011: begin
            RegWrite = 1'b1;
            ALUOp = 2'b10;
            ALUSrc = 1'b1;
        end
        default: begin
        end
    endcase
end
endmodule