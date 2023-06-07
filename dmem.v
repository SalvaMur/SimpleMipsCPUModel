//Model for Data Memory in Single Cycle MIPS Architecture (Ver. 1.0)
module dmem (Clock, Read, Write, Addr, DataIn, DataOut);

    //IO signals
    input Clock; //used for word write after Addr & Data are stable
    input Read, Write;
    input [31:0] Addr;
    input [31:0] DataIn;
    output [31:0] DataOut;

    //declare memory words
    reg [31:0] mem[0:255]; //for data part (addr: 0-255)

    //initialize memory words (with a test program)
    initial begin
    end

    //word address calulation
    wire [31:0] WordAddr;
    assign WordAddr = {Addr[31:2], 2'b00};

    //word (data) read operation - even if Read = 0
    assign DataOut = mem[WordAddr];

    //word (data) write operation after Addr & Data are stable
    always @(negedge Clock) begin
	if (Write) begin
	    mem[WordAddr] <= DataIn;
	end
    end

endmodule