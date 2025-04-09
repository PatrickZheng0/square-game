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

module Wrapper (
	// Board Signals
	input clk_100mHz, 
	input reset,

	// VGA Controller
	output[3:0] VGA_R,  // Red Signal Bits
	output[3:0] VGA_G,  // Green Signal Bits
	output[3:0] VGA_B,  // Blue Signal Bits
	inout ps2_clk,
	inout ps2_data,
	output hSync, 		// H Sync Signal
	output vSync, 		// Veritcal Sync Signal

	// Accelerometer
	output sclk,
	input miso,
	output mosi,
	output ss,

	// Buttons
	input BTND,
	input BTNL,
	input BTNR,
	input BTNU
	);

	// Clock Management
	wire locked, clk_25mHz, clk_50mHz;
	clk_wiz_0 pll_25MHz (
		// Clock out ports
		.clk_out50(clk_50mHz),
		.clk_out25(clk_25mHz),
		// Status and control signals
		.reset(1'b0),
		.locked(locked),
		// Clock in ports
		.clk_in100(clk_100mHz)
	);


	// VGA
	VGAController vga_control(
		.clk_25mHz(clk_25mHz),
		.reset(reset),
		.hSync(hSync),
		.vSync(vSync),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.ps2_clk(ps2_clk),
		.ps2_data(ps2_data),
		.BTNU(BTNU),
		.BTNR(BTNR),
		.BTNL(BTNL),
		.BTND(BTND),
		.accel_x(accel_x_out),
		.accel_y(accel_y_out)
	);


	// Clock
	wire clock;
	assign clock = clk_50mHz;

	// Accelerometer
	wire[8:0] accel_x_out, accel_y_out;
	AccelerometerCtl accel_control(
		.SYSCLK(clock),
		.RESET(reset),
		.SCLK(sclk),
		.MOSI(mosi),
		.MISO(miso),
		.SS(ss),
		.ACCEL_X_OUT(accel_y_out), // accelerometer on FPGA is sideways
		.ACCEL_Y_OUT(accel_x_out) // accelerometer on FPGA is sideways
	);


	// CPU
	wire rwe, mwe;
	wire[4:0] rd, rs1, rs2;
	wire[31:0] instAddr, instData, 
		rData, regA, regB,
		memAddr, memDataIn, memDataOut;


	// ADD YOUR MEMORY FILE HERE
	localparam INSTR_FILE = "";
	
	// Main Processing Unit
	processor CPU(.clock(clock), .reset(reset), 
								
		// ROM
		.address_imem(instAddr), .q_imem(instData),
									
		// Regfile
		.ctrl_writeEnable(rwe),     .ctrl_writeReg(rd),
		.ctrl_readRegA(rs1),     .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB),
									
		// RAM
		.wren(mwe), .address_dmem(memAddr), 
		.data(memDataIn), .q_dmem(memDataOut),
		
		// Piped
		.player_position_x_raw_in(accel_x_out),
		.player_position_y_raw_in(accel_y_out)
		); 
	
	// Instruction Memory (ROM)
	ROM #(.MEMFILE({INSTR_FILE, ".mem"}))
	InstMem(.clk(clock), 
		.addr(instAddr[11:0]), 
		.dataOut(instData));
	
	// Register File
	regfile RegisterFile(.clock(clock), 
		.ctrl_writeEnable(rwe), .ctrl_reset(reset), 
		.ctrl_writeReg(rd),
		.ctrl_readRegA(rs1), .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB));
						
	// Processor Memory (RAM)
	RAM ProcMem(.clk(clock), 
		.wEn(mwe), 
		.addr(memAddr[11:0]), 
		.dataIn(memDataIn), 
		.dataOut(memDataOut));

endmodule
