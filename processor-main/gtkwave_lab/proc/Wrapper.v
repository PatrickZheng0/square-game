`timescale 1ns / 1ps
/**
 * 
 * READ THIS DESCRIPTION:
 *
 * This is the Wrapper module that will serve as the header file combining your processor, 
 * RegFile and Memory elements together.
 *
 * This file will be used to generate the bitstream to upload to the FPGA.
 * We have provided a sibling file, Wrapper_tb.v so that you can test your processor's functionality.
 * 
 * We will be using our own separate Wrapper_tb.v to test your code. You are allowed to make changes to the Wrapper files 
 * for your own individual testing, but we expect your final processor.v and memory modules to work with the 
 * provided Wrapper interface.
 * 
 * Refer to Lab 5 documents for detailed instructions on how to interface 
 * with the memory elements. Each imem and dmem modules will take 12-bit 
 * addresses and will allow for storing of 32-bit values at each address. 
 * Each memory module should receive a single clock. At which edges, is 
 * purely a design choice (and thereby up to you). 
 * 
 * You must change line 36 to add the memory file of the test you created using the assembler
 * For example, you would add sample inside of the quotes on line 38 after assembling sample.s
 *
 **/

module Wrapper (clock, reset);
	input clock, reset;


	wire rwe;
	wire[2:0] rd, rs;
	wire[7:0] rData, regA;
	reg[7:0] instAddr = 8'b0;
	wire[14:0] instData;

	// ADD YOUR MEMORY FILE HERE
	localparam INSTR_FILE = "";

	always @(negedge clock) begin
		if (reset) begin
			instAddr <= 0;
		end else begin
			instAddr <= instAddr + 1;
		end
	end
	
	// Main Processing Unit
	processor CPU(.clock(clock), .reset(reset), 
								
		// ROM
		.address_imem(instAddr), .q_imem(instData),
									
		// Regfile
		.ctrl_writeEnable(rwe), .ctrl_writeReg(rd), .ctrl_readReg(rs), 
		.data_writeReg(rData), .data_readReg(regA)); 
	
	// Instruction Memory (ROM)
	ROM #(.MEMFILE({INSTR_FILE, ".mem"}), .DATA_WIDTH(15), .ADDRESS_WIDTH(8))
	InstMem(.clk(clock), 
		.addr(instAddr), 
		.dataOut(instData));
	
	// Register File
	regfile #(.WIDTH(15), .SIZE(8))
	RegisterFile(.clock(clock), 
		.ctrl_writeEnable(rwe), .ctrl_reset(reset), 
		.ctrl_writeReg(rd), .ctrl_readReg(rs), 
		.data_writeReg(rData), .data_readReg(regA));

endmodule
