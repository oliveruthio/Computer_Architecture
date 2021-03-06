// External memories used by MIPS single-cycle processor

module dmem(input          clk, we,
            input   [31:0] a, wd,
            output  [31:0] rd);
  reg [31:0] RAM[63:0];  // stores our 64 words.
  assign rd = RAM[a[31:2]]; // reads data that is word aligned
  always@ (posedge clk) begin
    if(we) RAM[a[31:2]] <= wd; // writes data to memory if enabled
  end
endmodule


// Instruction memory (already implemented)
module imem(input   [5:0]  a,
            output  [31:0] rd);

  reg [31:0] RAM[63:0];

  initial
    begin
      $readmemh("memfile2.dat",RAM); // initialize memory with test program. Change this with memfile2.dat for the modified code
    end

  assign rd = RAM[a]; // word aligned
endmodule

