module tb();
reg clk;
reg reset;
reg [31:0] writedata, dataadr;
reg memwrite;
// instantiate device to be tested
top dut (clk, reset);
// initialize test
initial reset <= 0;

// generate clock to sequence tests
always begin
clk <= 0; 
# 5; 
clk <= 1;
# 5;
end
endmodule
