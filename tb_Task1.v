`timescale 1ns / 1ps

module tb_Task1;

    // Clock and Reset
    reg clk;
    reg rst;

    // Instruction to Decode
    reg [31:0] inst;

    // Control Signals
    reg PCSrc;

    // Datapath Wires
    wire [31:0] pc_out;
    wire [31:0] pc_plus_4;
    wire [31:0] branch_target;
    wire [31:0] next_pc;
    wire [31:0] imm_out;

    // Instantiate Modules
    ProgramCounter u_pc (
        .clk(clk),
        .reset(rst),
        .next_pc(next_pc),
        .pc(pc_out)
    );

    pcAdder u_pcAdder (
        .pc(pc_out),
        .pc_plus_4(pc_plus_4)
    );

    immGen u_immGen (
        .inst(inst),
        .imm(imm_out)
    );

    branchAdder u_branchAdder (
        .pc(pc_out),
        .imm(imm_out),
        .branch_target(branch_target)
    );

    mux2 u_pcmux (
        .in0(pc_plus_4),
        .in1(branch_target),
        .sel(PCSrc),
        .out(next_pc)
    );

    // Clock Generation
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 1;
        PCSrc = 0;
        inst = 32'd0;

        // Reset the system
        #10;
        rst = 0;

        #10;
        // Test 1: PC Increment by 4 when PCSrc = 0
        // Expect pc_out to become 4
        if (pc_out !== 32'd4) $display("Fail: PC did not increment to 4.");
        else $display("Pass: PC incremented to 4.");

        #10;
        // Expect pc_out to become 8
        if (pc_out !== 32'd8) $display("Fail: PC did not increment to 8.");
        else $display("Pass: PC incremented to 8.");

        // Test 2: Immediate Generation (I-Type, e.g. addi x1, x2, -5)
        // RS1=x2(00010), RD=x1(00001), funct3=000, opcode=0010011, imm=-5 (111111111011)
        inst = 32'b111111111011_00010_000_00001_0010011; 
        #10;
        // Let it compute the immediate (-5)
        if (imm_out !== 32'hFFFFFFFB) $display("Fail: I-Type Immediate Generation failed. Got %h", imm_out);
        else $display("Pass: I-Type Immediate Generation Produced -5 (%h).", imm_out);

        // Test 3: PC updates to Branch Target when PCSrc = 1
        // B-Type instruction, e.g. beq: imm is 12 (0...01100). Wait, 0...0110 for the generated imm
        // Let's manually inject negative branch offset: -8
        // immGen drops bit 0, so -8 is encoded in B-type fields.
        // imm[12:1] of -8 (1111...11111000) is 111111111100 (-4 internally for immGen).
        // let's do an easy B-Type: imm = -4 (immGen outputs -2, then branchAdder << 1 gives -4).
        // 12-bit of -4: 111111111100
        // Inst: imm[12]=1, imm[11]=1, imm[10:5]=111111, imm[4:1]=1110, imm[0]=0
        // inst[31]=1, inst[7]=1, inst[30:25]=111111, inst[11:8]=1110
        // opcode for B-type = 1100011
        inst = {1'b1, 6'b111111, 5'b00000, 5'b00000, 3'b000, 4'b1110, 1'b1, 7'b1100011}; 
        
        #10; // PC is now e.g. 16 or 20
        $display("Generated Immediate before shift: %d", $signed(imm_out));
        $display("Current PC is %d", pc_out);
        
        PCSrc = 1;
        #10;
        // Check new PC
        // Previous PC was 20. Branch target = 20 + (-4) = 16. New PC should be 16.
        if (pc_out !== 32'd16) $display("Fail: Branch PC calculation. Expected 16, got %d", pc_out);
        else $display("Pass: Branch PC updated to target.");

        #10;
        $finish;
    end

endmodule
