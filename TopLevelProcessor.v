`timescale 1ns / 1ps

module TopLevelProcessor(
    input clk,            // This is the 100MHz clock from the Basys 3 W5 pin
    input rst,
    input [15:0] sw,      // Physical switches on the FPGA board
    output reg [15:0] led // Physical LEDs on the FPGA board
);

    // ================= Clock Divider (100MHz to 10MHz) =================
    reg [2:0] clk_div_counter = 0;
    reg clk_10MHz = 0; 
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_div_counter <= 0;
            clk_10MHz <= 0;
        end else begin
            // 100MHz / 10 = 10MHz (Toggles every 5 cycles)
            if (clk_div_counter == 3'd4) begin 
                clk_div_counter <= 0;
                clk_10MHz <= ~clk_10MHz;
            end else begin
                clk_div_counter <= clk_div_counter + 1;
            end
        end
    end

    // ================= PC Wires =================
    wire [31:0] pc_out;
    wire [31:0] pc_plus_4;
    wire [31:0] branch_target;
    wire [31:0] next_pc;
    wire PCSrc;

    // ================= Instruction Memory Wires =================
    wire [31:0] instruction;

    // ================= Control Signals =================
    wire RegWrite, MemRead, MemWrite, ALUSrc, MemtoReg, Branch, Jump, JumpReg;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;

    // ================= Register File Wires =================
    wire [4:0] rs1, rs2, rd;
    wire [31:0] read_data1, read_data2, write_data;

    // ================= Immediate Generator Wires =================
    wire [31:0] imm_out;

    // ================= ALU Wires =================
    wire [31:0] alu_in2, alu_result;
    wire zero;

    // ================= Data Memory Wires =================
    wire [31:0] data_mem_read;

    // ================= 1. Program Counter Datapath =================
    ProgramCounter pc_inst(
        .clk(clk_10MHz),
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

    // Evaluate branch conditions based on funct3
    // funct3 == 3'b000 is BEQ (Branch if zero is 1)
    // funct3 == 3'b001 is BNE (Branch if zero is 0)
    wire branch_condition_met = (funct3 == 3'b000 & zero) | (funct3 == 3'b001 & ~zero);
    
    // PC updates to branch target if it's a valid branch OR if it's a Jump instruction
    assign PCSrc = (Branch & branch_condition_met) | Jump;
    
    wire [31:0] next_pc_branch;
    
    mux2 pc_mux_inst(
        .in0(pc_plus_4),
        .in1(branch_target),
        .sel(PCSrc),
        .out(next_pc_branch)
    );

    // JALR selection: Intercepts the PC path to route the ALU result instead
    mux2 jr_mux_inst(
        .in0(next_pc_branch),
        .in1(alu_result),
        .sel(JumpReg),
        .out(next_pc)
    );

    // ================= 2. Instruction Memory =================
    InstructionMemory imem_inst(
        .address(pc_out),
        .read_data(instruction)
    );

    // ================= Decode Fields =================
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd  = instruction[11:7];
    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];

    // ================= 3. Control Unit =================
    main_control main_ctrl_inst(
        .opcode(opcode),
        .RegWrite(RegWrite),
        .ALUOp(ALUOp),
        .MemRead(MemRead),       
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),
        .Branch(Branch),
        .Jump(Jump),
        .JumpReg(JumpReg)
    );

    alu_control alu_ctrl_inst(
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .ALUControl(ALUControl)
    );

    // ================= 4. Register File & Immediate Generator =================
    RegisterFile reg_file_inst(
        .clk(clk_10MHz),
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

    // ================= 5. ALU =================
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

    // ================= 6. Data Memory =================
    DataMemory data_mem_inst(
        .clk(clk_10MHz),
        .MemWrite(MemWrite),
        .address(alu_result),
        .write_data(read_data2),
        .read_data(data_mem_read)
    );

    // ================= 7. Write Back Mux & MMIO Read =================
    wire [31:0] mem_to_reg_data;
    
    // MMIO Read: If address is 512, read the switches. Otherwise, read the RAM.
    wire [31:0] actual_mem_read;
    assign actual_mem_read = (alu_result == 32'd512) ? {16'd0, sw} : data_mem_read;
    
    // Normal Data/ALU selection (Updated to use actual_mem_read)
    mux2 wb_mux_inst(
        .in0(alu_result),
        .in1(actual_mem_read),
        .sel(MemtoReg),
        .out(mem_to_reg_data)
    );
    
    // Jump and Link selection: If Jump is high, write PC + 4 to register
    mux2 jump_wb_mux_inst(
        .in0(mem_to_reg_data),
        .in1(pc_plus_4),
        .sel(Jump),
        .out(write_data)
    );
    
    // ================= 8. MMIO Write (LEDs) =================
    always @(posedge clk_10MHz or posedge rst) begin
        if (rst) begin
            led <= 16'd0;
        end else if (MemWrite && (alu_result == 32'd256)) begin
            // If writing to address 256, capture the lower 16 bits to the LEDs
            led <= read_data2[15:0];
        end
    end

endmodule