`timescale 1ns / 1ps
module ControlPath_tb;
    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;   
    wire RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;

    MainControl MC (
        .opcode(opcode), 
        .RegWrite(RegWrite), .ALUSrc(ALUSrc), .MemRead(MemRead), 
        .MemWrite(MemWrite), .MemtoReg(MemtoReg), .Branch(Branch), .ALUOp(ALUOp)
    );             
    ALUControl AC (
        .ALUOp(ALUOp), .funct3(funct3), .funct7(funct7), 
        .ALUControl(ALUControl)
    );
    initial begin
        //R TYPE (Opcode 0110011)
        opcode = 7'b0110011; 
        // ADD
        funct3 = 3'b000; funct7 = 7'b0000000; #10;
        // SUB
        funct3 = 3'b000; funct7 = 7'b0100000; #10;
        // SLL, SRL, AND, OR, XOR where funct7 = 0
        funct3 = 3'b001; funct7 = 7'b0000000; #10; // SLL
        funct3 = 3'b101; funct7 = 7'b0000000; #10; // SRL
        funct3 = 3'b111; funct7 = 7'b0000000; #10; // AND
        funct3 = 3'b110; funct7 = 7'b0000000; #10; // OR
        funct3 = 3'b100; funct7 = 7'b0000000; #10; // XOR
        // I TYPE, LOAD, STORE, BRANCH
        opcode = 7'b0010011; funct3 = 3'b000; #10; // ADDI
        opcode = 7'b0000011; funct3 = 3'b010; #10; // LW
        opcode = 7'b0100011; funct3 = 3'b010; #10; // SW
        opcode = 7'b1100011; funct3 = 3'b000; #10; // BEQ
        
        $finish;
    end
endmodule