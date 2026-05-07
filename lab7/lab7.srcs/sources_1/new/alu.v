`timescale 1ns / 1ps
module ALU (
    input [31:0] A,
    input [31:0] B,
    input [3:0] control,
    output reg [31:0] result,
    output Zero
);
    always @(*) begin
        case (control)
            4'b0000: result = A & B;   
            4'b0001: result = A | B;      
            4'b0010: result = A + B;        
            4'b0110: result = A - B;           
            4'b0111: result = A ^ B;
            4'b1000: result = A << B[4:0]; 
            4'b1001: result = A >> B[4:0];
            default: result = 32'b0;
        endcase
    end
    
    assign Zero = (result == 32'b0) ? 1'b1 : 1'b0;
    
endmodule