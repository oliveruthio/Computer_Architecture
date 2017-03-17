// single-cycle MIPS processor
// instantiates a controller and a datapath module

module mips(input          clk, reset,
            output  [31:0] pc,
            input   [31:0] instr,
            output         memwrite,
            output  [31:0] aluout, writedata,
            input   [31:0] readdata);

  wire        memtoreg, branch,
               zero,
               alusrc, regdst, regwrite, jump, bne_enable, zero_ext;
  wire [2:0]  alucontrol;

  controller c(instr[31:26], instr[5:0], zero,
               memtoreg, memwrite,
               alusrc, regdst, regwrite, jump,
	       branch, bne_enable, zero_ext,
               alucontrol);
  datapath dp(clk, reset, memtoreg,
              alusrc, regdst, regwrite, jump, branch, bne_enable, zero_ext,
              alucontrol,
              zero, pc, instr,
              aluout, writedata, readdata);
endmodule


// Todo: Implement controller module
module controller(input   [5:0] op, funct,
                  input         zero,
                  output reg       memtoreg, memwrite,
                  output reg       alusrc,
                  output reg       regdst, regwrite,
                  output reg       jump, branch, bne_enable,  zero_ext,
                  output reg [2:0] alucontrol);

// **PUT YOUR CODE HERE**
  always @ * begin
   case (op) 
    6'b000000 : begin // R-TYPE
      branch <= 0;
      memtoreg <= 0;
      memwrite <= 0;
      alusrc <= 0;
      regdst <= 1;
      regwrite <= 1;
      jump <= 0;
      case (funct)
	6'b100000: alucontrol <= 3'b010;
	6'b100010: alucontrol <= 3'b110;
	6'b100100: alucontrol <= 3'b000;
	6'b100101: alucontrol <= 3'b001;
	6'b101010: alucontrol <= 3'b111;
	default: alucontrol <= 3'bxxx;
      endcase
    end
    6'b100011 : begin // lw
      zero_ext <= 0;
      branch <= 0;
      memtoreg <= 1;
      memwrite <= 0;
      alusrc <= 1;
      regdst <= 0;
      regwrite <= 1;
      jump <= 0;
      alucontrol <= 3'b010;
    end
    6'b101011 : begin // sw
      zero_ext <= 0;
      branch <= 0;
      memtoreg <= 1'bx;
      memwrite <= 1;
      alusrc <= 1;
      regdst <= 1'bx;
      regwrite <= 0;
      jump <= 0;
      alucontrol <= 3'b010;
    end
    6'b000100 : begin // beq
      zero_ext <= 0;
      bne_enable <= 0;
      branch <= 1;
      memtoreg <= 1'bx;
      memwrite <= 0;
      alusrc <= 0;
      regdst <= 1'bx;
      regwrite <= 0;
      jump <= 0;
      alucontrol <= 3'b110;
    end
    6'b001000 : begin // addi
      zero_ext <= 0;
      branch <= 0;
      memtoreg <= 0;
      memwrite <= 0;
      alusrc <= 1;
      regdst <= 0;
      regwrite <= 1;
      jump <= 0;
      alucontrol <= 3'b010;
    end
    6'b000010 : begin // j
      branch <= 0;
      memtoreg <= 1'bx;
      memwrite <= 0;
      alusrc <= 1'bx;
      regdst <= 1'bx;
      regwrite <= 0;
      jump <= 1;
      alucontrol <= 3'b010;
    end
    6'b000101 : begin // bne
      zero_ext <= 0;
      bne_enable <= 1;
      branch <= 1;
      memtoreg <= 1'bx;
      memwrite <= 0;
      alusrc <= 0;
      regdst <= 1'bx;
      regwrite <= 0;
      jump <= 0;
      alucontrol <= 3'b110;
    end
    6'b001101 : begin // ori
      zero_ext <= 1;
      branch <= 0;
      memtoreg <= 0;
      memwrite <= 0;
      alusrc <= 1;
      regdst <= 0;
      regwrite <= 1;
      jump <= 0;
      alucontrol <= 3'b001;
    end
   endcase
  end 

endmodule


// Todo: Implement datapath
module datapath(input          clk, reset,
                input          memtoreg,
                input          alusrc, regdst,
                input          regwrite, jump, branch, bne_enable, zero_ext,
                input   [2:0]  alucontrol,
                output         zero,
                output reg [31:0] pc,
                input   [31:0] instr,
                output  [31:0] aluout, writedata,
                input   [31:0] readdata);

// **PUT YOUR CODE HERE**                
  reg [4:0] writereg;
  reg [31:0] pcnext, pcnextbr, pcplus4, pcbranch;
  reg [31:0] signimm, signimmsh;
  reg [31:0] srca, srcb;
  reg [31:0] result;
  reg pcsrc, xor_output;
  reg [31:0] sign_ext_output, zero_ext_output;

  initial  pc = 32'b0;

  //PC LOGIC
  flopr pc_reg(clk, reset, pcnext, pc);
  adder pc_add1(pc, 32'b100, pcplus4);
  sl2 immsh(signimm, signimmsh);
  adder pc_add2(pcplus4, signimmsh, pcbranch);

  xor xor_bne(xor_output, bne_enable, zero);
  and and_pcsrc(pcsrc, branch, xor_output);

  mux2 pcbrmux(pcplus4, pcbranch, pcsrc, pcnextbr);
  mux2 pcmux(pcnextbr, {pcplus4[31:28], instr[25:0], 2'b00}, jump, pcnext);
  
  // Register file logic
  regfile rf(clk, regwrite, instr[25:21], instr[20:16], writereg, result, srca, writedata);
  fivebitmux2 wrmux(instr[20:16], instr[15:11], regdst, writereg);
  mux2 resmux(aluout, readdata,memtoreg, result);

  // Add logic for ori
  sign_ext se(instr[15:0], sign_ext_output);
  zero_ext ze(instr[15:0], zero_ext_output);
  mux2 extend_mux(sign_ext_output, zero_ext_output, zero_ext, signimm);
  
  // ALU Logic
  mux2 srcbmux(writedata, signimm, alusrc, srcb);
  ALU  alu(srca, srcb, alucontrol, aluout, zero);
endmodule


