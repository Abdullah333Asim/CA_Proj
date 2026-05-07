`timescale 1ns / 1ps
module ALU_tb;
    reg [31:0] A, B;
    reg [3:0] control;
    wire [31:0] result;
    wire Zero;

    ALU uut (.A(A),.B(B),.control(control), .result(result),.Zero(Zero) );

    initial begin
        A = 32'h0000000D;
        B = 32'h00000006;

        // ADD check
        control = 4'b0010; #10;
        // SUB check
        control = 4'b0110; #10;
        // AND check
        control = 4'b0000; #10;
        // OR check
        control = 4'b0001; #10;
        // XOR check
        control = 4'b0111; #10;
        // SLL check
        control = 4'b1000; #10;
        // SRL check
        control = 4'b1001; #10;
        //  BEQ check 
        A = 32'h00000008;
        B = 32'h00000008;
        control = 4'b0110; #10;
        
        $finish;
    end
endmodule
