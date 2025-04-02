`timescale 1 ns/ 100 ps
module VGAController(     
	input clk_25mHz, 	// 25 MHz PLL Clock
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
	input[8:0] accel_x,
	input[8:0] accel_y
	);

	// Lab Memory Files Location
	localparam FILES_PATH = "C:/Users/pzhen/VSCodeProjects/ECE_350_Workspace/square-game/vga/";

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

	RAM #(		
		.DEPTH(PIXEL_COUNT), 				     // Set RAM depth to contain every pixel
		.DATA_WIDTH(PALETTE_ADDRESS_WIDTH),      // Set data width according to the color palette
		.ADDRESS_WIDTH(PIXEL_ADDRESS_WIDTH),     // Set address with according to the pixel count
		.MEMFILE({FILES_PATH, "image.mem"})) // Memory initialization
	ImageData(
		.clk(clk), 						 		// Falling edge of the 100 MHz clk
		.addr(imgAddress),					 // Image data address
		.dataOut(colorAddr),				 // Color palette address
		.wEn(1'b0)); 						 // We're always reading

	// Color Palette to Map Color Address to 12-Bit Color
	wire[BITS_PER_COLOR-1:0] bg_colorData; // 12-bit color data at current pixel
	wire[BITS_PER_COLOR-1:0] box_colorData; // 12-bit color data at current pixel

	RAM #(
		.DEPTH(PALETTE_COLOR_COUNT), 		       // Set depth to contain every color		
		.DATA_WIDTH(BITS_PER_COLOR), 		       // Set data width according to the bits per color
		.ADDRESS_WIDTH(PALETTE_ADDRESS_WIDTH),     // Set address width according to the color count
		.MEMFILE({FILES_PATH, "colors.mem"}))  	// Memory initialization
	ColorPalette(
		.clk(clk), 							   	   // Rising edge of the 100 MHz clk
		.addr(colorAddr),					       // Address from the ImageData RAM
		.dataOut(bg_colorData),				       // Color at current pixel
		.wEn(1'b0)); 						       // We're always reading

	// Assign to output color from register if active
	wire[BITS_PER_COLOR-1:0] colorOut; 			  // Output color 
	wire[BITS_PER_COLOR-1:0] colorScreen;

	// Draw Box
	reg[9:0] tl_x, tl_y;
	wire[9:0] right_x, bottom_y;
	
	assign right_x = 10'd50 + tl_x;
	assign bottom_y = 10'd50 + tl_y;

	wire within_box;
	assign within_box = (tl_x < x && x < right_x) && (tl_y < y && y < bottom_y);
	assign box_colorData = 12'd15;

	assign colorScreen = within_box ? 12'h0F0 : bg_colorData;
	assign colorOut = active ? colorScreen : 12'd0; // When not active, output black

	// Quickly assign the output colors to their channels using concatenation
	assign {VGA_R, VGA_G, VGA_B} = colorOut;


	initial begin
		tl_x = 0;
		tl_y = 0;
	end

	always @(posedge screenEnd) begin
		tl_x = accel_y;
		tl_y = accel_x;
	end


	// Get PS2 Controller
	wire read_data;
	wire[7:0] rx_data;
	reg[7:0] latched_rx_data;
	Ps2Interface controller(.ps2_clk(ps2_clk), .ps2_data(ps2_data), .clk(clk), .rst(reset), .rx_data(rx_data), .read_data(read_data));
	always @(posedge read_data) begin
		latched_rx_data = rx_data;
	end

endmodule