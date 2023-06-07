// Import modules
`include "imem.v"
`include "reg.v"
`include "dmem.v"
`include "alu.v"

module pcmux(PC, instruction, AddResult, PCSrc, PCNext);
    input [31:0] PC;
    input [31:0] instruction;
    input [31:0] AddResult;
    input PCSrc;
    output reg [31:0] PCNext;

    always @(PC, instruction, PCSrc, AddResult) begin
        case(instruction[31:26])
            6'h2: PCNext = {PC[31:28], instruction[25:0], 2'b00}; // If instruction is jump
            default: begin
                case(PCSrc)
                    1'b0: PCNext = PC + 4;
                    1'b1: PCNext = AddResult;
                    default: PCNext = PC + 4; // PCSrc is undefined
                endcase
            end
        endcase
    end
endmodule

module alucontrol(funct, ALUOp, ALUctl);
	input [5:0] funct;
    input [1:0] ALUOp;
	output reg [4:0] ALUctl;

	always @(funct, ALUOp) begin
        case(ALUOp)
            2'b00: ALUctl = 5'h2; // addi, lw, and sw (add)
            2'b01: ALUctl = 5'h6; // beq and bne (sub)
            2'b10: begin // Use 'funct' to determine ALUctl
                case(funct)
                    6'h24: ALUctl = 5'h0; // and
                    6'h25: ALUctl = 5'h1; // or
                    6'h20: ALUctl = 5'h2; // add
                    6'h22: ALUctl = 5'h6; // sub
                    6'h2a: ALUctl = 5'h7; // slt
                    6'h27: ALUctl = 5'hc; // nor
                    default: ALUctl = 5'hx;
                endcase
            end
            default: ALUctl = 5'hx;
        endcase
	end
endmodule

module control(instruction, EX, M, WB);
    input [31:0] instruction;
    output reg [3:0] EX;
    output reg [2:0] M;
    output reg [1:0] WB;

    always @(instruction) begin
        case (instruction[31:26]) // Check instruction opcode
            6'h0: begin // R-type
                EX = 4'b1100;
                M = 3'b000;
                WB = 2'b10;
            end
            6'h23: begin // lw
                EX = 4'b0001;
                M = 3'b010;
                WB = 2'b11;
            end
            6'h2b: begin // sw
                EX = 4'bx001;
                M = 3'b001;
                WB = 2'b0x;
            end
            6'h4: begin // beq
                EX = 4'bx010;
                M = 3'b100;
                WB = 2'b0x;
            end
            6'h5: begin // bne
                EX = 4'bx010;
                M = 3'b100;
                WB = 2'b0x;
            end
            6'h8: begin // addi
                EX = 4'b0001;
                M = 3'bxxx;
                WB = 2'b10;
            end
            default: begin
                EX = 4'bxxxx;
                M = 3'bxxx;
                WB = 2'bxx;
            end
        endcase
    end
endmodule

module cpu;
    reg clk = 1;
    wire [3:0] EX;   // [3] RegDst,      [2] ALUOp1,     [1] ALUOp0,     [0] ALUSrc
    wire [2:0] M;    // [2] Branch,      [1] MemRead,    [0] MemWrite
    wire [1:0] WB;   // [1] RegWrite,    [0] MemToReg
    reg [31:0] PC = 32'h0;
    wire [31:0] PCNext;
    wire [31:0] instruction;

    // If instruction is R-type, write to 'rd'; If not, write to 'rt'
    wire RegDst = EX[3];
    wire [4:0] regWriteReg = (RegDst == 1'b1) ? instruction[15:11] : rt;
    wire [4:0] rs = instruction[25:21];
    wire [4:0] rt = instruction[20:16];
    wire RegWrite = WB[1];
    wire [31:0] rsout, rtout;

    wire signed [31:0] A = rsout;
    wire signed [31:0] B = (ALUSrc == 1'b0) ? rtout : {{16{instruction[15]}}, instruction[15:0]};
    wire ALUSrc = EX[0];
    wire [1:0] ALUOp = EX[2:1];
    wire [4:0] ALUctl;
    wire signed [31:0] ALUOut;
    wire Zero;

    wire [31:0] AddResult = (PC + 4) + ({{16{instruction[15]}}, instruction[15:0]}<<2);
    wire Branch = M[2];
    wire PCSrc = (instruction[31:26] == 6'h5) ? (!Zero) && Branch : Zero && Branch;

    wire memR = M[1];
    wire memW = M[0];
    wire [31:0] memAddr = ALUOut;
    wire [31:0] dmemIn = rtout;
    wire [31:0] dmemOut;

    wire MemToReg = WB[0];
    wire [31:0] regUpdate = (MemToReg == 1'b1) ? dmemOut : ALUOut;

    regfile regdata(clk, RegWrite, rs, rt, regWriteReg, rsout, rtout, regUpdate);
    imem instruction_mem(PC, instruction);
    dmem data_mem(clk, memR, memW, memAddr, dmemIn, dmemOut);
    alu mips_alu(ALUctl, A, B, ALUOut, Zero);

    control inst_control(instruction, EX, M, WB);
    alucontrol alu_ctl(instruction[5:0], ALUOp, ALUctl);
    pcmux pc_multiplexer(PC, instruction, AddResult, PCSrc, PCNext);

    always begin
        #5 clk = !clk;
    end

    reg [31:0] i = 1;
    always @(posedge clk) begin
        PC <= PCNext;
        i <= i + 1;

        if (instruction == 32'hC) begin // End of code, syscall called
            $display("------------------------");
            $finish;
        end
    end

    always @(negedge clk) begin
        case(instruction)
            32'hx: begin
                // Do not display anything, invalid instruction
            end
            default: begin
                $display(
                    "Cycle %0d:\nPC: %h, PCNext: %h, Instruction: %h", 
                    i, PC, PCNext, instruction
                );
				$display(
					"Control Signals: \n + EX: %b\t->\tRegDst: %b,\tALUOp: %b,\tALUSrc: %b",
					EX, RegDst, ALUOp, ALUSrc
				);
				$display(
					" + M: %b\t->\tBranch: %b,\tmemR: %b,\tmemW: %b",
					M, Branch, memR, memW
				);
				$display(
					" + WB: %b\t->\tRegWrite: %b,\tMemToReg: %b",
					WB, RegWrite, MemToReg
				);
                $display(
                    "Variables: \n + regWriteReg: %d, rs: %d, rt: %d, rsout: %h, rtout: %h", 
                    regWriteReg, rs, rt, rsout, rtout
                );
                $display(
                    " + A: %0d, B: %0d, ALUctl: %h, ALUOut: %0d, Zero: %h", 
                    A, B, ALUctl, ALUOut, Zero
                );
                $display(
                    " + AddResult: %h, PCSrc: %h, memAddr: %h", 
                    AddResult, PCSrc, memAddr
                );
                $display(
                    " + dmemIn: %h, dmemOut: %h, regUpdate: %h\n",
                    dmemIn, dmemOut, regUpdate
                );
            end
        endcase
    end
endmodule
