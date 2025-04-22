// Inspired by ADXL362Ctrl.vhd in FPGA Default Demo Code in https://github.com/Digilent/Nexys-A7-100T-OOB
`timescale 1ns / 1ps
module ADXL362Control(
    input clk,
    input reset,
    output accel_x,
    output accel_y,
    output data_rdy,
    output sclk,
    output mosi,
    input miso,
    output ss
);

    localparam[7:0]
        READ_CMD = 8'h0B,
        STATUS_ADDR = 8'h0B, // addr of STATUS register
        DATA_ADDR = 8'h0E; // addr of XDATA_L

    // FSM states
    localparam  
        IDLE = 3'd0,
        SEND_STATUS = 3'd1,
        READ_STATUS = 3'd2,
        SEND_DATA_CMD = 3'd3,
        READ_DATA = 3'd4,
        PULSE_READY = 3'd5;

    reg[2:0] state, next_state;

    // Counter for bytes for reading
    reg[1:0] byte_count;

    // SPI Interface wires
    reg spi_start, spi_hold;
    reg[7:0] spi_tx;
    wire[7:0] spi_rx;
    wire spi_done;

    SPI_Inteface spi_if(
        .clk (clk),
        .reset (reset),
        .data_in (spi_tx),
        .data_out (spi_rx),
        .start (spi_start),
        .done (spi_done),
        .hold_ss (spi_hold),
        .sclk (sclk),
        .mosi (mosi),
        .miso (miso),
        .ss (ss)
    );

    // Move to next FSM state
    always @(posedge clk) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Get next FSM state
    always @(*) begin
        if (state == IDLE) begin
            if (!reset)
                next_state = SEND_STATUS;
        end else if (state == SEND_STATUS) begin
            if (spi_done)
                next_state = READ_STATUS;
        end else if (state == READ_STATUS) begin
            if (spi_done)
                next_state = (spi_rx[0] ? SEND_DATA_CMD : SEND_STATUS);
        end else if (state == SEND_DATA_CMD) begin
            if (spi_done && byte_count == 2)
                next_state = READ_DATA;
        end else if (state == READ_DATA) begin
            if (spi_done && byte_count == 3)
                next_state = PULSE_READY;
        end else if (state == PULSE_READY)
            next_state = IDLE;
        else
            next_state = IDLE;
    end

    reg[11:0] accel_x_inter, accel_y_inter;
    reg data_rdy_inter;
    assign accel_x = accel_x_inter;
    assign accel_y = accel_y_inter;
    assign data_rdy = data_rdy_inter;

    // Set control signals for spi interface
    always @(posedge clk) begin
        if (reset) begin
            spi_start <= 1'b0;
            spi_hold <= 1'b0;
            spi_tx <= 8'd0;
            byte_count <= 2'd0;
            accel_x_inter <= 12'd0;
            accel_y_inter <= 12'd0;
            data_rdy_inter <= 1'b0;
        end else begin
            // default case
            spi_start <= 1'b0;
            data_rdy_inter <= 1'b0;
        end

        if (state == IDLE) begin
            // Prepare for 2 writes and 1 read
            byte_count <= 2'd0;
            spi_hold <= 1'b1; // keep SS low across all three bytes
            spi_tx <= READ_CMD; // first byte = READ_CMD
            spi_start <= 1'b1;
        end else if (state == SEND_STATUS) begin
            if (spi_done) begin
                byte_count <= byte_count + 1;
                if (byte_count == 0) spi_tx <= STATUS_ADDR;
                else if (byte_count == 1) spi_tx <= 8'd0; // dummy read
                spi_start <= 1'b1;
            end
        end else if (state == READ_STATUS) begin
            if (spi_done) begin
                // if status[0] = 1, data ready; otherwise keep polling
                spi_hold <= 1'b0; // release SS to re‑select for next action
            end
        end else if (state == SEND_DATA_CMD) begin
            // Prepare for 2 writes, then 4 reads
            byte_count <= 2'd0;
            spi_hold <= 1'b1;
            if (spi_done) begin
                byte_count <= byte_count + 1;
                if (byte_count == 0)
                    spi_tx <= READ_CMD;
                else if (byte_count == 1)
                    spi_tx <= DATA_ADDR;
                else
                    spi_tx <= 8'd0;  // dummy to clock X_L, X_H, Y_L, Y_H

                spi_start <= 1'b1;
            end
        end else if (state == READ_DATA) begin
            if (spi_done) begin
                // capture the four bytes in order: X_L, X_H, Y_L, Y_H
                if (byte_count == 3'd2)
                    accel_x_inter[7:0] <= spi_rx;
                else if (byte_count == 3'd3)
                    accel_x_inter[11:8] <= spi_rx[3:0];
                else if (byte_count == 3'd4)
                    accel_y_inter[7:0] <= spi_rx;
                else if (byte_count == 3'd5)
                    accel_y_inter[11:8] <= spi_rx[3:0];

                byte_count <= byte_count + 1;

                // Continue reading if more bytes exist
                if (byte_count < 5) begin
                    spi_tx <= 8'd0;
                    spi_start <= 1'b1;
                end else begin
                    spi_hold <= 1'b0; // done with action
                end
            end
        end else if (state == PULSE_READY) begin
            // sign‑extend top nibble for two’s‑complement
            accel_x_inter[11] <= spi_rx[7];  
            accel_y_inter[11] <= spi_rx[7];
            data_rdy_inter <= 1'b1;
        end
    end

endmodule