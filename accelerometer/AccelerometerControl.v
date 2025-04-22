// Inspired by AccelerometerCtl.vhd in FPGA Default Demo Code in https://github.com/Digilent/Nexys-A7-100T-OOB
`timescale 1ns / 1ps
module AccelerometerControl(
    input clk,
    input reset,
    output sclk,
    output mosi,
    input miso,
    output ss,
    output accel_x_out,
    output accel_y_out
);

    wire[11:0] accel_x_raw, accel_y_raw;
    wire data_rdy;

    localparam SYSCLK_FREQUENCY_HZ = 108_000_000;
    localparam SCLK_FREQUENCY_HZ   =   1_000_000;
    localparam NUM_READS_AVG       =          16;
    localparam UPDATE_FREQUENCY_HZ =         100;

    // 10 µs reset hold
    localparam ACC_RESET_PERIOD_US    = 10;
    localparam ACC_RESET_IDLE_CLOCKS  = (ACC_RESET_PERIOD_US * 1000)
                                        / (1_000_000_000 / SYSCLK_FREQUENCY_HZ);

    // Raw 12‑bit outputs from the ADXL controller
    wire [11:0] ax_raw, ay_raw, az_raw;
    wire data_rdy_raw;

    // Reset stretching counter
    reg [$clog2(ACC_RESET_IDLE_CLOCKS)-1:0] cnt_reset = 0;
    reg reset_int  = 1'b1;

    // On reset, hold the reset_int high for ~10 us
    always @(posedge clk) begin
        if (reset) begin
            cnt_reset <= 0;
            reset_int <= 1'b1;
        end else if (cnt_reset == ACC_RESET_IDLE_CLOCKS-1) begin
            cnt_reset <= cnt_reset;
            reset_int <= 1'b0;
        end else begin
            cnt_reset <= cnt_reset + 1;
            reset_int <= 1'b1;
        end
    end

    // Initialize accelerometer control and SPI inteface    
    ADXL362Control adxl_control (
        .clk (clk),
        .reset (reset_int),
        .accel_x (accel_x_raw),
        .accel_y (accel_y_raw),
        .data_rdy (data_rdy),   // pulses when new samples ready
        .sclk (sclk),
        .mosi (mosi),
        .miso (miso),
        .ss (ss)
    );

    // Intialize module to scale raw data
    AccelArithmetics accel_arithmetics (
        .clk (clk),
        .reset (reset_int),
        .data_rdy (data_rdy),
        .accel_x_in (accel_x_raw),
        .accel_y_in (accel_y_raw),
        .accel_x_out (accel_x_out),
        .accel_y_out (accel_y_out)
    );

endmodule