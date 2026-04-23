`timescale 1ns / 1ps

module ALU (
    input  [31:0] A,
    input  [31:0] B,
    input  [3:0]  ALUControl,
    output [31:0] ALUResult,
    output        Zero
);

    reg [31:0] result;

    always @(*) begin
        case (ALUControl)
            4'b0000: result = A & B;                            // AND
            4'b0001: result = A | B;                            // OR
            4'b0010: result = A + B;                            // ADD
            4'b0110: result = A - B;                            // SUB
            // Optional/Standard extensions just in case
            4'b0011: result = A ^ B;                            // XOR
            4'b0111: result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; // SLT
            4'b1000: result = (A < B) ? 32'd1 : 32'd0;          // SLTU
            4'b0100: result = A << B[4:0];                      // SLL
            4'b0101: result = A >> B[4:0];                      // SRL
            4'b1001: result = $signed(A) >>> B[4:0];            // SRA
            default: result = 32'd0;
        endcase
    end

    assign ALUResult = result;
    assign Zero = (result == 32'd0);

endmodule
