module regfile (
	clock,
	ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg,
	data_readRegA, data_readRegB,
	data_player_x, data_player_y,
	data_target_x, data_target_y
);

	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;

	output [31:0] data_readRegA, data_readRegB, data_player_x, data_player_y, data_target_x, data_target_y;

	// add your code here
	wire[31:0] reg_write_en;
	decoder_32 decode_write(reg_write_en, ctrl_writeReg, ctrl_writeEnable);

	wire[31:0] data_out[31:0];
	dff_32 dff_0(data_out[0], 32'b0, clock, reg_write_en[0], ctrl_reset);
	genvar i;
	generate
		for (i = 1; i < 32; i = i+1) begin: loop1
			dff_32 a_dff_32(data_out[i], data_writeReg, clock, reg_write_en[i], ctrl_reset);
		end
	endgenerate


	wire[31:0] read_A_en;
	decoder_32 decode_writeA(read_A_en, ctrl_readRegA, 1'b1);

	wire[31:0] tri_A_out;
	generate
		for (i = 0; i < 32; i = i+1) begin: loop2
			tri_state_buffer_32 a_tri_buffer(data_readRegA, data_out[i], read_A_en[i]);
		end
	endgenerate

	wire[31:0] read_B_en;
	decoder_32 decode_writeB(read_B_en, ctrl_readRegB, 1'b1);

	wire[31:0] tri_B_out;
	generate
		for (i = 0; i < 32; i = i+1) begin: loop3
			tri_state_buffer_32 a_tri_buffer(data_readRegB, data_out[i], read_B_en[i]);
		end
	endgenerate

	// Piping
	assign data_player_x = data_out[27];
	assign data_player_y = data_out[25];
	assign data_target_x = data_out[24];
 	assign data_target_y = data_out[23];
endmodule
