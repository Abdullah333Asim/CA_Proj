`timescale 1ns / 1ps

module branchAdder(
    input [31:0] pc,
    input [31:0] imm,
    output [31:0] branch_target
);

    // Shifts immediate left by 1 (equivalent to multiplying by 2)
    // and adds it to the current PC to get the branch target address.
    assign branch_target = pc + (imm << 1);

endmodule
