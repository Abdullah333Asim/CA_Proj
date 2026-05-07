`timescale 1ns / 1ps

module immGen(
    input [31:0] inst,
    output reg [31:0] imm
);

    wire [6:0] opcode = inst[6:0];

    always @(*) begin
        case(opcode)
            // I-type (lw, addi, etc.)
            7'b0000011, 7'b0010011, 7'b1100111: begin
                imm = {{20{inst[31]}}, inst[31:20]};
            end
            
            // S-type (sw)
            7'b0100011: begin
                imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            end
            
            // B-type (beq, bne, etc.)
            7'b1100011: begin
                // Since branchAdder calculates PC + (imm << 1),
                // the immediate generator provides the pre-shifted 12-bit signed value.
                imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8]};
            end
            
            default: begin
                imm = 32'd0;
            end
        endcase
    end

endmodule
