/**
 * READ THIS DESCRIPTION!
 *
 * Modified 4-stage pipelined processor for the GTKWave lab
 *
 * @author: Vincent Chen
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // I: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readReg,                  // O: Register to read from in RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readReg                   // I: Data from read port of RegFile
	 
	);

	// Control signals
	input clock, reset;
	
	// Imem
    input [7:0] address_imem;
	input [14:0] q_imem;

	// Regfile
	output ctrl_writeEnable;
	output [2:0] ctrl_writeReg, ctrl_readReg;
	output [7:0] data_writeReg;
	input [7:0] data_readReg;

	/* YOUR CODE STARTS HERE */

    // ================FETCH STAGE=================== //

    // Latch instruction from imem
    wire [14:0] fdinsn_out;
    register #(.WIDTH(15)) FD_INSN(.clock(~clock), .reset(reset), .we(1'b1), .dataWrite(q_imem), .dataRead(fdinsn_out));

    // ================DECODE STAGE================== //

    // Decode RS register
    assign ctrl_readReg = fdinsn_out[10:8];

    // Latch data from RS
    wire [7:0] dxa_out;
    register #(.WIDTH(8)) DX_A(.clock(~clock), .reset(reset), .we(1'b1), .dataWrite(data_readReg), .dataRead(dxa_out));

    // Latch instruction
    wire [14:0] dxinsn_out;
    register #(.WIDTH(15)) DX_INSN(.clock(~clock), .reset(reset), .we(1'b1), .dataWrite(fdinsn_out), .dataRead(dxinsn_out));

    // ================EXECUTE STAGE================= //

    // Helper wires
    wire [7:0] alu_out;
    wire [7:0] immediate; 
    assign immediate = dxinsn_out[7:0];

    // Use ALU to compute result
    alu ALU(.data_operandA(dxa_out), .data_operandB(immediate), .ctrl_ALUopcode(dxinsn_out[14]), .data_result(alu_out)); 

    // Latch ALU result
    wire [7:0] xwo_out;
    register #(.WIDTH(8)) XW_O(.clock(~clock), .reset(reset), .we(1'b1), .dataWrite(alu_out), .dataRead(xwo_out));

    // Latch instruction
    wire [14:0] xwinsn_out;
    register #(.WIDTH(15)) XW_INSN(.clock(~clock), .reset(reset), .we(1'b1), .dataWrite(dxinsn_out), .dataRead(xwinsn_out));

    // ================WRITEBACK STAGE=============== //

    // Set destination register and data to write
    assign ctrl_writeReg = xwinsn_out[13:11];
    assign data_writeReg = xwo_out;

    // Set write enable
    assign ctrl_writeEnable = 1'b1;
	
	/* END CODE */

endmodule
