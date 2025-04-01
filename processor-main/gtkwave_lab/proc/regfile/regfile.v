/**
 * Standard register file module
 * $r0 is hardwired to 0
 * 
 * @param WIDTH: Width of the register
 * @param SIZE: Number of registers
 */

module regfile #(
	parameter WIDTH = 32,  // width of the register
	parameter SIZE = 32  // number of registers
)( 
	clock,
	ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readReg, data_writeReg,
	data_readReg
);

    localparam REGBITS = $clog2(SIZE);

    // Set up inputs and outputs 
	input clock, ctrl_writeEnable, ctrl_reset;
	input [REGBITS-1:0] ctrl_writeReg, ctrl_readReg;
	input [WIDTH-1:0] data_writeReg;
	output [WIDTH-1:0] data_readReg;

    // Decode read and write registers
	wire [SIZE-1:0] decoded_readReg;
	wire [SIZE-1:0] decoded_writeReg;
	
	decoder #(.WIDTH(SIZE), .SELECT_BITS(REGBITS)) read_decode(.out(decoded_readReg), .select(ctrl_readReg), .enable(1'b1));
	decoder #(.WIDTH(SIZE), .SELECT_BITS(REGBITS)) write_reg_decode(.out(decoded_writeReg), .select(ctrl_writeReg), .enable(ctrl_writeEnable));

    // Generate registers
	genvar i;
	generate
		for (i = 1; i < SIZE; i = i + 1) begin: loop1
			wire [WIDTH-1:0] regOut;
			register #(.WIDTH(WIDTH)) reg32(
				.clock(clock),
				.we(decoded_writeReg[i]),
				.reset(ctrl_reset),
				.dataWrite(data_writeReg),
				.dataRead(regOut)
			);
			assign data_readReg = decoded_readReg[i] ? regOut : {WIDTH{1'bz}}; 
		end
	endgenerate

    // Special case for $r0
    assign data_readReg = decoded_readReg[0] ? {WIDTH{1'b0}} : {WIDTH{1'bz}};
endmodule
