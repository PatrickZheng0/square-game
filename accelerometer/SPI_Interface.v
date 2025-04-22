// Inspired by SPI_If.vhd in FPGA Default Demo Code in https://github.com/Digilent/Nexys-A7-100T-OOB
`timescale 1ns / 1ps
module SPI_Inteface(
    input clk,
    input reset,
    input[7:0] data_in,
    output[7:0] data_out,
    input start,
    input done,
    input hold_ss, // forces SS to be low when transmitting multiple bytes
    output sclk,
    output mosi,
    input miso,
    output ss
);

    localparam
        // general parameters
        SYSCLK_FREQUENCY_HZ = 108000000,
        SCLK_FREQUENCY_HZ   = 1000000,
        DIV_RATE = (SYSCLK_FREQUENCY_HZ / (2 * SCLK_FREQUENCY_HZ)) - 1;

    localparam[7:0]
        // Bit encodings for 4 states
        state_idle = 8'b10100000,
        state_prepare = 8'b00001001,
        state_shift = 8'b01011011,
        state_done = 8'b00001110;

    // Initialize state
    reg[7:0] state_current = state_idle;
    reg[7:0] state_next = state_idle;

    // Create wires for values inside the state
    reg EN_LOAD_DIN, EN_SHIFT, Reset_Counters, EN_SCLK, EN_SS, EN_LOAD_DOUT;

    // Pipeline Done
    reg DONE_1 = 1'b0;

    // Generate output enables from state bits
    always @(*) begin
        EN_LOAD_DIN    = state_current[7];
        EN_SHIFT       = state_current[6];
        Reset_Counters = state_current[5];
        EN_SCLK        = state_current[4];
        EN_SS          = state_current[3];
        EN_LOAD_DOUT   = state_current[2];
    end

    // Define SS and MOSI
    assign ss = (!reset && (hold_ss || EN_SS)) ? 1'b0 : 1'b1;
    assign mosi = MOSI_REG[7];

    // Get sclk
    assign sclk = EN_SCLK ? SCLK_INTER : 1'b0;
    
    reg data_out_inter, done_inter;
    assign data_out = data_out_inter;
    assign done = done_inter;

    // Load received byte into data_out, with reset
    always @(posedge clk) begin
        if (reset) begin
            data_out_inter <= 8'd0;
        end else if (EN_LOAD_DOUT) begin
            data_out_inter <= MISO_REG;
        end
    end

    // Done pulse one cycle later, reset
    always @(posedge clk) begin
        if (reset) begin
            DONE_1 <= 1'b0;
            done_inter <= 1'b0;
        end else begin
            DONE_1 <= EN_LOAD_DOUT;
            done_inter <= DONE_1;
        end
    end

    // Create SCLK_2X_TICK that toggles twice per sclk cycle
    wire SCLK_2X_TICK = (SCLK_2X_DIV == DIV_RATE);
    reg[31:0] SCLK_2X_DIV = 0;

    always @(posedge clk) begin
    if (Reset_Counters || SCLK_2X_TICK)
        SCLK_2X_DIV <= 0;
    else
        SCLK_2X_DIV <= SCLK_2X_DIV + 1;
    end

    // Toggles SCLK_INTER twice per sclk cycle, creating the serial clk sclk
    reg SCLK_INTER;

    always @(posedge clk) begin
    if (Reset_Counters)
        SCLK_INTER <= 1'b0;
    else if (SCLK_2X_TICK)
        SCLK_INTER <= ~SCLK_INTER;
    end

    // Shift signals
    wire SHIFT_TICK_IN = EN_SHIFT && !SCLK_INTER && SCLK_2X_TICK; // high on posedge sclk, sample MISO
    wire SHIFT_TICK_OUT = EN_SHIFT && SCLK_INTER && SCLK_2X_TICK; // high on negedge sclk, shift out MOSI

    // Shift in MISO bit
    reg[7:0] MISO_REG = 8'b0;

    always @(posedge clk) begin
        if (SHIFT_TICK_IN)
            MISO_REG <= {MISO_REG[6:0], miso};
    end

    // Shift out MOSI bit or put in load byte
    reg[7:0] MOSI_REG = 8'b0;

    always @(posedge clk) begin
        if (EN_LOAD_DIN)
            MOSI_REG <= data_in;
        else if (SHIFT_TICK_OUT)
            MOSI_REG <= {MOSI_REG[6:0], 1'b0};
    end

    // Count bits shifted
    reg[2:0] bits_shifted = 3'b0;

    always @(posedge clk) begin
        if (Reset_Counters)
            bits_shifted <= 3'd0;
        else if (SHIFT_TICK_OUT) begin
            bits_shifted <= (bits_shifted == 3'd7) ? 3'd0 : (bits_shifted + 1);
        end
    end

    // Set new state
    always @(posedge clk) begin
        if (reset)
            state_current <= state_idle;
        else
            state_current <= state_next;
    end

    // Get next state
    wire Start_Shifting = (state_current == state_prepare) && (hold_ss || (SCLK_INTER && SCLK_2X_TICK));
    wire Shifting_Done = (state_current == state_shift) && (bits_shifted == 3'd7) && SCLK_INTER && SCLK_2X_TICK;

    always @(*) begin
        state_next <= state_current;
        if (state_current == state_idle) begin
            if (start)
                state_next = state_prepare;
        end else if (state_current == state_prepare) begin
            if (Start_Shifting)
                state_next = state_shift;
        end else if (state_current == state_shift) begin
            if (Shifting_Done)
                state_next = state_done;
        end else if (state_current == state_done)
            state_next = state_idle;
        else
            state_next = state_idle;
    end

endmodule