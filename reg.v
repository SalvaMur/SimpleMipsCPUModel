//Model for Data Memory in Single Cycle MIPS Architecture (Ver. 1.0)
module regfile (Clock, Write, reg1, reg2, reg3, r1Out, r2Out, r3In);

    input Clock;
    input  wire Write;
    input [4:0] reg1,reg2,reg3;
    input [31:0] r3In;
    output wire [31:0] r1Out, r2Out;

    logic [31:0] mem[31:0]; //for data part (addr: 0-255)


    initial begin
    mem[0] <= 32'h0;
    mem[1] <= 32'h0;
    mem[2] <= 32'h0;
    mem[3] <= 32'h0;
    mem[4] <= 32'h0;
    mem[5] <= 32'h0;
    mem[6] <= 32'h0;
    mem[7] <= 32'h0;
    mem[8] <= 32'h0;
    mem[9] <= 32'h0;
    mem[10] <= 32'h0;
    mem[11] <= 32'h0;
    mem[12] <= 32'h0;
    mem[13] <= 32'h0;
    mem[14] <= 32'h0;
    mem[15] <= 32'h0;
    mem[16] <= 32'h0;
    mem[17] <= 32'h0;
    mem[18] <= 32'h0;
    mem[19] <= 32'h0;
    mem[20] <= 32'h0;
    mem[21] <= 32'h0;
    mem[22] <= 32'h0;
    mem[23] <= 32'h0;
    mem[24] <= 32'h0;
    mem[25] <= 32'h0;
    mem[26] <= 32'h0;
    mem[27] <= 32'h0;
    mem[28] <= 32'h0;
    mem[29] <= 32'h0;
    mem[30] <= 32'h0;
    mem[31] <= 32'h0;
    end

        assign r1Out = mem[reg1];
        assign r2Out = mem[reg2];

    always @(negedge Clock) begin

if (Write && (reg3 != 5'h0)) begin

	    mem[reg3] <= r3In;
	end
    end

endmodule
