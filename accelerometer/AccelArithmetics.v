// Inspired by AccelArithmetics.vhd in FPGA Default Demo Code in https://github.com/Digilent/Nexys-A7-100T-OOB
`timescale 1ns / 1ps
module AccelArithmetics(
    input clk,
    input reset,
    input data_rdy,
    input[11:0] accel_x_in,
    input[11:0] accel_y_in,
    output[8:0] accel_x_out, // unsigned measuring -1g to 1g, 0 to 511
    output[8:0] accel_y_out  // unsigned measuring -1g to 1g, 0 to 511
);

    // Acceleration input is from -2048 to 2047, measuring -2g to 2g
    // Module outputs scaled data from 0 to 511, measuring -1g to 1g
    // First add sum_factor = 2047 to get range from 0 to 4095, 2047 to ensure 0 stays 0 after scaling
    // Right shift by 2 to get range to be 0 to 1023, measuring -2g to 2g
    // Subtract 255 then bound between 0 and 511 to get -1g to 1g

    // Add sum_factor
    reg[12:0] sum_x, sum_y;
    reg[12:0] sum_factor = 13'd2047;

    always @(posedge clk) begin
        if (reset) begin
            sum_x <= 13'd0;
            sum_y <= 13'd0;
        end
        else if (data_rdy) begin
            sum_x <= {accel_x_in[11], accel_x_in} + sum_factor;
            sum_y <= {accel_y_in[11], accel_y_in} + sum_factor;
        end
    end

    // Shift scaled values
    wire[9:0] shifted_x = sum_x[11:2];
    wire[9:0] shifted_y = sum_y[11:2];

    // Bound -1g to 1g between 0 and 511
    reg[9:0] clip_x, clip_y;
    reg[9:0] lower_bound  = 10'd255;
    reg[9:0] upper_bound  = 10'd767;

    always @(posedge clk) begin
    if (reset) begin
        clip_x <= 10'b0;
        clip_y <= 10'b0;
    end else begin
        if (shifted_x <= lower_bound)
            clip_x <= 10'b0;
        else if (shifted_x >= upper_bound)
            clip_x <= 10'd511;
        else
            clip_x <= shifted_x - lower_bound;

        if (shifted_y <= lower_bound)
            clip_y <= 10'b0;
        else if (shifted_y >= upper_bound)
            clip_y <= 10'd511;
        else
            clip_y <= shifted_y - lower_bound;
        end
    end

    // Invert y output because of accelerometer orientation
    assign accel_x_out = clip_x[8:0];
    assign accel_y_out = ~clip_y[8:0];

endmodule