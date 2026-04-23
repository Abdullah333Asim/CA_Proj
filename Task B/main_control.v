module main_control (
    input [6:0] opcode,
    output reg RegWrite,
    output reg [1:0] ALUOp,
    output reg MemRead,
    output reg MemWrite,
    output reg ALUSrc,
    output reg MemtoReg,
    output reg Branch,
    output reg Jump,
    output reg JumpReg
);

always @(*) begin
    // Default assignments to handle Don't Care (X) conditions safely
    RegWrite = 1'b0;
    ALUOp = 2'b00;     // Default ALUOp: 00 (Addition)
    MemRead = 1'b0;
    MemWrite = 1'b0;
    ALUSrc = 1'b0;
    MemtoReg = 1'b0;
    Branch = 1'b0;
    Jump = 1'b0;
    JumpReg = 1'b0;

    case(opcode)
        7'b0110011: begin // R-type (add, sub, and, or, etc.)
            RegWrite = 1'b1;
            ALUOp = 2'b10; // ALUOp 10: R-Type (Checks funct3 and funct7 to decide operation)
        end
        
        7'b0000011: begin // lw (Load Word)
            RegWrite = 1'b1;
            ALUOp = 2'b00; // ALUOp 00: Memory (Forces ADD to calculate address)
            ALUSrc = 1'b1;
            MemRead = 1'b1;
            MemtoReg = 1'b1;
        end
        
        7'b0100011: begin // sw (Store Word)
            ALUOp = 2'b00; // ALUOp 00: Memory (Forces ADD to calculate address)
            ALUSrc = 1'b1;
            MemWrite = 1'b1;
        end
        
        7'b1100011: begin // B-type (beq, bne)
            ALUOp = 2'b01; // ALUOp 01: Branch (Forces SUB to compare registers)
            Branch = 1'b1;
        end
        
        7'b0010011: begin // I-type (addi, ori, andi, etc.)
            RegWrite = 1'b1;
            ALUOp = 2'b11; // ALUOp 11: I-Type (Forces ADD for ADDI, ignores negative immediate bit)
            ALUSrc = 1'b1;
        end
        
        7'b1101111: begin // jal (Jump and Link)
            RegWrite = 1'b1;
            Jump = 1'b1;
            // ALUOp doesn't matter here since ALU isn't used for JAL address calculation
        end
        
        7'b1100111: begin // jalr (Jump and Link Register)
            RegWrite = 1'b1;
            ALUSrc = 1'b1;     // Feed immediate to ALU
            ALUOp = 2'b00;     // ALUOp 00: Forces ADD (rs1 + imm)
            Jump = 1'b1;       // Save PC + 4 to register file
            JumpReg = 1'b1;    // Route ALU result to the PC
        end
        
        default: begin
            // safe defaults already set at the top
        end
    endcase
end
endmodule