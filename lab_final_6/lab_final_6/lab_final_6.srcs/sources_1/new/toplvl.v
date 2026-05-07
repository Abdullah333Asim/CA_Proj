module top_ALU (
    input [5:0] sw_A,         // SW0 to SW5
    input [5:0] sw_B,         // SW6 to SW11
    input [3:0] sw_ctrl,      // SW12 to SW15
    output [14:0] led,        // LED0 to LED14 (Lower 15 bits of result)
    output led_zero           // LED15 (Zero flag)
);

    wire [31:0] A = {26'b0, sw_A};
    wire [31:0] B = {26'b0, sw_B};
    wire [31:0] result;
    wire zero_flag;

    ALU alu_inst (
        .A(A),
        .B(B),
        .control(sw_ctrl),
        .result(result),
        .Zero(zero_flag)
    );

    // Map only the lower 15 bits of the result to the physical LEDs
    assign led = result[14:0]; 
    assign led_zero = zero_flag;

endmodule