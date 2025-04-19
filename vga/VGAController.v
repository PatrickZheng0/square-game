`timescale 1 ns/ 100 ps
module VGAController(     
	input clk_25mHz, 	// 25 MHz PLL Clock
	input clk_100mHz,
	input reset, 		// Reset Signal
	output hSync, 		// H Sync Signal
	output vSync, 		// Veritcal Sync Signal
	output[3:0] VGA_R,  // Red Signal Bits
	output[3:0] VGA_G,  // Green Signal Bits
	output[3:0] VGA_B,  // Blue Signal Bits
	inout ps2_clk,
	inout ps2_data,
	input BTNU,
	input BTNL,
	input BTNR,
	input BTND,
	input[31:0] accel_x,
	input[31:0] accel_y,
	input[31:0] target_x,
	input[31:0] target_y,
	input[31:0] game_state
	);

	// Lab Memory Files Location
	//localparam FILES_PATH = "C:/Users/pzhen/VSCodeProjects/ECE_350_Workspace/square-game/vga/";
	localparam FILES_PATH = "C:/Users/mathe/Documents/Duke/ECE350/Project/square-game/vga/";

	// VGA Timing Generation for a Standard VGA Screen
	localparam 
		VIDEO_WIDTH = 640,  // Standard VGA Width
		VIDEO_HEIGHT = 480; // Standard VGA Height

	wire active, screenEnd;
	wire[9:0] x;
	wire[8:0] y;
	
	VGATimingGenerator #(
		.HEIGHT(VIDEO_HEIGHT), // Use the standard VGA Values
		.WIDTH(VIDEO_WIDTH))
	Display( 
		.clk25(clk_25mHz),  	   // 25MHz Pixel Clock
		.reset(reset),		   // Reset Signal
		.screenEnd(screenEnd), // High for one cycle when between two frames
		.active(active),	   // High when drawing pixels
		.hSync(hSync),  	   // Set Generated H Signal
		.vSync(vSync),		   // Set Generated V Signal
		.x(x), 				   // X Coordinate (from left)
		.y(y)); 			   // Y Coordinate (from top)	   

	// Image Data to Map Pixel Location to Color Address
	localparam 
		PIXEL_COUNT = VIDEO_WIDTH*VIDEO_HEIGHT, 	             // Number of pixels on the screen
		PIXEL_ADDRESS_WIDTH = $clog2(PIXEL_COUNT) + 1,           // Use built in log2 command
		BITS_PER_COLOR = 12, 	  								 // Nexys A7 uses 12 bits/color
		PALETTE_COLOR_COUNT = 256, 								 // Number of Colors available
		PALETTE_ADDRESS_WIDTH = $clog2(PALETTE_COLOR_COUNT) + 1; // Use built in log2 Command

	wire[PIXEL_ADDRESS_WIDTH-1:0] imgAddress;  	 // Image address for the image data
	wire[PALETTE_ADDRESS_WIDTH-1:0] colorAddr; 	 // Color address for the color palette
	assign imgAddress = x + 640*y;				 // Address calculated coordinate

	// RAM #(		
	// 	.DEPTH(PIXEL_COUNT), 				     // Set RAM depth to contain every pixel
	// 	.DATA_WIDTH(PALETTE_ADDRESS_WIDTH),      // Set data width according to the color palette
	// 	.ADDRESS_WIDTH(PIXEL_ADDRESS_WIDTH),     // Set address with according to the pixel count
	// 	.MEMFILE({FILES_PATH, "image.mem"})) // Memory initialization
	// ImageData(
	// 	.clk(clk_100mHz), 						 		// Falling edge of the 100 MHz clk
	// 	.addr(imgAddress),					 // Image data address
	// 	.dataOut(colorAddr),				 // Color palette address
	// 	.wEn(1'b0)); 						 // We're always reading

	// Color Palette to Map Color Address to 12-Bit Color
	wire[BITS_PER_COLOR-1:0] bg_colorData; // 12-bit color data at current pixel
	assign bg_colorData = (game_state == 32'd0) ? 12'h0F0 : 12'h000;
	wire[BITS_PER_COLOR-1:0] player_box_colorData, target_box_colorData; // 12-bit color data at current pixel

	// RAM #(
	// 	.DEPTH(PALETTE_COLOR_COUNT), 		       // Set depth to contain every color		
	// 	.DATA_WIDTH(BITS_PER_COLOR), 		       // Set data width according to the bits per color
	// 	.ADDRESS_WIDTH(PALETTE_ADDRESS_WIDTH),     // Set address width according to the color count
	// 	.MEMFILE({FILES_PATH, "colors.mem"}))  	// Memory initialization
	// ColorPalette(
	// 	.clk(clk_100mHz), 							   	   // Rising edge of the 100 MHz clk
	// 	.addr(colorAddr),					       // Address from the ImageData RAM
	// 	.dataOut(bg_colorData),				       // Color at current pixel
	// 	.wEn(1'b0)); 						       // We're always reading

	// Assign to output color from register if active
	wire[BITS_PER_COLOR-1:0] colorOut; 			  // Output color 
	wire[BITS_PER_COLOR-1:0] colorScreen_final, colorScreen_inter;

	// Draw Player Box
	reg[9:0] player_center_x;
	reg[8:0] player_center_y;
	reg[9:0] player_left_x, player_right_x; 
	reg[8:0] player_top_y, player_bottom_y;
	initial begin
		player_left_x <= 10'd0;
		player_right_x <= 10'd0;
		player_top_y <= 9'd0;
		player_bottom_y <= 9'd0;
	end

	always @(negedge screenEnd) begin
		player_center_x <= accel_x[9:0];
		player_center_y <= accel_y[8:0];
	end
	
	always @(posedge screenEnd) begin
		player_left_x <= player_center_x - 10'd25;
		player_right_x <= player_center_x + 10'd25;
		player_top_y <= player_center_y - 9'd25;
		player_bottom_y <= player_center_y + 9'd25;
	end

	wire within_player_box;
	assign within_player_box = (player_left_x < x && x < player_right_x) && (player_top_y < y && y < player_bottom_y);
	assign player_box_colorData = 12'h0F0;

	// Draw Target Box
	reg[9:0] target_center_x;
	reg[8:0] target_center_y;
	reg[9:0] target_left_x, target_right_x; 
	reg[8:0] target_top_y, target_bottom_y;
	initial begin
		target_left_x <= 10'd0;
		target_right_x <= 10'd0;
		target_top_y <= 9'd0;
		target_bottom_y <= 9'd0;
	end

	always @(negedge screenEnd) begin
		target_center_x <= target_x[9:0];
		target_center_y <= target_y[8:0];
	end

	always @(posedge screenEnd) begin
		target_left_x <= target_center_x - 10'd30;
		target_right_x <= target_center_x + 10'd30;
		target_top_y <= target_center_y - 9'd30;
		target_bottom_y <= target_center_y + 9'd30;
	end

	wire within_target_box;
	assign within_target_box = (target_left_x < x && x < target_right_x) && (target_top_y < y && y < target_bottom_y);
	assign target_box_colorData = 12'h00F;

	assign colorScreen_inter = within_target_box ? target_box_colorData : bg_colorData;
	assign colorScreen_final = within_player_box ? player_box_colorData : colorScreen_inter;
	assign colorOut = active ? colorScreen_final : 12'd0; // When not active, output black

	// Quickly assign the output colors to their channels using concatenation
	assign {VGA_R, VGA_G, VGA_B} = colorOut;

	// Get PS2 Controller
	wire read_data;
	wire[7:0] rx_data;
	reg[7:0] latched_rx_data;
	Ps2Interface controller(.ps2_clk(ps2_clk), .ps2_data(ps2_data), .clk(clk_100mHz), .rst(reset), .rx_data(rx_data), .read_data(read_data));
	always @(posedge read_data) begin
		latched_rx_data = rx_data;
	end

endmodule