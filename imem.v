//Model for Instruction Memory in Single Cycle MIPS Architecture (Ver. 1.0)
module imem (Addr, DataOut);

    //IO signals
    input [31:0] Addr; //32-bit address bus
    output [31:0] DataOut;

    //declare memory words
    reg [31:0] mem[256:1023]; //instructions start at 0x100 (addr: 256 - 1023)

    //initialize memory words (with a test program)
    initial begin
	mem[32'h0000_0100] <= 32'h2002_0140;	//addi	$2 $0 320
	mem[32'h0000_0104] <= 32'h2003_0036;	//addi	$3 $0 54
	mem[32'h0000_0108] <= 32'h0060_2820;	//add	$5 $3 $0
	mem[32'h0000_010c] <= 32'h0000_2020;	//add	$4 $0 $0
	mem[32'h0000_0110] <= 32'h0082_2020;	//add	$4 $4 $2
	mem[32'h0000_0114] <= 32'h20A5_FFFE;	//addi	$5 $5 -2
	mem[32'h0000_0118] <= 32'h10A0_0001;	//beq	$5 $0 exit
	mem[32'h0000_011c] <= 32'h0800_0045;	//j	loop
	mem[32'h0000_0120] <= 32'h0000_000C;	//syscall	0
    end

    //word (instruction) read operation
    wire [31:0] WordAddr;
    assign WordAddr = {Addr[31:2], 2'b00};
    assign DataOut = mem[WordAddr]; //word read

endmodule