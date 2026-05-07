`timescale 1ns / 1ps

module TopLevelProcessor(
    input clk,
    input rst,
    output [31:0] test_out
);

    // PC Wires
    wire [31:0] pc_out;
    wire [31:0] pc_plus_4;
    wire [31:0] branch_target;
    wire [31:0] next_pc;
    wire PCSrc;

    // Instruction Memory Wires
    wire [31:0] instruction;

    // Control Signals 
    wire RegWrite, MemRead, MemWrite, ALUSrc, MemtoReg, Branch;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;

    // Register File Wires
    wire [4:0] rs1, rs2, rd;
    wire [31:0] read_data1, read_data2, write_data;

    // Immediate Generator Wires
    wire [31:0] imm_out;

    //ALU Wires
    wire [31:0] alu_in2, alu_result;
    wire zero;

    //Data Memory Wires
    wire [31:0] data_mem_read;

    // Program Counter Datapath 
    ProgramCounter pc_inst(
        .clk(clk),
        .reset(rst),
        .next_pc(next_pc),
        .pc(pc_out)
    );

    pcAdder pc_add_inst(
        .pc(pc_out),
        .pc_plus_4(pc_plus_4)
    );

    branchAdder branch_add_inst(
        .pc(pc_out),
        .imm(imm_out),
        .branch_target(branch_target)
    );

    assign PCSrc = Branch & zero;

    mux2 pc_mux_inst(
        .in0(pc_plus_4),
        .in1(branch_target),
        .sel(PCSrc),
        .out(next_pc)
    );

    // Instruction Memory
    InstructionMemory imem_inst(
        .address(pc_out),
        .read_data(instruction)
    );

    // Decode Fields 
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd  = instruction[11:7];
    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];

    // Control Unit
    main_control main_ctrl_inst(
        .opcode(opcode),
        .RegWrite(RegWrite),
        .ALUOp(ALUOp),
        .MemRead(MemRead),       
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),
        .Branch(Branch)
    );

    alu_control alu_ctrl_inst(
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .ALUControl(ALUControl)
    );

    // Register File & Immediate Generator
    RegisterFile reg_file_inst(
        .clk(clk),
        .rst(rst),
        .WriteEnable(RegWrite),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .WriteData(write_data),
        .ReadData1(read_data1),
        .ReadData2(read_data2)
    );

    immGen imm_gen_inst(
        .inst(instruction),
        .imm(imm_out)
    );

    //ALU 
    mux2 alu_mux_inst(
        .in0(read_data2),
        .in1(imm_out),
        .sel(ALUSrc),
        .out(alu_in2)
    );

    ALU alu_inst(
        .A(read_data1),
        .B(alu_in2),
        .ALUControl(ALUControl),
        .ALUResult(alu_result),
        .Zero(zero)
    );

    // Data Memory 
    DataMemory data_mem_inst(
        .clk(clk),
        .MemWrite(MemWrite),
        .address(alu_result),
        .write_data(read_data2),
        .read_data(data_mem_read)
    );

    //Write Back Mux 
    mux2 wb_mux_inst(
        .in0(alu_result),
        .in1(data_mem_read),
        .sel(MemtoReg),
        .out(write_data)
    );
    
    assign test_out = alu_result;
endmodule
