module alu_control (
input [1:0] ALUOp,
input [2:0] funct3,
input [6:0] funct7,
output reg [3:0] ALUControl
);

always @(*) begin
// default assignment to handle Don't Care (X) conditions safely
ALUControl = 4'b0000;

case (ALUOp)
2'b00: begin // lw, sw
ALUControl = 4'b0010; // add
end
2'b01: begin // beq
ALUControl = 4'b0110; // sub

end
2'b10: begin // R-type or I-type
case(funct3)
3'b000: begin
// In standard RISC-V: R-type add uses funct7 = 0000000, sub uses 0100000
if (funct7[5] == 1'b1)
ALUControl = 4'b0110; // sub
else
ALUControl = 4'b0010; // add
end
3'b111: ALUControl = 4'b0000; // and
3'b110: ALUControl = 4'b0001; // or
default: ALUControl = 4'b0000; // undefined default
endcase
end
default: ALUControl = 4'b0000;
endcase
end
endmodule
