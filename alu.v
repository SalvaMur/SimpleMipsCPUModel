//Model for ALU in Single Cycle MIPS Architecture (Ver. 1.0)
module alu (ALUctl, A, B, ALUOut, Zero);

    //IO signals 
    input [4:0] ALUctl;
    input signed [31:0] A, B; // Group 2 Note: This line was our only change. Added 'signed' keyword
    output [31:0] ALUOut;
    output Zero;

    reg [31:0] ALUOut;

    assign Zero = (ALUOut == 0);

    always @(ALUctl or A or B) begin //reevaluate if these change

	case (ALUctl)
	    4'h0: ALUOut <= A & B;
	    4'h1: ALUOut <= A | B;
	    4'h2: ALUOut <= A + B;
	    4'h6: ALUOut <= A - B;
	    4'h7: ALUOut <= (A < B) ? 1 : 0;
	    4'hc: ALUOut <= ~(A | B);
	    default: ALUOut <= 0;
	endcase



    end

endmodule
