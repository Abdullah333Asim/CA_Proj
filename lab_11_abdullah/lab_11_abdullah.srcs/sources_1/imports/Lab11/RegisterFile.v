module RegisterFile (
input
clk,
input
rst,
input
WriteEnable,
input [4:0] rs1, // read register 1 
input [4:0] rs2, // read register 2 
input [4:0] rd,
input [31:0] WriteData,
output [31:0] ReadData1,
output [31:0] ReadData2
);

reg [31:0] regs [31:0];
integer i;

always @(posedge clk or posedge rst) begin
if (rst) begin
for (i = 0; i < 32; i = i + 1)
regs[i] <= 32'b0;
end
else if (WriteEnable && rd != 0) begin
regs[rd] <= WriteData;
end
end

assign ReadData1 = (rst || rs1 == 0) ? 32'b0 : regs[rs1];

assign ReadData2 = (rst || rs2 == 0) ? 32'b0 : regs[rs2];

endmodule
