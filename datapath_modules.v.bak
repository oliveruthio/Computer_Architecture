module regfile(input clk, we3,
		input [4:0] ra1, ra2, wa3,
		input [31:0] wd3,
		output reg [31:0] rd1, rd2);
  reg [31:0] RAM [31:0];
  reg [31:0] index;
initial begin // initialize registers to 0
  for (index=0; index < 32; index = index + 1)
 	 RAM[index] = 32'b0;
end


  always @ (posedge clk)
    if (we3) RAM[wa3] <= wd3; // if enabled, write to register
  assign rd1 = (ra1 != 0) ? RAM[ra1] : 0; // Assign read values
  assign rd2 = (ra2 != 0) ? RAM[ra2] : 0;
endmodule

// D flip-flop
module flopr(input clk, reset,
		input [31:0] d,
		output reg [31:0] q);
always @ (posedge clk) begin
  if (reset) q <= 0;
  else q <= d;
end
endmodule 

// Sign extend
module sign_ext(input [15:0] a,
		output [31:0] y);
	assign y = {{16{a[15]}}, a };
endmodule 

// Zero extend
module zero_ext(input [15:0] a,
		output [31:0] y);
	assign y = {16'b0, a};
endmodule

// Shift left 2
module sl2(input [31:0] a,
	   output [31:0] y);
	assign y = {a[29:0], 2'b00};
endmodule 

// 32-bit 2-input mux
module mux2(input [31:0] d0, d1,
	    input s,
	    output [31:0] y);
	assign  y = s ? d1 : d0;
endmodule 

// 5-bit 2-input mux
module fivebitmux2(input [4:0] d0, d1,
	    input s,
	    output [4:0] y);
	assign  y = s ? d1 : d0;
endmodule 

// 32-bit adder
module adder(input [31:0] a, b,
	     output [31:0] y);
	assign y = a + b;
endmodule 
